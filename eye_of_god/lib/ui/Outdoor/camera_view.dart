import 'dart:io';
import 'dart:isolate';
// import 'package:eye_of_god/depthModel/classifier_quant.dart';
import 'package:eye_of_god/OnDevice_ML/depthModel/depthClass.dart';
import 'package:eye_of_god/OnDevice_ML/depthModel/depthMapRes.dart';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:eye_of_god/OnDevice_ML/tflite/classifier.dart';
import 'package:eye_of_god/OnDevice_ML/tflite/recognition.dart';
import 'package:eye_of_god/OnDevice_ML/tflite/stats.dart';
import 'package:eye_of_god/ui/camera_view_singleton.dart';
import 'package:eye_of_god/utils/isolate_utils.dart';
import 'package:eye_of_god/utils/depthIsolate.dart';
import 'dart:math' as math;

/// [CameraView] sends each frame for inference
class CameraView extends StatefulWidget {
  /// Callback to pass results after inference to [HomeView]
  final Function(List<dynamic> recognitions) resultsCallback;

  /// Callback to inference stats to [HomeView]
  final Function(Stats stats) statsCallback;

  final Function(DepthMap depthMap) depthMapCallback;

  /// Constructor
  const CameraView(
      this.resultsCallback, this.statsCallback, this.depthMapCallback);
  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  /// List of available cameras
  List<CameraDescription> cameras;

  /// Controller
  CameraController cameraController;

  /// true when inference is ongoing
  bool predicting;

  /// Instance of [Classifier]
  Classifier classifier;
  depthModel depthClassy;

  /// Instance of [IsolateUtils]
  IsolateUtils isolateUtils;
  DepthIsolateUtils depthIsolateUtils;

  @override
  void initState() {
    super.initState();
    initStateAsync();
  }

  void initStateAsync() async {
    WidgetsBinding.instance.addObserver(this);

    // Spawn a new isolate
    isolateUtils = IsolateUtils();
    depthIsolateUtils = DepthIsolateUtils();
    await isolateUtils.start();
    await depthIsolateUtils.start();

    // Camera initialization
    initializeCamera();

    // Create an instance of classifier to load model and labels
    classifier = Classifier();
    depthClassy = depthModel();

    // Initially predicting = false
    predicting = false;
  }

  /// Initializes the camera by setting [cameraController]
  void initializeCamera() async {
    cameras = await availableCameras();

    // cameras[0] for rear-camera
    cameraController =
        CameraController(cameras[0], ResolutionPreset.low, enableAudio: false);

    cameraController.initialize().then((_) async {
      // Stream of image passed to [onLatestImageAvailable] callback
      await cameraController.startImageStream(onLatestImageAvailable);

      /// previewSize is size of each image frame captured by controller
      ///
      /// 352x288 on iOS, 240p (320x240) on Android with ResolutionPreset.low
      Size previewSize = cameraController.value.previewSize;
      print("It is:$previewSize");

      /// previewSize is size of raw input image to the model
      CameraViewSingleton.inputImageSize = previewSize;

      // the display width of image on screen is
      // same as screenWidth while maintaining the aspectRatio
      Size screenSize = MediaQuery.of(context).size;
      print("screen si: ${screenSize.height}");
      CameraViewSingleton.screenSize = screenSize;
      CameraViewSingleton.ratio = screenSize.width / previewSize.height;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Return empty container while the camera is not initialized
    if (cameraController == null || !cameraController.value.isInitialized) {
      return Container();
    }

    var tmp = MediaQuery.of(context).size;

    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = cameraController.value.previewSize;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    print("Previe is: $screenH $screenW");

    return OverflowBox(
      // maxHeight: 352,
      maxWidth: 500,
      child: RotatedBox(
        quarterTurns: 0,
        child: Transform.rotate(
          angle: 0,
          // scale: cameraController.value.aspectRatio,
          child: CameraPreview(cameraController),
        ),
      ),
    );
  }

  /// Callback to receive each frame [CameraImage] perform inference on it
  onLatestImageAvailable(CameraImage cameraImage) async {
    if (classifier.interpreter != null && classifier.labels != null) {
      if (predicting) {
        return;
      }

      setState(() {
        predicting = true;
      });

      var uiThreadTimeStart = DateTime.now().millisecondsSinceEpoch;

      var isolateData = IsolateData(
          cameraImage, classifier.interpreter.address, classifier.labels);

      List<dynamic> inferenceResults = await inference(isolateData);

      var depthIsolateData =
          IsolateDepthData(cameraImage, depthClassy.interpreter.address);
      var depthMaps = await depthInference(depthIsolateData);
      // depthInference(depthIsolated);

      var uiThreadInferenceElapsedTime =
          DateTime.now().millisecondsSinceEpoch - uiThreadTimeStart;

      // pass results to HomeView
      widget.resultsCallback(inferenceResults);

      DepthMap k = DepthMap();
      k.depthMap = depthMaps[0];
      k.depthMapCV = depthMaps[1];
      k.OGImage = depthMaps[2];
      widget.depthMapCallback(k);
      // pass stats to HomeView
      widget.statsCallback((inferenceResults[1]["stats"] as Stats)
        ..totalElapsedTime = uiThreadInferenceElapsedTime);

      setState(() {
        predicting = false;
      });
    }
  }

  /// Runs inference in another isolate
  Future<List<dynamic>> inference(IsolateData isolateData) async {
    ReceivePort responsePort = ReceivePort();
    // print(isolateUtils.sendPort);
    isolateUtils.sendPort
        .send(isolateData..responsePort = responsePort.sendPort);
    var results = await responsePort.first;
    return results;
  }

  Future<dynamic> depthInference(IsolateDepthData depthIsolated) async {
    ReceivePort responsePort = ReceivePort();
    // print(depthIsolateUtils.sendPort);
    depthIsolateUtils.sendPort
        .send(depthIsolated..responsePort = responsePort.sendPort);
    var results = await responsePort.first;
    // print("It is");
    // print(results.runtimeType);
    return results;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
        cameraController.stopImageStream();
        break;
      case AppLifecycleState.resumed:
        if (!cameraController.value.isStreamingImages) {
          await cameraController.startImageStream(onLatestImageAvailable);
        }
        break;
      default:
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController.dispose();
    super.dispose();
  }
}
