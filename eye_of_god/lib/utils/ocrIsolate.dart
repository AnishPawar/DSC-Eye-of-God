// import 'dart:io';
// import 'dart:isolate';
// import 'package:eye_of_god/OnDevice_ML/OCR/ocr.dart';
// import 'package:http/http.dart';
// import 'dart:convert';
// import 'package:camera/camera.dart';
// import 'package:image/image.dart' as imageLib;
// import 'package:eye_of_god/OnDevice_ML/tflite/classifier.dart';
// import 'package:eye_of_god/utils/image_utils.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:eye_of_god/OnDevice_ML/depthModel/depthClass.dart';
// // import 'package:eye_of_god/depthModel/classifier_quant.dart';
// // import 'package:eye_of_god/depthModel/classifier_float.dart';

// /// Manages separate Isolate instance for inference
// class OcrIsolateUtils {
//   static const String DEBUG_NAME = "InferenceIsolateOcr";

//   Isolate _isolateOcr;
//   ReceivePort _receivePort = ReceivePort();
//   SendPort _sendPort;

//   SendPort get sendPort => _sendPort;

//   Future<void> start() async {
//     _isolateOcr = await Isolate.spawn<SendPort>(
//       entryPoint,
//       _receivePort.sendPort,
//       debugName: DEBUG_NAME,
//     );

//     _sendPort = await _receivePort.first;
//   }

//   static void entryPoint(SendPort sendPort) async {
//     final port = ReceivePort();
//     sendPort.send(port.sendPort);

//     await for (final IsolateOcrData isolateData in port) {
//       if (isolateData != null) {
//         // depthModel depthClassy = depthModel(
//         //     interpreter:
//         //         Interpreter.fromAddress(isolateData.interpreterAddressDepth));
//         // imageLib.Image image =
//         //     ImageUtils.convertCameraImage(isolateData.cameraImage);

//         //var depthMaps = await depthClassy.predict(image);
//         var visiontext = await OcrManager.scanText(isolateData.cameraImage);

//         isolateData.responsePort.send(visiontext);
//       }
//     }
//   }
// }

// /// Bundles data to pass between Isolate
// class IsolateOcrData {
//   CameraImage cameraImage;
//   int interpreterAddressOcr;
//   SendPort responsePort;

//   IsolateOcrData(
//     this.cameraImage,
//     // this.interpreterAddressOcr,
//   );
// }
