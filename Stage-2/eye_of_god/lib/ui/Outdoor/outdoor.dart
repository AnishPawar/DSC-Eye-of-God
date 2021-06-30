import 'package:flutter/cupertino.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:flutter/material.dart';
import 'package:eye_of_god/OnDevice_ML/tflite/recognition.dart';
import 'package:eye_of_god/OnDevice_ML/tflite/stats.dart';
import 'package:eye_of_god/OnDevice_ML/depthModel/depthMapRes.dart';
import 'package:eye_of_god/Speech/utils.dart';
import 'package:eye_of_god/ui/box_widget.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'camera_view.dart';
import 'dart:typed_data';
import 'dart:io';
import 'dart:isolate';
import 'package:image_crop/image_crop.dart';
import 'package:eye_of_god/OpenCV_Backend/native_opencv.dart';
import 'package:eye_of_god/Globals/globals.dart' as globals;
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:avatar_glow/avatar_glow.dart';

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
import 'dart:convert';

double latitude = 19.079790;
double longitude = 72.904050;
// enum TtsState { playing, stopped, paused, continued }
var coordinateList;
final cropKey = GlobalKey<CropState>();
List<int> DepthCV = [];
List<int> OGImageList = [];

int blueCounter = 0;
FlutterBlue flutterBlue;

int m1intensity = 0;
bool micState = true;
int m2intensity = 0;
int m3intensity = 0;
int m4intensity = 0;
bool objSpeakState = true;
bool clashState = false;
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

class HomeView extends StatefulWidget {
  static String id = 'home_view';
  // final List<BluetoothService> BlueService;
  //final Function discoverServices;

  // const HomeView(this.BlueService);
  @override
  _HomeViewState createState() => _HomeViewState();
}

// VoiceController controller;
VoiceController controller1;
enum TtsState { playing, stopped, paused, continued }

class _HomeViewState extends State<HomeView> {
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

  Stats stats;

  DepthMap depthMap;

  List<int> imageData = [];
  Uint8List list11;

  // List<int> colorSetter(int intensity) {
  //   List<int> tempColors = [0, 0, 0, 0];
  //   if (intensity <= 63.75) {
  //     tempColors = [1, 0, 0, 0];
  //   } else if ((intensity > 63.75) && (intensity <= 127.5)) {
  //     tempColors = [1, 1, 0, 0];
  //   } else if ((intensity > 127.5) && (intensity <= 191.25)) {
  //     tempColors = [1, 1, 1, 0];
  //   } else if ((intensity > 191.25)) {
  //     tempColors = [1, 1, 1, 1];
  //   }
  //   return tempColors;
  // }
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

  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController newGoogleMapController;
  Position currentPosition;
  LatLng destinationPos;
  List<LatLng> polylineCoordinates = [];
  List<Prediction> destinationPredictionList = [];
  LatLng pos;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  var geolocator = Geolocator();
  location.LocationData currentLocationld;
  var location1 = new location.Location();
  LatLng pinPosition;
  var thisDetails;
  String nav_command;
  String direction;
  double upd_start_lat;
  double upd_start_long;
  double upd_end_lat;
  double upd_end_long;
  double next_end_lat;
  double next_end_long;
  // FlutterTts flutterTts;
  // double volume = 0.5;
  // double pitch = 1.0;
  // double rate = 1.0;
  TtsState ttsState = TtsState.stopped;
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

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;

  Color micColor = Colors.teal;
  List<bool> arrowPulse = [false, false];
  // List<_Message> messages = List<_Message>();
  // // String _messageBuffer = '';
  List<double> _userAccelerometerValues;
  List<double> _gyroscopeValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  List<List<String>> gyro_global = List<List<String>>.filled(5, []);
  int count_global = 0;

  int i = 0;
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
  AnimationController _animationController;
  Animation _animation;
  // Pulse List

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();

    // flutterBlue = FlutterBlue.instance;
    try {
      startScan();
    } catch (e) {
      print("Not Scanning Because$e");
    }

    location11.getLocation();
    location11.onLocationChanged.listen((location.LocationData cLoc) {
      currentLocationld = cLoc;
      print("Updated is $currentLocationld");
      updatePinOnMap();
    });
    activateSpeechRecognizer();
    // var startTime = time
    // controller = FlutterTextToSpeech.instance.voiceController();
    // controller.init().then((_) {
    //   print("init done");
    // });
    controller1 = FlutterTextToSpeech.instance.voiceController();
    controller1.init().then((_) {
      print("init done");
    });
    // try {
    //   _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
    //     setState(() {
    //       _gyroscopeValues = <double>[event.x, event.y, event.z];
    //     });
    //   }));
    // } catch (e) {
    //   print("Error is now:$e");
    // }

    initTts();
    updatePinOnMap();
    initAsync();
  }

  void initAsync() async {
    speechIso = SpeechIsolateUtils();
    await speechIso.start();
  }

  void speak11(String okspeak) {
    controller1.speak(okspeak, VoiceControllerOptions(delay: 2));
    setState(() {
      clashState = true;
    });
  }

  Future<void> speakSomething(IsolateSpeechData speech) async {
    ReceivePort responsePort = ReceivePort();
    // print(depthIsolateUtils.sendPort);
    speechIso.sendPort.send(speech..responsePort = responsePort.sendPort);
    var results = await responsePort.first;
    print("Response is:$results");
    return results;
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
              print("Listening to Changes Outdoor: $value");
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

  initTts() async {
    flutterTts = FlutterTts();
    await flutterTts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback,
        [IosTextToSpeechAudioCategoryOptions.defaultToSpeaker]);
    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    if (isIOS) {
      flutterTts.setPauseHandler(() {
        setState(() {
          print("Paused");
          ttsState = TtsState.paused;
        });
      });

      flutterTts.setContinueHandler(() {
        setState(() {
          print("Continued");
          ttsState = TtsState.continued;
        });
      });
    }

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future _speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (_newVoiceText != null) {
      if (_newVoiceText.isNotEmpty) {
        await flutterTts.awaitSpeakCompletion(true);
        await flutterTts.speak(_newVoiceText);
      }
    }
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
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

  void updatePinOnMap() async {
    try {
      CameraPosition cPosition = CameraPosition(
        zoom: 16,
        target: LatLng(currentLocationld.latitude, currentLocationld.longitude),
      );
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    } catch (e) {
      print("Stuck:${e}");
    }

    print("outside set state of coordi");
    // straight_path();
    setState(() {
      print("in set state of coordi");
      pinPosition =
          LatLng(currentLocationld.latitude, currentLocationld.longitude);
      check_voice(pinPosition.latitude, pinPosition.longitude);
      path_match(pinPosition.latitude, pinPosition.longitude);
    });
  }

  Future<void> getDirection() async {
    print("in Get Direction");
    var pickup = pos;
    var destination = destinationPos;
    print("Latitude = $pos");
    print("Latitude = $destinationPos");
    thisDetails = await Directions.getDirectionDetails(pickup, destination);
    print("thisdetailstext = " + thisDetails.distanceText);
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =
        polylinePoints.decodePolyline(thisDetails.encodedPoints);
    polylineCoordinates.clear();
    if (results.isNotEmpty) {
      results.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _polylines.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('polyid'),
        color: Color.fromARGB(255, 95, 109, 237),
        points: polylineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      _polylines.add(polyline);
    });

    LatLngBounds bounds;

    if (pickup.latitude > destination.latitude &&
        pickup.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: pickup);
    } else if (pickup.longitude > destination.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(pickup.latitude, destination.longitude),
          northeast: LatLng(destination.latitude, pickup.longitude));
    } else if (pickup.latitude > destination.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destination.latitude, pickup.longitude),
          northeast: LatLng(pickup.latitude, destination.longitude));
    } else {
      bounds = LatLngBounds(southwest: pickup, northeast: destination);
    }

    newGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destination,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    Marker sourceMarker = Marker(
      markerId: MarkerId('source'),
      position: pos,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );

    setState(
      () {
        _markers.add(destinationMarker);
        _markers.add(sourceMarker);
        i = 0;
      },
    );
  }

  double angleBetweenPoints(LatLng latlongA, LatLng latlongB, LatLng latlongC) {
    double headingBA = calculateBearing(latlongB, latlongA);
    double headingBC = calculateBearing(latlongB, latlongC);

    return angleBetweenHeadings(headingBA, headingBC);
  }

  double angleBetweenHeadings(double headingBA, double headingBC) {
    double angle = ((headingBA - headingBC) + 360) % 360;

    if (angle > 180) {
      setState(() {
        arrowPulse[0] = true;
      });
      return 360 - angle;
    } else {
      setState(() {
        arrowPulse[1] = true;
      });
      return angle;
    }
  }

  double calculateBearing(LatLng latlong1, LatLng latlong2) {
    double lat1 = DegtoRad(latlong1.latitude);
    double lon1 = latlong1.longitude;
    double lat2 = DegtoRad(latlong2.latitude);
    double lon2 = latlong2.longitude;
    double dLon = DegtoRad(lon2 - lon1);
    double y = math.sin(dLon) * math.cos(lat2);
    double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    double brng = (RadtoDeg(math.atan2(y, x)) + 360) % 360;
    return brng;
  }

  double DegtoRad(double x) {
    return x * math.pi / 180;
  }

  double RadtoDeg(double x) {
    return x * 180 / math.pi;
  }

  Function eq = const ListEquality().equals;

  void straight_path() {
    List<String> gyroscope;
    print("Abs value: " + _gyroscopeValues[0].abs().toString());
    if ((_gyroscopeValues[0]).abs().toStringAsFixed(1) == "0.0" &&
        (_gyroscopeValues[1]).abs().toStringAsFixed(1) == "0.0" &&
        (_gyroscopeValues[2]).abs().toStringAsFixed(1) == "0.0") {
      print("inside abs");
      gyroscope = ["0.0", "0.0", "0.0"];
    } else {
      gyroscope =
          _gyroscopeValues.map((double v) => v.toStringAsFixed(1)).toList();
    }
    final List<String> userAccelerometer = _userAccelerometerValues
        .map((double v) => v.toStringAsFixed(1))
        .toList();
    print("Gyro: $gyroscope, Acc: $userAccelerometer");
    print("gyro" + _gyroscopeValues[0].toString());
    if (count_global == 5) {
      print("remove gyro");
      for (int i = 0; i < 4; i++) {
        print("inside for");
        gyro_global[i] = gyro_global[i + 1];
        print("after gyro_glo");
      }
      gyro_global[4] = gyroscope;
      print("Gyro list:" + gyro_global.toString());
    } else {
      print("add gyro");
      gyro_global[count_global] = gyroscope;
      count_global++;
      print("Gyro list:" + gyro_global.toString());
    }

    if (eq(gyro_global[0], ["0.0", "0.0", "0.0"]) &&
            eq(gyro_global[1], ["0.0", "0.0", "0.0"]) &&
            eq(gyro_global[3], ["0.0", "0.0", "0.0"]) &&
            eq(gyro_global[4], ["0.0", "0.0", "0.0"]) &&
            !eq(gyro_global[2], ["0.0", "0.0", "0.0"])
        // !eq(userAccelerometer, ["0.0", "0.0", "0.0"])
        ) {
      if (double.parse(gyro_global[2][0]) < 0.0) {
        // var SpeakInt = SpeakThis();
        // SpeakInt.initTts();
        String inst5 = "You are not walking on a Straight Path. Turn Left";
        // SpeakInt.speak_tts(inst5);
        print("Inst5 = " + inst5);
      }
      if (double.parse(gyro_global[2][0]) > 0) {
        // var SpeakInt = SpeakThis();
        // SpeakInt.initTts();
        String inst5 = "You are not walking on a Straight Path. Turn Right";
        // SpeakInt.speak_tts(inst5);
        print("Inst5 = " + inst5);
      }
    }
  }

  void path_match(double cur_lat, double cur_lng) {
    String inst =
        "You are not on the correct route to your destination. Please turn around";
    bool lat_check =
        pathMatching(pos.latitude, destinationPos.latitude, cur_lat);
    bool long_check =
        pathMatching(pos.longitude, destinationPos.longitude, cur_lng);
    if (lat_check && long_check) {
      print("On path");
      setState(() {
        arrowPulse = [false, false];
      });
    } else {
      LatLng latlongA = LatLng(cur_lat, cur_lng);
      LatLng latlongB = LatLng(upd_end_lat, upd_end_long);
      LatLng latlongC = LatLng(next_end_lat, next_end_long);
      double corr_angle = angleBetweenPoints(latlongA, latlongB, latlongC);
      double angle = double.parse((corr_angle).toStringAsFixed(2));
      String inst2 = "Turn by " + angle.toString() + " degrees ";
    }
    // straight_path();
  }

  void check_voice(double cur_lat, double cur_lng) {
    print("inside check voice");
    while (i < thisDetails.steps.length) {
      upd_end_lat = thisDetails.steps[i]['end_location']['lat'];
      upd_end_long = thisDetails.steps[i]['end_location']['lng'];
      upd_start_lat = thisDetails.steps[i]['start_location']['lat'];
      upd_start_long = thisDetails.steps[i]['start_location']['lng'];
      next_end_lat = thisDetails.steps[i + 1]['end_location']['lat'];
      next_end_long = thisDetails.steps[i + 1]['end_location']['lng'];
      nav_command = thisDetails.steps[i]['html_instructions'];
      direction = thisDetails.steps[i]['maneuver'];
      print("inside  while of check voice");
      if (mid(upd_start_lat, upd_start_long, upd_end_lat, upd_end_long, cur_lat,
          cur_lng)) {
        print("inside if of check voice");
        _newVoiceText = updateCoordi(nav_command);
        // _onChange(speech);
        if (direction != null) {
          LatLng latlongA = new LatLng(upd_start_lat, upd_start_long);
          LatLng latlongB = new LatLng(upd_end_lat, upd_end_long);
          LatLng latlongC = new LatLng(next_end_lat, next_end_long);
          print("After LatLng: ");
          double corr_angle = angleBetweenPoints(latlongA, latlongB, latlongC);
          print("After corr_angle");
          double angle = double.parse((corr_angle).toStringAsFixed(2));
          String inst3 = "Turn by " + angle.toString() + " degrees ";
          print("After inst3 string");
          // var SpeakInt = SpeakThis();
          // SpeakInt.initTts();
          //SpeakInt.speak_tts(inst3);
          print("Inst3 = " + inst3);
        }
        i++;
        return;
      }
    }
  }

  Future<void> setupPositionLocator() async {
    print("Current is:");

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print(position.latitude);
      currentPosition = position;
      pos = LatLng(position.latitude, position.longitude);
      CameraPosition cp = new CameraPosition(target: pos, zoom: 14);
      newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cp));
      String address = await Directions.findCordinateAddress(position, context);
      print("Address:" + address);
      print("setuppos = $pos");
      print("setuppos = $destinationPos");
    } catch (e) {
      print("Error is:$e");
    }

    print("Current is:11");
  }

  Future<void> searchPlace(String placeName) async {
    print("in Search Place");
    if (placeName.length > 1) {
      String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=AIzaSyA7Dfm5_owPuczra0Ey8TsE92PDf1-RC8s&sessiontoken=1234567890&components=country:in';
      var response = await Directions.getRequest(url);

      if (response == 'failed') {
        return;
      }

      if (response['status'] == 'OK') {
        var predictionJson = response['predictions'];
        var thisList = (predictionJson as List)
            .map((e) => Prediction.fromJson(e))
            .toList();
        var addresses = await Geocoder.local.findAddressesFromQuery(placeName);
        var first = addresses.first;
        var coord = first.coordinates.toString().replaceAll("{", " ");
        coord = coord.replaceAll("}", " ");
        var fcord = coord.split(",");

        setState(() {
          destinationPredictionList = thisList;

          destinationPos =
              LatLng(double.parse(fcord[0]), double.parse(fcord[1]));
          print("search place = $pos");
          print("search place = $destinationPos");
        });
      }
    }
    getDirection();
  }

  String updateCoordi(String nav_command) {
    print("jojo is fine");

    var retstring = "";
    HtmlTags.removeTag(
        htmlString: nav_command,
        callback: (string) {
          // retstring = string;
          speak11(string);
          // setState(() {
          //   _newVoiceText = string;
          // });
          // _speak();
        });
    print("VOice is:$retstring");
    setState(() {
      clashState = false;
    });
    return retstring;

    //SpeakInt.speak_tts(retstring);
    // SpeakThis()._onChange(retstring);
    // SpeakThis()._speak();
  }

  var location11 = new location.Location();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: Align(
        alignment: Alignment(0.09, 1.6),
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
                        CameraView(
                            resultsCallback, statsCallback, depthMapCallback),
                        RotatedBox(
                            quarterTurns: 0, child: boundingBoxes(results)),
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
                              flex: 1,
                              child: Stack(
                                children: [
                                  GoogleMap(
                                    mapType: MapType.normal,
                                    initialCameraPosition: CameraPosition(
                                      target: LatLng(latitude, longitude),
                                      zoom: 14.4746,
                                    ),
                                    myLocationButtonEnabled: false,
                                    myLocationEnabled: true,
                                    zoomGesturesEnabled: true,
                                    // zoomControlsEnabled: true,
                                    polylines: _polylines,
                                    markers: _markers,
                                    circles: _circles,
                                    onMapCreated:
                                        (GoogleMapController controller) async {
                                      _controller.complete(controller);
                                      newGoogleMapController = controller;
                                      setupPositionLocator();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
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
                      SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: AvatarGlow(
                          glowColor: Colors.white,
                          endRadius: 50.0,
                          shape: BoxShape.rectangle,
                          duration: Duration(milliseconds: 1000),
                          repeat: true,
                          animate: pulseList[0] != 0,
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
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: AvatarGlow(
                          glowColor: Colors.white,
                          endRadius: 50.0,
                          shape: BoxShape.rectangle,
                          duration: Duration(milliseconds: 1000),
                          repeat: true,
                          animate: pulseList[1] != 0,
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
                        width: 240,
                      ),
                      Expanded(
                        child: AvatarGlow(
                          glowColor: Colors.white,
                          endRadius: 50.0,
                          shape: BoxShape.rectangle,
                          duration: Duration(milliseconds: 1000),
                          repeat: true,
                          animate: pulseList[2] != 0,
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
                        width: 10,
                      ),
                      Expanded(
                        child: AvatarGlow(
                          glowColor: Colors.white,
                          endRadius: 50.0,
                          shape: BoxShape.rectangle,
                          duration: Duration(milliseconds: 1000),
                          repeat: true,
                          animate: pulseList[3] != 0,
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
        ),
        Align(
            alignment: Alignment(0.25, 0.95),
            child: AvatarGlow(
              glowColor: Colors.white,
              endRadius: 20,
              duration: Duration(milliseconds: 250),
              repeat: true,
              animate: arrowPulse[0],
              showTwoGlows: true,
              // repeatPauseDuration: Duration(milliseconds: 100),
              child: Container(
                  child: Icon(
                Icons.arrow_forward_rounded,
                color: Colors.orange,
                size: 30,
              )),
            )),
        Align(
            alignment: Alignment(-0.2, 0.95),
            child: AvatarGlow(
              glowColor: Colors.white,
              endRadius: 20,
              duration: Duration(milliseconds: 250),
              repeat: true,
              animate: arrowPulse[0],
              showTwoGlows: true,
              // repeatPauseDuration: Duration(milliseconds: 100),
              child: Container(
                  child: Icon(
                Icons.arrow_back_rounded,
                color: Colors.orange,
                size: 30,
              )),
            ))
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
    searchPlace(dest);
  }

  void onRecognitionComplete() => setState(() => _isListening = false);

  void errorHandler() => activateSpeechRecognizer();

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
              if ((int.parse(item.split(":")[1]) > 0) &
                  (int.parse(item.split(":")[1]) < 30)) {
                if (!clashState) {
                  playClass(int.parse(Class1));
                  print(
                      "Testing 1: ${globals.impClassesRev[int.parse(Class1)]}");
                }
              }
            }
          }

          encodedClasses.add(int.parse(Class1));
          ik++;
        }
      }

      for (var i = 0; i < 4; i++) {
        if (encodedClasses[i] != 0) {
          setState(() {
            pulseList[i] = 100;
          });
        } else {
          setState(() {
            pulseList[i] = 0;
          });
        }
      }

      var toEsp =
          "${motorIntensities[0]}:0&${motorIntensities[1]}:0&${motorIntensities[2]}:0&${motorIntensities[3]}:0";
      print("Sending to ESP:$toEsp");
      writeData(toEsp);
      //globals.classToSpeak = encodedClasses
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

  /// Callback to get inference results from [CameraView]
  void resultsCallback(List<dynamic> results) {
    setState(() {
      this.results = results[1]["recognitions"];
      coordinateList = results[0];
    });
  }

  void depthMapCallback(DepthMap depthMaps) {
    setState(() {
      this.depthMap = depthMaps;
      imageData = depthMaps.depthMap;
      DepthCV = depthMaps.depthMapCV;
      OGImageList = depthMaps.OGImage;
    });
  }

  /// Callback to get inference stats from [CameraView]
  void statsCallback(Stats stats) {
    setState(() {
      this.stats = stats;
    });
  }

  static const BOTTOM_SHEET_RADIUS = Radius.circular(24.0);
  static const BORDER_RADIUS_BOTTOM_SHEET = BorderRadius.only(
      topLeft: BOTTOM_SHEET_RADIUS, topRight: BOTTOM_SHEET_RADIUS);
}

/// Row for one Stats field

