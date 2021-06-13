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
class DepthIsolateUtils {
  static const String DEBUG_NAME = "InferenceIsolateDepth";

  Isolate _isolateDepth;
  ReceivePort _receivePort = ReceivePort();
  SendPort _sendPort;

  SendPort get sendPort => _sendPort;

  Future<void> start() async {
    _isolateDepth = await Isolate.spawn<SendPort>(
      entryPoint,
      _receivePort.sendPort,
      debugName: DEBUG_NAME,
    );

    _sendPort = await _receivePort.first;
  }

  static void entryPoint(SendPort sendPort) async {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    await for (final IsolateDepthData isolateData in port) {
      if (isolateData != null) {
        depthModel depthClassy = depthModel(
            interpreter:
                Interpreter.fromAddress(isolateData.interpreterAddressDepth));
        imageLib.Image image =
            ImageUtils.convertCameraImage(isolateData.cameraImage);

        if (Platform.isAndroid) {
          image = imageLib.copyRotate(image, 90);
        }

        var depthMap = await depthClassy.predict(image);

        isolateData.responsePort.send(depthMap);
      }
    }
  }
}

/// Bundles data to pass between Isolate
class IsolateDepthData {
  CameraImage cameraImage;
  int interpreterAddressDepth;
  SendPort responsePort;

  IsolateDepthData(
    this.cameraImage,
    this.interpreterAddressDepth,
  );
}
