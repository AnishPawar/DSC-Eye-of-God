import 'dart:io';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as imageLib;
import 'package:ondeviceog/tflite/classifier.dart';
import 'package:ondeviceog/utils/image_utils.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:ondeviceog/depthModel/depthClass.dart';
// import 'package:ondeviceog/depthModel/classifier_quant.dart';
// import 'package:ondeviceog/depthModel/classifier_float.dart';

/// Manages separate Isolate instance for inference
class IsolateUtils {
  static const String DEBUG_NAME = "InferenceIsolate";

  Isolate _isolate;
  ReceivePort _receivePort = ReceivePort();
  SendPort _sendPort;

  SendPort get sendPort => _sendPort;

  Future<void> start() async {
    _isolate = await Isolate.spawn<SendPort>(
      entryPoint,
      _receivePort.sendPort,
      debugName: DEBUG_NAME,
    );

    _sendPort = await _receivePort.first;
  }

  static void entryPoint(SendPort sendPort) async {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    await for (final IsolateData isolateData in port) {
      if (isolateData != null) {
        Classifier classifier = Classifier(
            interpreter:
                Interpreter.fromAddress(isolateData.interpreterAddressObj),
            labels: isolateData.labels);

        // var zz = isolateData.interpreterAddressObj;
        // print("Received is: $zz");
        // depthModel depthClassy = depthModel(
        //     interpreter:
        //         Interpreter.fromAddress(isolateData.interpreterAddressDepth));
        // );
        imageLib.Image image =
            ImageUtils.convertCameraImage(isolateData.cameraImage);

        if (Platform.isAndroid) {
          image = imageLib.copyRotate(image, 90);
        }

        // depthClassy.predict(image);

        Map<String, dynamic> results = classifier.predict(image);

        isolateData.responsePort.send(results);
      }
    }
  }
}

/// Bundles data to pass between Isolate
class IsolateData {
  CameraImage cameraImage;
  int interpreterAddressObj;
  // int interpreterAddressDepth;
  List<String> labels;
  SendPort responsePort;

  IsolateData(
    this.cameraImage,
    this.interpreterAddressObj,
    // this.interpreterAddressDepth,
    this.labels,
  );
}
