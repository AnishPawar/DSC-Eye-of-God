// import 'package:flutter/cupertino.dart';
// // import 'package:speech_to_text/speech_to_text.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:speech_recognition/speech_recognition.dart';

// void playsoundTing() {
//   final player = AudioCache();
//   player.play("Ting.wav");
// }

// void playsoundTong() {
//   final player = AudioCache();
//   player.play("Tong.wav");
// }

// class SpeechApi {
//   // SpeechRecognition _speech;

//   // bool _speechRecognitionAvailable = false;
//   // bool _isListening = false;
//   // static final _speech = SpeechToText();
//   // void activateSpeechRecognizer() {
//   //   print('_MyAppState.activateSpeechRecognizer... ');
//   //   _speech = new SpeechRecognition();
//   //   _speech.setAvailabilityHandler(onSpeechAvailability);
//   //   _speech.setCurrentLocaleHandler(onCurrentLocale);
//   //   _speech.setRecognitionStartedHandler(onRecognitionStarted);
//   //   _speech.setRecognitionResultHandler(onRecognitionResult);
//   //   _speech.setRecognitionCompleteHandler(onRecognitionComplete);
//   //   // _speech.setErrorHandler(errorHandler);
//   //   _speech
//   //       .activate()
//   //       .then((res) => setState(() => _speechRecognitionAvailable = res));
//   // }

//   // void start() => _speech
//   //     .listen(locale: 'en_US')
//   //     .then((result) => print('_MyAppState.start => result $result'));

//   // void cancel() =>
//   //     _speech.cancel().then((result) => setState(() => _isListening = result));

//   // void stop() => _speech.stop().then((result) {
//   //       setState(() => _isListening = result);
//   //     });

//   // void onSpeechAvailability(bool result) =>
//   //     setState(() => _speechRecognitionAvailable = result);

//   // void onCurrentLocale(String locale) {
//   //   print('_MyAppState.onCurrentLocale... $locale');
//   //   setState(
//   //       () => selectedLang = languages.firstWhere((l) => l.code == locale));
//   // }

//   // void onRecognitionStarted() => setState(() => _isListening = true);

//   // void onRecognitionResult(String text) => setState(() => transcription = text);

//   // void onRecognitionComplete() => setState(() => _isListening = false);

//   // void errorHandler() => activateSpeechRecognizer();
//   static Future<bool> toggleRecording({
//     @required Function(String text) onResult,
//     @required ValueChanged<bool> onListening,
//   }) async {
//     if (_speech.isListening) {
//       _speech.stop();
//       playsoundTong();
//       return true;
//     } else {
//       playsoundTing();
//     }
//     final isAvailable = await _speech.initialize(
//       onStatus: (status) => onListening(_speech.isListening),
//       onError: (e) => print('Error: $e'),
//     );

//     if (isAvailable) {
//       _speech.listen(onResult: (value) => onResult(value.recognizedWords));
//     }

//     return isAvailable;
//   }
// }
