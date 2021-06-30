import 'dart:io';
import 'dart:isolate';
// import 'package:eye_of_god/depthModel/classifier_quant.dart';
import 'package:eye_of_god/OnDevice_ML/OCR/ocr.dart';
import 'package:eye_of_god/OnDevice_ML/depthModel/depthClass.dart';
import 'package:eye_of_god/OnDevice_ML/depthModel/depthMapRes.dart';
import 'package:eye_of_god/utils/ocrIsolate.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:eye_of_god/OnDevice_ML/tflite/classifier.dart';
import 'package:eye_of_god/OnDevice_ML/tflite/recognition.dart';
import 'package:eye_of_god/OnDevice_ML/tflite/stats.dart';
import 'package:eye_of_god/ui/camera_view_singleton.dart';
import 'package:eye_of_god/utils/isolate_utils.dart';
import 'package:eye_of_god/utils/depthIsolate.dart';
import 'dart:math' as math;

/// [CameraViewIndoor] sends each frame for inference
class CameraViewIndoor extends StatefulWidget {
  /// Callback to pass results after inference to [HomeView]

  final Function(DepthMap depthMap) depthMapCallback;

  final Function(List<TextBlock> ocrElement) ocrCallback;

  /// Constructor
  const CameraViewIndoor(this.depthMapCallback, this.ocrCallback);
  @override
  _CameraViewIndoorState createState() => _CameraViewIndoorState();
}

class _CameraViewIndoorState extends State<CameraViewIndoor>
    with WidgetsBindingObserver {
  /// List of available cameras
  List<CameraDescription> cameras;

  /// Controller
  CameraController cameraController;

  /// true when inference is ongoing
  bool predicting;

  /// Instance of [Classifier]
  //Classifier classifier;
  depthModel depthClassy;

  /// Instance of [IsolateUtils]
  IsolateUtils isolateUtils;
  DepthIsolateUtils depthIsolateUtils;
  //OcrIsolateUtils ocrIsolateUtils;

  @override
  void initState() {
    super.initState();
    initStateAsync();
  }

  void initStateAsync() async {
    WidgetsBinding.instance.addObserver(this);

    // Spawn a new isolate
    // isolateUtils = IsolateUtils();
    depthIsolateUtils = DepthIsolateUtils();
    //ocrIsolateUtils = OcrIsolateUtils();
    // await isolateUtils.start();
    await depthIsolateUtils.start();
    //await ocrIsolateUtils.start();

    // Camera initialization
    initializeCamera();
    depthClassy = depthModel();

    // Initially predicting = false
    predicting = false;
  }

  /// Initializes the camera by setting [cameraController]
  void initializeCamera() async {
    cameras = await availableCameras();

    // cameras[0] for rear-camera
    cameraController = CameraController(cameras[0], ResolutionPreset.medium,
        enableAudio: false);

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
      CameraViewSingleton.screenSize = screenSize;
      CameraViewSingleton.ratio = screenSize.width / previewSize.height;
    });
  }

  @override
  Widget build(BuildContext context) {
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
    print("previe is : $previewH and $previewW");
    return OverflowBox(
      // maxHeight: 352,
      maxWidth: 500,
      child: RotatedBox(
        quarterTurns: 0,
        child: Transform.rotate(
          angle: 0,
          child: CameraPreview(cameraController),
        ),
      ),
    );
  }

  onLatestImageAvailable(CameraImage cameraImage) async {
    if (depthClassy.interpreter != null) {
      if (predicting) {
        return;
      }

      setState(() {
        predicting = true;
      });
      var textTest = await OcrManager.scanText(cameraImage);
      //print("jolyne is : ${textTest}");
      var depthIsolateData =
          IsolateDepthData(cameraImage, depthClassy.interpreter.address);
      var depthMaps = await depthInference(depthIsolateData);
      // depthInference(depthIsolated);

      // var ocrIsolateData = IsolateOcrData(cameraImage);
      // var visionText = await ocrInference(ocrIsolateData);
      // print("jotaro now : $visionText");
      DepthMap k = DepthMap();
      k.depthMap = depthMaps[0];
      k.depthMapCV = depthMaps[1];
      k.OGImage = depthMaps[2];
      widget.depthMapCallback(k);
      widget.ocrCallback(textTest);
      // pass stats to HomeView

      setState(() {
        predicting = false;
      });
    }
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

  // Future<dynamic> ocrInference(IsolateOcrData ocrIsolated) async {
  //   ReceivePort responsePort = ReceivePort();
  //   // print(depthIsolateUtils.sendPort);
  //   ocrIsolateUtils.sendPort
  //       .send(ocrIsolated..responsePort = responsePort.sendPort);
  //   var results = await responsePort.first;
  //   // print("It is");
  //   // print(results.runtimeType);
  //   return results;
  // }

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
