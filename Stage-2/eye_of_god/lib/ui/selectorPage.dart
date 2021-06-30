import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:eye_of_god/ui/Indoor/indoor.dart';
import 'package:eye_of_god/ui/Outdoor/outdoor.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';
import 'dart:convert';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:audioplayers/audioplayers.dart';

// Utils Clone
class Command {
  // static final all = [email, browser1, browser2];

  static const place = 'to';
  static const start = 'start';
  static const indoor = 'indoor';
  // static const browser2 = 'go to';
}

class Utils {
  static String scanText(String rawText) {
    final text = rawText.toLowerCase();
    print(text);
    String command;
    // if (text.contains(Command.place)) {
    //   loc = _getTextAfterCommand(text: text, command: Command.place);
    // }

    if (text.contains(Command.start)) {
      command = _getTextAfterCommand(text: text, command: Command.start);
      command = command.split(" ")[0];
      // print("Final is:$finalret");
    }

    return command;
  }

  static bool scanText1(String rawText) {
    final text = rawText.toLowerCase();
    print(text);
    String loc;
    if (text.contains(Command.indoor)) {
      return true;
    }
    return false;
  }

  static String _getTextAfterCommand({
    @required String text,
    @required String command,
  }) {
    final indexCommand = text.indexOf(command);
    final indexAfter = indexCommand + command.length;

    if (indexCommand == -1) {
      return null;
    } else {
      return text.substring(indexAfter).trim();
    }
  }
}
// Utils Clone

int blueCounter = 0;
FlutterBlue flutterBlue;
bool micState = true;

class Language {
  final String name;
  final String code;

  const Language(this.name, this.code);
}

const languages = const [
  // const Language('Francais', 'fr_FR'),
  const Language('English', 'en_US '),
];

Language selectedLang = languages.first;

class SelectorPage extends StatefulWidget {
  const SelectorPage({key}) : super(key: key);

  @override
  _SelectorPageState createState() => _SelectorPageState();
}

class _SelectorPageState extends State<SelectorPage> {
// Page Selector
  int pageSelector = 0;

  // ---Blue Vars---
  final String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  final String TARGET_DEVICE_NAME = "ESP32";

  FlutterBlue flutterBlue = FlutterBlue.instance;
  StreamSubscription<ScanResult> scanSubScription;

  BluetoothDevice targetDevice;
  BluetoothCharacteristic targetCharacteristic;
  Color micColor = Colors.cyanAccent;

  String connectionText = "";
  // ---Blue Vars---

  bool _speechRecognitionAvailable = false;
  bool _isListening = false;
  SpeechRecognition _speech;
  bool objSpeakState = true;
  void playNav() {
    final player = AudioCache();
    player.play("welcome.wav");
  }

  @override
  void initState() {
    startScan();
    activateSpeechRecognizer();
    playNav();
    super.initState();
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
      print(connectionText);
    });
  }

  blueCallTest() {
    return true;
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

// Audio
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
      var transcription = text;
      print("Recog Raw: ${transcription}");
      String dest = Utils.scanText(text);
      print("Recog Processed: ${dest}");
      if (dest == "indoor") {
        stop();
        print("Indoor");
        disconnectFromDevice();

        pageSelector = 2;
      } else if (dest == "outdoor") {
        stop();
        print("Outdoor");
        // stopScan();
        disconnectFromDevice();
        pageSelector = 1;
      }
    });
  }

  void onRecognitionComplete() => setState(() => _isListening = false);

  void errorHandler() => activateSpeechRecognizer();

  void start() {
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

  void playsoundTing() {
    final player = AudioCache();
    player.play("Ting.wav");
  }
// Audio

  @override
  Widget build(BuildContext context) {
    return pageSelector == 1
        ? HomeView()
        : pageSelector == 2
            ? Indoor()
            : Scaffold(
                body: Stack(children: [
                  Align(
                      child: Center(
                          child: Image(
                              image: AssetImage("assets/Eye_of_god.png")))),
                  Align(
                    alignment: Alignment(0.15, -0.95),
                    child: Container(
                      width: 100,
                      height: 100,
                      // color: Colors.white,
                      child: Stack(
                        children: [
                          AvatarGlow(
                            glowColor: micColor,
                            endRadius: 190.0,
                            duration: Duration(milliseconds: 2000),
                            repeat: true,
                            animate: _isListening || true,
                            showTwoGlows: true,
                            repeatPauseDuration: Duration(milliseconds: 100),
                            child: Icon(
                              Icons.remove_red_eye_outlined,
                              color: micColor,
                              size: 100.0,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (micState) {
                                _speechRecognitionAvailable && !_isListening
                                    ? start()
                                    : null;
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
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ]),
                backgroundColor: Colors.black,
              );
  }
}
