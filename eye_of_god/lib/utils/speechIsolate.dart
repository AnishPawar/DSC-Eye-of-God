import 'dart:io';
import 'dart:isolate';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as imageLib;
import 'package:eye_of_god/OnDevice_ML/tflite/classifier.dart';
import 'package:eye_of_god/ui/Outdoor/outdoor.dart';
import 'package:eye_of_god/utils/image_utils.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:eye_of_god/OnDevice_ML/depthModel/depthClass.dart';
import 'package:flutter_text_to_speech/flutter_text_to_speech.dart';
// import 'package:eye_of_god/depthModel/classifier_quant.dart';
// import 'package:eye_of_god/depthModel/classifier_float.dart';

/// Manages separate Isolate instance for inference
class SpeechIsolateUtils {
  static const String DEBUG_NAME = "InferenceIsolateDepth";

  Isolate _isolateSpeech;
  ReceivePort _receivePort = ReceivePort();
  SendPort _sendPort;

  SendPort get sendPort => _sendPort;

  Future<void> start() async {
    _isolateSpeech = await Isolate.spawn<SendPort>(
      entryPoint,
      _receivePort.sendPort,
      debugName: DEBUG_NAME,
    );

    _sendPort = await _receivePort.first;
  }

  static void entryPoint(SendPort sendPort) async {
    final port = ReceivePort();

    sendPort.send(port.sendPort);

    await for (final IsolateSpeechData isolateData in port) {
      if (isolateData != null) {
        // print("Coming in ");
        // VoiceController controller;
        // controller = FlutterTextToSpeech.instance.voiceController();

        // var controller = isolateData.controller;
        // String inputSpeech = isolateData.SpeechString;
        // try {
        //   controller.speak(
        //       inputSpeech, VoiceControllerOptions(delay: 2, volume: 1));
        //   print("coming 3");
        // } catch (e) {
        //   print("Voice Error:$e");
        // }

        // print("Coming in 2");
        print("Preparing to Speak");
        isolateData.initController();
        isolateData.controller
            .speak("Something", VoiceControllerOptions(delay: 1, volume: 1));
        print("Speaking");
        isolateData.responsePort.send(true);
      }
      isolateData.responsePort.send(false);
    }
  }
}

/// Bundles data to pass between Isolate
class IsolateSpeechData {
  String SpeechString;
  VoiceController controller;
  SendPort responsePort;
  void initController() {
    controller = FlutterTextToSpeech.instance.voiceController();
  }

  IsolateSpeechData(this.SpeechString);
}
