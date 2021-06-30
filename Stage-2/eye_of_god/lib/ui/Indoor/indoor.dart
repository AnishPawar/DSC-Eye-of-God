import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/cupertino.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:flutter/material.dart';
import 'package:eye_of_god/ui/selectorPage.dart' as selector;
import 'package:eye_of_god/OnDevice_ML/tflite/recognition.dart';
import 'package:eye_of_god/OnDevice_ML/tflite/stats.dart';
import 'package:eye_of_god/OnDevice_ML/depthModel/depthMapRes.dart';
import 'package:eye_of_god/Speech/utils.dart';
import 'package:eye_of_god/ui/box_widget.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'dart:io';
import 'package:eye_of_god/ui/Indoor/drawIndoorBox.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'dart:isolate';
import 'package:image_crop/image_crop.dart';
import 'package:eye_of_god/OpenCV_Backend/native_opencv.dart';
import 'package:eye_of_god/ui/Indoor/camera_viewIndoor.dart';
import 'package:eye_of_god/Globals/globals.dart' as globals;
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'package:collection/equality.dart';
import 'dart:math' as math;

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';

import 'package:location/location.dart' as location;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:eye_of_god/LocationMethods/geodes.dart';
import 'package:eye_of_god/LocationMethods/directions.dart';
import 'package:eye_of_god/utils/speechIsolate.dart';
import 'package:eye_of_god/Speech/html.dart';
import 'package:eye_of_god/DataClass/Prediction.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_text_to_speech/flutter_text_to_speech.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_blue/flutter_blue.dart';

double latitude = 19.079790;
double longitude = 72.904050;
// enum TtsState { playing, stopped, paused, continued }
var coordinateList;
final cropKey = GlobalKey<CropState>();
List<int> DepthCV = [];
List<int> OGImageList = [];

int blueCounter = 0;
FlutterBlue flutterBlue;
int textBoundingMotor = 0;
int indoorCondCount = 0;
Size imgSize;
List<TextBlock> ocrElementIn = [];
int m1intensity = 0;
bool micState = true;
int m2intensity = 0;
int m3intensity = 0;
int m4intensity = 0;
bool objSpeakState = true;
List motorColors = [
  [0, 0, 0, 0],
  [0, 0, 0, 0],
  [0, 0, 0, 0],
  [0, 0, 0, 0]
];

const languages = const [
  // const Language('Francais', 'fr_FR'),
  const Language('English', 'en_US '),
];

class Language {
  final String name;
  final String code;

  const Language(this.name, this.code);
}

class Indoor extends StatefulWidget {
  static String id = 'indoor';
  // final Function blueCallback;

  @override
  _IndoorState createState() => _IndoorState();
}

// VoiceController controller;
VoiceController controller1;
// enum TtsState { playing, stopped, paused, continued }

class _IndoorState extends State<Indoor> {
  /// Results to draw bounding boxes
  List<Recognition> results;
  void showVersion(BuildContext context) {
    final scaffoldState = Scaffold.of(context);
    final snackbar =
        SnackBar(content: Text('OpenCV version: ${opencvVersion()}'));

    scaffoldState
      ..removeCurrentSnackBar(reason: SnackBarClosedReason.dismiss)
      ..showSnackBar(snackbar);
  }

  void playClass(int classNo) {
    final player = AudioCache();
    player.play("${classNo}.wav");
  }

  void playNav() {
    final player = AudioCache();
    player.play("indoor_dest.wav");
  }

  // ---Blue Vars---
  final String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  final String TARGET_DEVICE_NAME = "ESP32";

  FlutterBlue flutterBlue = FlutterBlue.instance;
  StreamSubscription<ScanResult> scanSubScription;

  BluetoothDevice targetDevice;
  BluetoothCharacteristic targetCharacteristic;

  String connectionText = "";

  // ---Blue Vars---

  // Pulse List

  List<int> pulseList = [0, 0, 0, 0];

  // Pulse List

  Stats stats;

  DepthMap depthMap;

  List<int> imageData = [];
  Uint8List list11;

  List<int> colorSetter(int intensity) {
    List<int> tempColors = [0, 0, 0, 0];
    if (intensity <= 20) {
      tempColors = [1, 0, 0, 0];
    } else if ((intensity > 20) && (intensity <= 50)) {
      tempColors = [1, 1, 0, 0];
    } else if ((intensity > 50) && (intensity <= 80)) {
      tempColors = [1, 1, 1, 0];
    } else if ((intensity > 80)) {
      tempColors = [1, 1, 1, 1];
    }
    return tempColors;
  }

  /// Scaffold Key
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  // double volume = 0.5;
  // double pitch = 1.0;
  // double rate = 1.0;

  String text;
  String dest;
  bool isListening = false;

  FlutterTts flutterTts;
  String language;
  String engine;
  double volume = 10.0;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  String _newVoiceText;

  // TtsState ttsState = TtsState.stopped;

  // get isPlaying => ttsState == TtsState.playing;
  // get isStopped => ttsState == TtsState.stopped;
  // get isPaused => ttsState == TtsState.paused;
  // get isContinued => ttsState == TtsState.continued;

  Color micColor = Colors.teal;
  // List<_Message> messages = List<_Message>();
  // // String _messageBuffer = '';

  // int i = 0;
  //stt.SpeechToText _speech;
  bool get isIOS => !kIsWeb && Platform.isIOS;
  SpeechRecognition _speech;

  bool _speechRecognitionAvailable = false;
  bool _isListening = false;

  String transcription = '';
  var startTime;
  //String _currentLocale = 'en_US';
  Language selectedLang = languages.first;
  SpeechIsolateUtils speechIso;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    activateSpeechRecognizer();
    controller1 = FlutterTextToSpeech.instance.voiceController();
    controller1.init().then((_) {
      print("init done");
    });
    startScan();

    // try {
    //   _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
    //     setState(() {
    //       _gyroscopeValues = <double>[event.x, event.y, event.z];
    //     });
    //   }));
    // } catch (e) {
    //   print("Error is now:$e");
    // }

    //initTts();

    initAsync();
  }

  void initAsync() async {
    speechIso = SpeechIsolateUtils();
    await speechIso.start();
  }

  void speak11(String okspeak) {
    controller1.speak(okspeak, VoiceControllerOptions(delay: 2));
  }

  // ------- Bluetooth -------
  startScan() {
    setState(() {
      connectionText = "Start Scanning";
    });

    scanSubScription = flutterBlue.scan().listen((scanResult) {
      if (scanResult.device.name == TARGET_DEVICE_NAME) {
        print('DEVICE found');
        stopScan();
        setState(() {
          connectionText = "Found Target Device";
        });

        targetDevice = scanResult.device;
        connectToDevice();
      }
    }, onDone: () => stopScan());
  }

  stopScan() {
    scanSubScription?.cancel();
    scanSubScription = null;
  }

  connectToDevice() async {
    if (targetDevice == null) return;

    setState(() {
      connectionText = "Device Connecting";
    });

    await targetDevice.connect();
    print('DEVICE CONNECTED');
    setState(() {
      connectionText = "Device Connected";
    });

    discoverServices();
  }

  disconnectFromDevice() {
    if (targetDevice == null) return;

    targetDevice.disconnect();

    setState(() {
      connectionText = "Device Disconnected";
    });
  }

  discoverServices() async {
    if (targetDevice == null) return;

    List<BluetoothService> services = await targetDevice.discoverServices();
    services.forEach((service) {
      if (service.uuid.toString() == SERVICE_UUID) {
        service.characteristics.forEach((characteristic) async {
          if (characteristic.uuid.toString() == CHARACTERISTIC_UUID) {
            targetCharacteristic = characteristic;
            await characteristic.setNotifyValue(true);
            characteristic.value.listen((value) {
              print("Listening to Changes: $value");
              if (value[0] == 1) {
                if (micState) {
                  _speechRecognitionAvailable && !_isListening ? start() : null;
                  setState(() {
                    micState = false;
                  });
                } else {
                  setState(() {
                    micState = true;
                  });
                  stop();
                  playsoundTing();
                }
              }
            });
          }
        });
      }
    });
  }

  writeData(String data) {
    if (targetCharacteristic == null) return;

    List<int> bytes = utf8.encode(data);
    targetCharacteristic.write(bytes);
  }

  // ------- Bluetooth -------

  // Future _speak() async {
  //   await flutterTts.setVolume(volume);
  //   await flutterTts.setSpeechRate(rate);
  //   await flutterTts.setPitch(pitch);

  //   if (_newVoiceText != null) {
  //     if (_newVoiceText.isNotEmpty) {
  //       await flutterTts.awaitSpeakCompletion(true);
  //       await flutterTts.speak(_newVoiceText);
  //     }
  //   }
  // }

  // Future _stop() async {
  //   var result = await flutterTts.stop();
  //   if (result == 1) setState(() => ttsState = TtsState.stopped);
  // }

  // Future _pause() async {
  //   var result = await flutterTts.pause();
  //   if (result == 1) setState(() => ttsState = TtsState.paused);
  // }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
    // for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
    //   subscription.cancel();
    // }
  }

  void _onChange(String text) {
    setState(() {
      _newVoiceText = text;
    });
    //speak();
  }

  // Speech end

  void activateSpeechRecognizer() {
    print('_MyAppState.activateSpeechRecognizer... ');
    _speech = new SpeechRecognition();
    _speech.setAvailabilityHandler(onSpeechAvailability);
    _speech.setCurrentLocaleHandler(onCurrentLocale);
    _speech.setRecognitionStartedHandler(onRecognitionStarted);
    _speech.setRecognitionResultHandler(onRecognitionResult);
    _speech.setRecognitionCompleteHandler(onRecognitionComplete);
    // _speech.setErrorHandler(errorHandler);
    _speech
        .activate()
        .then((res) => setState(() => _speechRecognitionAvailable = res));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: Align(
        alignment: Alignment(0.1, 1.6),
        child: AvatarGlow(
          glowColor: Colors.red,
          endRadius: 90.0,
          duration: Duration(milliseconds: 2000),
          repeat: true,
          animate: _isListening,
          showTwoGlows: true,
          repeatPauseDuration: Duration(milliseconds: 100),
          child: FloatingActionButton(
            onPressed: () async {
              if (micState) {
                _speechRecognitionAvailable && !_isListening ? start() : null;
                setState(() {
                  micState = false;
                });
              } else {
                setState(() {
                  micState = true;
                });
                stop();
                playsoundTing();
              }
              //speak11("Ok I work");
            },
            backgroundColor: micColor,
            child: Icon(Icons.mic),
          ),
        ),
      ),
      body: Stack(children: [
        Column(
          children: [
            Expanded(
              flex: 9,
              child: Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: Stack(
                      children: [
                        CameraViewIndoor(depthMapCallback, ocrCallback),
                        AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            child: IndoorBoundingBox(
                              ocrElementIn == null ? [] : ocrElementIn,
                              ocrElementIn == null ? 0 : 200,
                              ocrElementIn == null ? 0 : 200,
                              ocrElementIn == null ? 0 : 500,
                              ocrElementIn == null ? 0 : 500,
                              // Height

                              // Width
                            ),
                          ),
                        ),
                        depthToCV(),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Stack(children: [
                      Container(
                        color: Colors.black,
                        // ),
                        child: Column(
                          children: [
                            Expanded(
                                child: Image(
                              image: AssetImage("assets/indoorLogo.png"),
                            )),
                            Expanded(
                              flex: 4,
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: RotatedBox(
                                  quarterTurns: 0,
                                  child: new Container(
                                    width: 255,
                                    height: 255,
                                    decoration: new BoxDecoration(
                                        image: new DecorationImage(
                                      fit: BoxFit.none,
                                      alignment: FractionalOffset.topLeft,
                                      image: MemoryImage(
                                          Uint8List.fromList(imageData)),
                                    )),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            Expanded(child: Container(color: Colors.black))
          ],
        ),
        Center(
          child: Column(
            children: [
              Expanded(
                flex: 6,
                child: Container(),
              ),
              Expanded(
                flex: 2,
                child: new Container(
                  width: 1334,
                  height: 255,
                  decoration: new BoxDecoration(
                      image: new DecorationImage(
                    fit: BoxFit.fitWidth,
                    alignment: FractionalOffset.bottomCenter,
                    image: AssetImage("assets/belt3.png"),
                  )),
                  child: Row(
                    children: [
                      // SizedBox(
                      //   width: 35,
                      // ),
                      Expanded(
                        child: AvatarGlow(
                          glowColor: Colors.white,
                          endRadius: 50.0,
                          shape: BoxShape.rectangle,
                          duration: Duration(milliseconds: 1000),
                          repeat: true,
                          animate: textBoundingMotor == 1,
                          repeatPauseDuration: Duration(milliseconds: 100),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 5,
                                )),
                            child: Stack(children: [
                              Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                        color: motorColors[0][3] == 1
                                            ? Colors.red
                                            : Colors.white),
                                  ),
                                  Expanded(
                                    child: Container(
                                        color: motorColors[0][2] == 1
                                            ? Colors.red
                                            : Colors.white),
                                  ),
                                  Expanded(
                                    child: Container(
                                        color: motorColors[0][1] == 1
                                            ? Colors.red
                                            : Colors.white),
                                  ),
                                  Expanded(
                                    child: Container(
                                        color: motorColors[0][0] == 1
                                            ? Colors.red
                                            : Colors.white),
                                  ),
                                ],
                              ),
                              Center(
                                child: Text(
                                  '${m1intensity}',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15),
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ),
                      // SizedBox(
                      //   width: 30,
                      // ),
                      Expanded(
                        child: AvatarGlow(
                          glowColor: Colors.white,
                          endRadius: 50.0,
                          shape: BoxShape.rectangle,
                          duration: Duration(milliseconds: 1000),
                          repeat: true,
                          animate: textBoundingMotor == 2,
                          // showTwoGlows: true,
                          repeatPauseDuration: Duration(milliseconds: 100),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 5,
                                )),
                            child: Stack(children: [
                              Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                        color: motorColors[1][3] == 1
                                            ? Colors.yellow
                                            : Colors.white),
                                  ),
                                  Expanded(
                                    child: Container(
                                        color: motorColors[1][2] == 1
                                            ? Colors.yellow
                                            : Colors.white),
                                  ),
                                  Expanded(
                                    child: Container(
                                        color: motorColors[1][1] == 1
                                            ? Colors.yellow
                                            : Colors.white),
                                  ),
                                  Expanded(
                                    child: Container(
                                        color: motorColors[1][0] == 1
                                            ? Colors.yellow
                                            : Colors.white),
                                  ),
                                ],
                              ),
                              Center(
                                child: Text(
                                  '${m2intensity}',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15),
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 210,
                      ),
                      Expanded(
                        child: AvatarGlow(
                          glowColor: Colors.white,
                          endRadius: 50.0,
                          shape: BoxShape.rectangle,
                          duration: Duration(milliseconds: 1000),
                          repeat: true,
                          animate: textBoundingMotor == 3,
                          // showTwoGlows: true,
                          repeatPauseDuration: Duration(milliseconds: 100),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 5,
                                )),
                            width: 50,
                            height: 50,
                            child: Stack(children: [
                              Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                        color: motorColors[2][3] == 1
                                            ? Colors.green
                                            : Colors.white),
                                  ),
                                  Expanded(
                                    child: Container(
                                        color: motorColors[2][2] == 1
                                            ? Colors.green
                                            : Colors.white),
                                  ),
                                  Expanded(
                                    child: Container(
                                        color: motorColors[2][1] == 1
                                            ? Colors.green
                                            : Colors.white),
                                  ),
                                  Expanded(
                                    child: Container(
                                        color: motorColors[2][0] == 1
                                            ? Colors.green
                                            : Colors.white),
                                  ),
                                ],
                              ),
                              Center(
                                child: Text(
                                  '${m3intensity}',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15),
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Expanded(
                        child: AvatarGlow(
                          glowColor: Colors.white,
                          endRadius: 50.0,
                          shape: BoxShape.rectangle,
                          duration: Duration(milliseconds: 1000),
                          repeat: true,
                          animate: textBoundingMotor == 4,
                          // showTwoGlows: true,
                          repeatPauseDuration: Duration(milliseconds: 100),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 5,
                                )),
                            width: 50,
                            height: 50,
                            child: Stack(children: [
                              Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                        color: motorColors[3][3] == 1
                                            ? Colors.blue
                                            : Colors.white),
                                  ),
                                  Expanded(
                                    child: Container(
                                        color: motorColors[3][2] == 1
                                            ? Colors.blue
                                            : Colors.white),
                                  ),
                                  Expanded(
                                    child: Container(
                                        color: motorColors[3][1] == 1
                                            ? Colors.blue
                                            : Colors.white),
                                  ),
                                  Expanded(
                                    child: Container(
                                        color: motorColors[3][0] == 1
                                            ? Colors.blue
                                            : Colors.white),
                                  ),
                                ],
                              ),
                              Center(
                                child: Text(
                                  '${m4intensity}',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15),
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      ]),
    );
  }

  List<CheckedPopupMenuItem<Language>> get _buildLanguagesWidgets => languages
      .map((l) => new CheckedPopupMenuItem<Language>(
            value: l,
            checked: selectedLang == l,
            child: new Text(l.name),
          ))
      .toList();

  void _selectLangHandler(Language lang) {
    setState(() => selectedLang = lang);
  }

  void playsoundTing() {
    final player = AudioCache();
    player.play("Ting.wav");
  }

  void start() {
    // playsoundTing();
    setState(() {
      micColor = Colors.red;
      objSpeakState = false;
    });
    _speech
        .listen(locale: "en_US")
        .then((result) => print('_MyAppState.start => result $result'));
  }

  void cancel() =>
      _speech.cancel().then((result) => setState(() => _isListening = result));

  void stop() {
    _speech.stop().then((result) {
      setState(() => _isListening = result);
    });
    setState(() {
      micColor = Colors.teal;
      objSpeakState = true;
    });
  }

  void onSpeechAvailability(bool result) =>
      setState(() => _speechRecognitionAvailable = result);

  void onCurrentLocale(String locale) {
    print('_MyAppState.onCurrentLocale... $locale');
    setState(
        //() => selectedLang = languages.firstWhere((l) => l.code == locale));
        () => selectedLang = languages[0]);
  }

  void onRecognitionStarted() => setState(() => _isListening = true);

  void onRecognitionResult(String text) {
    setState(() {
      transcription = text;
    });
    print("Recog Raw: ${text}");
    dest = Utils.scanText(text);
    print("Recog Processed: ${dest}");
  }

  void onRecognitionComplete() => setState(() => _isListening = false);

  void errorHandler() => activateSpeechRecognizer();

  Widget depthToCV() {
    int motorNo = 0;
    String returnedString = sendToCVIndoor(DepthCV);
    var splitted = returnedString.split(";");
    print("ret str for indoor : $returnedString");
    List<int> motorIntensities = [];
    print("dodge this: ${imgSize}");
    for (var item in splitted) {
      var secondSplit = item.split(":");
      // print(secondSplit.isNotEmpty);
      if (item.isNotEmpty) {
        var intensity = secondSplit[0];

        motorIntensities.add(int.parse(intensity));
      }
    }

    if (ocrElementIn.isNotEmpty) {
      if (dest != null) {
        List<int> sendCoordText = [];
        for (String item in dest.split(" ")) {
          print("desti is: $item");
          for (TextBlock ocrBlock in ocrElementIn) {
            for (TextLine line in ocrBlock.lines) {
              // Same getters as TextBlock
              print("thid : ${line.text}");
              for (TextElement element in line.elements) {
                // Same getters as TextBlock
                //_elements.add(element);
                var jojo = element.text;
                print("element ocr: ${jojo.toLowerCase()}");
                if (element.text.toLowerCase() == "nike") {
                  //if (element.text.toLowerCase() == "macbook") {
                  print("jojo is dead inside");
                  indoorCondCount++;
                  int x1 = (ocrBlock.cornerPoints[0].dx).round() < 0
                      ? 0
                      : (ocrBlock.cornerPoints[0].dx).round();
                  x1 = x1 > 375 ? 375 : x1;

                  sendCoordText.add((x1 * (255 / 375)).round());
                  //sendCoordList.add((item.topLeft.dx * 255 / 375).round());
                  int y1 = (ocrBlock.cornerPoints[0].dy).round() < 0
                      ? 0
                      : (ocrBlock.cornerPoints[0].dy).round();
                  y1 = y1 > 288 ? 288 : y1;

                  sendCoordText.add((y1 * (255 / 288)).round());

                  int x2 = (ocrBlock.cornerPoints[2].dx).round() > 288
                      ? 288
                      : (ocrBlock.cornerPoints[2].dx).round();
                  x2 = (x2 * 255 / 288).round();
                  int width = (x2 - x1).abs();

                  sendCoordText.add((width).round());

                  int y2 = (ocrBlock.cornerPoints[2].dy).round() > 288
                      ? 288
                      : (ocrBlock.cornerPoints[2].dy).round();

                  int height = (y2 - y1).abs();
                  print("Indoor:$indoorCondCount");
                  if (indoorCondCount == 1) {
                    // speak11("Taking you to ");
                    playNav();
                    print(" navjojo is alive");
                  }
                  sendCoordText.add((height * (255 / 288)).round());
                  List<int> motorInt = [];
                  List<int> delays = [];
                  String returnedString =
                      sendToCV(DepthCV, sendCoordText, [30]);
                  print("Ret CV:$returnedString");
                  var splitted = returnedString.split(";");
                  int countThis = 1;
                  for (var item in splitted) {
                    var secondSplit = item.split(":");
                    // print(secondSplit.isNotEmpty);
                    if (item.isNotEmpty) {
                      int intensity = int.parse(secondSplit[0]);
                      motorInt.add(intensity);

                      var Class1 = item.split(":")[1];
                      if (Class1 == "30") {
                        print("text boxis in quad $countThis");
                        setState(() {
                          textBoundingMotor = countThis;
                          delays.add(50);
                        });
                      } else {
                        delays.add(0);
                      }
                      print('Splitted is: ');
                      countThis++;
                    }
                    // var toEsp =
                    //     "${motorIntensities[0]}:${delays[0]}&${motorIntensities[1]}:${delays[1]}&${motorIntensities[2]}:${delays[2]}&${motorIntensities[3]}:${delays[3]}";
                    // writeData(toEsp);
                  }
                }
              }
            }
          }
        }
      }

      //print("desti is 1 : ${ocrElementIn[0].text}");
    }
    var tempmax = 0;
    for (int i = 0; i < 4; i++) {
      if (motorIntensities[i] > tempmax) {
        tempmax = motorIntensities[i];
      }
    }
    motorIntensities[0] = motorIntensities[0] > 250
        ? (((motorIntensities[0] - 250) * 100) / (tempmax - 150)).round()
        : 0;
    motorIntensities[1] = motorIntensities[1] > 250
        ? (((motorIntensities[1] - 250) * 100) / (tempmax - 150)).round()
        : 0;
    motorIntensities[2] = motorIntensities[2] > 250
        ? (((motorIntensities[2] - 250) * 100) / (tempmax - 150)).round()
        : 0;
    motorIntensities[3] = motorIntensities[3] > 250
        ? (((motorIntensities[3] - 250) * 100) / (tempmax - 150)).round()
        : 0;
    setState(() {
      //imgSize = globals.imageSizeIn;
      //textBoundingMotor = motorNo;
      m1intensity = motorIntensities[0];
      m2intensity = motorIntensities[1];
      m3intensity = motorIntensities[2];
      m4intensity = motorIntensities[3];

      motorColors[0] = colorSetter(m1intensity);
      print("Color is:${motorColors[0]}");
      motorColors[1] = colorSetter(m2intensity);
      motorColors[2] = colorSetter(m3intensity);
      motorColors[3] = colorSetter(m4intensity);
    });
    //print("text quad is : $textBoundingMotor");
    //return Container();
    // if (ocrElementIn.isEmpty) {
    return Container();
  }

  /// Returns Stack of bounding boxes
  Widget boundingBoxes(List<Recognition> results) {
    if (results == null) {
      return Container();
    }
    List<int> sendCoordList = [];
    List<int> encodedLabelList;
    List<String> sendLabelList = [];
    if (results.length > 0) {
      // print("Results:${results[0].location.topL
      // eft.dy}");
      var k1 = [];
      //print("okok ; ${results[0].label}");
      for (var item in coordinateList) {
        int x1 = (item.topLeft.dx).round() < 0 ? 0 : (item.topLeft.dx).round();
        x1 = x1 > 375 ? 375 : x1;

        sendCoordList.add((x1 * (255 / 375)).round());
        //sendCoordList.add((item.topLeft.dx * 255 / 375).round());
        int y1 = (item.topLeft.dy).round() < 0 ? 0 : (item.topLeft.dy).round();
        y1 = y1 > 288 ? 288 : y1;

        sendCoordList.add((y1 * (255 / 288)).round());

        int x2 =
            x1 + (item.width).round() > 375 ? 375 : x1 + (item.width).round();

        int width = (x2 - x1).abs();

        sendCoordList.add((width * (255 / 375)).round());

        int y2 =
            y1 + (item.height).round() > 288 ? 288 : y1 + (item.height).round();

        int height = (y2 - y1).abs();

        sendCoordList.add((height * (255 / 288)).round());

        // k1.add((item.location.topLeft.dx).round());
        // k1.add((item.location.topLeft.dy).round());
        // k1.add((item.location.width).round());
        // k1.add((item.location.height).round());
        // k1.add(item.label);
      }
      for (var labe in results) {
        sendLabelList.add(labe.label);
      }

      // print("Result List is: ${sendCoordList}");
      // print("K1 is: ${k1}");

      encodedLabelList = [];

      int traffic_counter = 0;
      List<int> Traffic_Coords = [];
      for (var label in sendLabelList) {
        print("if keys ${globals.impClasses.containsKey(label)}");
        for (var item in globals.impClasses.keys) {
          if (item == label) {
            encodedLabelList.add(globals.impClasses[label]);
          }
        }

        if (label == "traffic light") {
          // print("I'm in 1:${label}");

          for (int i = 0; i < 4; i++) {
            Traffic_Coords.add(sendCoordList[(4 * traffic_counter) + i]);
          }

          var OP_String = sendToTraffic(OGImageList, Traffic_Coords);
          print("Color Is: ${OP_String}");
        }

        traffic_counter += 1;
      }

      // print("Traffic Coords:${Traffic_Coords}");

      // print("Label List is: ${encodedLabelList}");

      String returnedString =
          sendToCV(DepthCV, sendCoordList, encodedLabelList);

      // String signalNumber =

      List<int> motorIntensities = [];
      List<int> encodedClasses = [];
      int ik = 1;
      var splitted = returnedString.split(";");
      print("ret str : $returnedString");
      for (var item in splitted) {
        var secondSplit = item.split(":");
        // print(secondSplit.isNotEmpty);
        if (item.isNotEmpty) {
          var intensity = secondSplit[0];
          var Class1 = item.split(":")[1];
          print('Splitted is:${Class1}');
          motorIntensities.add(int.parse(intensity));

          var currentTime = DateTime.now();
          int secondDiff = ((currentTime.millisecondsSinceEpoch -
                      startTime.millisecondsSinceEpoch) /
                  1000)
              .round();
          if (objSpeakState) {
            if (secondDiff % 2 == 0) {
              if (int.parse(item.split(":")[1]) > 0) {
                playClass(int.parse(Class1));
              }
            }
          }

          encodedClasses.add(int.parse(Class1));
          ik++;
        }
      }

      //globals.classToSpeak = encodedClasses
      setState(() {
        m1intensity = motorIntensities[0];
        m2intensity = motorIntensities[1];
        m3intensity = motorIntensities[2];
        m4intensity = motorIntensities[3];

        motorColors[0] = colorSetter(m1intensity);
        print("Color is:${motorColors[0]}");
        motorColors[1] = colorSetter(m2intensity);
        motorColors[2] = colorSetter(m3intensity);
        motorColors[3] = colorSetter(m4intensity);
      });
    }

    return Stack(
      children: results
          .map((e) => BoxWidget(
                result: e,
              ))
          .toList(),
    );
  }

  void depthMapCallback(DepthMap depthMaps) {
    setState(() {
      this.depthMap = depthMaps;
      imageData = depthMaps.depthMap;
      DepthCV = depthMaps.depthMapCV;
      OGImageList = depthMaps.OGImage;
    });
  }

  void ocrCallback(List<TextBlock> ocrElement) {
    //print("jojojojo is : ${ocrElement[1]}");
    setState(() {
      ocrElementIn = ocrElement;
    });
  }

  static const BOTTOM_SHEET_RADIUS = Radius.circular(24.0);
  static const BORDER_RADIUS_BOTTOM_SHEET = BorderRadius.only(
      topLeft: BOTTOM_SHEET_RADIUS, topRight: BOTTOM_SHEET_RADIUS);
}

// class TextDetectorPainter extends CustomPainter {
//   TextDetectorPainter(this.absoluteImageSize, this.elements);

//   final Size absoluteImageSize;
//   final List<TextElement> elements;

//   @override
//   void paint(Canvas canvas, Size size) {
//     final double scaleX = size.width / absoluteImageSize.width;
//     final double scaleY = size.height / absoluteImageSize.height;

//     Rect scaleRect(TextContainer container) {
//       return Rect.fromLTRB(
//         container.boundingBox.left * scaleX,
//         container.boundingBox.top * scaleY,
//         container.boundingBox.right * scaleX,
//         container.boundingBox.bottom * scaleY,
//       );
//     }

//     final Paint paint = Paint()
//       ..style = PaintingStyle.stroke
//       ..color = Colors.red
//       ..strokeWidth = 2.0;

//     for (TextElement element in elements) {
//       canvas.drawRect(scaleRect(element), paint);
//     }
//   }

//   @override
//   bool shouldRepaint(TextDetectorPainter oldDelegate) {
//     return true;
//   }
// }
/// Row for one Stats field
