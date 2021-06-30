import 'dart:async';
import 'dart:collection';

import 'package:camera/camera.dart';
import 'package:collection/equality.dart';
import 'package:flutter/material.dart';
import 'package:eyeofgod/tflite_helpers/bounding_box.dart';
import 'package:eyeofgod/camera_controllers/camera.dart';
import 'dart:math' as math;
import 'package:tflite/tflite.dart';
import 'package:eyeofgod/variables/globals.dart' as globals;
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' hide LocationAccuracy;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:eyeofgod/LocationMethods/geodes.dart';
import 'package:eyeofgod/LocationMethods/directions.dart';
import 'package:eyeofgod/Speech/html.dart';
import 'package:eyeofgod/Speech/speech_api.dart';
import 'package:eyeofgod/Speech/utils.dart';
import 'package:eyeofgod/DataClass/Prediction.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'package:flutter/services.dart';

BluetoothConnection connection;
double latitude = 19.079790;
double longitude = 72.904050;
enum TtsState { playing, stopped }
final GlobalKey<_LiveFeedState> mainkey = GlobalKey();
List<int> x = globals.colors;

class LiveFeed extends StatefulWidget {
  final List<CameraDescription> cameras;
  // final BluetoothDevice server;
  final String title;

  LiveFeed(this.cameras, {Key key, this.title}) : super(key: key);

  @override
  _LiveFeedState createState() => _LiveFeedState();
}

class SendMessage {
  void sendMessage(String text) async {
    text = text.trim();
    // textEditingController.clear();

    if (text.length > 0) {
      // try {
      connection.output.add(utf8.encode(text + "\r\n"));
      await connection.output.allSent;
    }
  }
}

// class Send
class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class SpeakThis {
  var flutterTts = FlutterTts();
  var ttsState;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 1.0;
  initTts() {
    flutterTts.setStartHandler(() {
      print("playing");
      ttsState = TtsState.playing;

      print("TTS State:${ttsState}");
      // print(ttsState);
    });

    flutterTts.setCompletionHandler(() {
      print("Complete");
      ttsState = TtsState.stopped;
      print("TTS State:${ttsState}");
    });
    flutterTts.setErrorHandler((msg) {
      print("error: $msg");
      ttsState = TtsState.stopped;
      print("TTS State:${ttsState}");
    });
  }

  Future speak_tts(String _newVoiceText) async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);
    await flutterTts.setLanguage("en-IN");

    if (_newVoiceText != null) {
      if (_newVoiceText.isNotEmpty) {
        var result = await flutterTts.speak(_newVoiceText);
        if (result == 1) ttsState = TtsState.playing;
        print(_newVoiceText);
      }
    }
  }
}

class _LiveFeedState extends State<LiveFeed> {
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
  LocationData currentLocationld;
  Location loacation1;
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
  FlutterTts flutterTts;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 1.0;
  TtsState ttsState = TtsState.stopped;
  String text;
  String dest;
  bool isListening = false;
  List<_Message> messages = List<_Message>();
  String _messageBuffer = '';
  List<double> _userAccelerometerValues;
  List<double> _gyroscopeValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  List<List<String>> gyro_global = List<List<String>>.filled(5, []);
  int count_global = 0;

  List buttonColorsDefault = [
    Colors.cyanAccent,
    Colors.cyanAccent,
    Colors.cyanAccent,
    Colors.cyanAccent
  ];

  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();
    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccelerometerValues = <double>[
          event.x.abs(),
          event.y.abs(),
          event.z.abs()
        ];
      });
    }));
    loadTfModel();
    initTts();

    loacation1 = new Location();
    loacation1.onLocationChanged.listen((LocationData cLoc) {
      currentLocationld = cLoc;
      print("calling updatePinOnMap");
      updatePinOnMap();
    });

    // BluetoothConnection.toAddress(widget.server.address).then((_connection) {
    //   print('Connected to the device');
    //   connection = _connection;
    //   setState(() {
    //     isConnecting = false;
    //     isDisconnecting = false;
    //   });

    //   connection.input.listen(_onDataReceived).onDone(() {
    //     if (isDisconnecting) {
    //       print('Disconnecting locally!');
    //     } else {
    //       print('Disconnected remotely!');
    //     }
    //     if (this.mounted) {
    //       setState(() {});
    //     }
    //   });
    // }).catchError((error) {
    //   print('Cannot connect, exception occured');
    //   print(error);
    // }

    // );
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  initCameras() async {}
  loadTfModel() async {
    await Tflite.loadModel(
      model: "assets/ssd_mobilenet.tflite",
      labels: "assets/ssd_mobilenet.txt",
    );
  }

  /*
  The set recognitions function assigns the values of recognitions, imageHeight and width to the variables defined here as callback
  */
  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
    globals.recogthis = _recognitions;
  }

  void updatePinOnMap() async {
    CameraPosition cPosition = CameraPosition(
      zoom: 16,
      target: LatLng(currentLocationld.latitude, currentLocationld.longitude),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    print("outside set state of coordi");
    straight_path();
    setState(() {
      print("in set state of coordi");
      pinPosition =
          LatLng(currentLocationld.latitude, currentLocationld.longitude);
      //print(pinPosition);
      // print("currentLoc: Lat:" +
      //     pinPosition.latitude +
      //     " long:" +
      //     pinPosition.longitude);
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

  void doSomething() {
    doingSomething();
  }

  void doingSomething() {
    setState(() {
      globals.colors;
    });
  }

  double angleBetweenPoints(LatLng latlongA, LatLng latlongB, LatLng latlongC) {
    double headingBA = calculateBearing(latlongB, latlongA);
    double headingBC = calculateBearing(latlongB, latlongC);

    return angleBetweenHeadings(headingBA, headingBC);
  }

  double angleBetweenHeadings(double headingBA, double headingBC) {
    double angle = ((headingBA - headingBC) + 360) % 360;

    if (angle > 180)
      return 360 - angle;
    else
      return angle;
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
        var SpeakInt = SpeakThis();
        SpeakInt.initTts();
        String inst5 = "You are not walking on a Straight Path. Turn Left";
        SpeakInt.speak_tts(inst5);
        print("Inst5 = " + inst5);
      }
      if (double.parse(gyro_global[2][0]) > 0) {
        var SpeakInt = SpeakThis();
        SpeakInt.initTts();
        String inst5 = "You are not walking on a Straight Path. Turn Right";
        SpeakInt.speak_tts(inst5);
        print("Inst5 = " + inst5);
      }
    }
  }

  Function eq = const ListEquality().equals;

  void path_match(double cur_lat, double cur_lng) {
    String inst =
        "You are not on the correct route to your destination. Please turn around";
    bool lat_check =
        pathMatching(pos.latitude, destinationPos.latitude, cur_lat);
    bool long_check =
        pathMatching(pos.longitude, destinationPos.longitude, cur_lng);
    if (lat_check && long_check) {
      print("On path");
    } else {
      LatLng latlongA = LatLng(cur_lat, cur_lng);
      LatLng latlongB = LatLng(upd_end_lat, upd_end_long);
      LatLng latlongC = LatLng(next_end_lat, next_end_long);
      double corr_angle = angleBetweenPoints(latlongA, latlongB, latlongC);
      double angle = double.parse((corr_angle).toStringAsFixed(2));
      String inst2 = "Turn by " + angle.toString() + " degrees ";
      var SpeakInt = SpeakThis();
      SpeakInt.initTts();
      SpeakInt.speak_tts(inst);
      SpeakInt.speak_tts(inst2);
    }
    // straight_path();
  }

  int i = 0;
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
        updateCoordi(nav_command);
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
          var SpeakInt = SpeakThis();
          SpeakInt.initTts();
          SpeakInt.speak_tts(inst3);
          print("Inst3 = " + inst3);
        }
        i++;
        return;
      }
    }
  }

  Future<void> setupPositionLocator() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;
    pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = new CameraPosition(target: pos, zoom: 14);
    newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cp));
    String address = await Directions.findCordinateAddress(position, context);
    print("Address:" + address);
    print("setuppos = $pos");
    print("setuppos = $destinationPos");
  }

  void refresh() {
    setState(() {
      x = globals.colors;
    });
  }

  static final CameraPosition _currentpos = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(latitude, longitude),
      tilt: 59.440717697143555,
      zoom: 14);

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Real Time Object Detection"),
      // ),
      body: Column(
        children: [
          Expanded(
            flex: 8,
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Stack(
                    children: [
                      CameraFeed(
                          widget.cameras, setRecognitions, mainkey, refresh),
                      BoundingBox(
                        _recognitions == null ? [] : _recognitions,
                        math.max(_imageWidth, _imageHeight),
                        math.min(_imageWidth, _imageHeight),
                        screen.height,
                        screen.width,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
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
                        zoomControlsEnabled: true,
                        polylines: _polylines,
                        markers: _markers,
                        circles: _circles,
                        onMapCreated: (GoogleMapController controller) async {
                          _controller.complete(controller);
                          newGoogleMapController = controller;
                          setupPositionLocator();
                        },
                      ),
                      GestureDetector(onTap: () => toggleRecording()),
                    ],
                  ),
                ),
                Expanded(child: RaisedButton(onPressed: () {
                  setState(() {
                    x = globals.colors;
                  });
                }))
              ],
            ),
          ),
          Expanded(
              child: Row(
            children: [
              Expanded(
                child: Container(
                  color: Colors.amber,
                  child: Icon(
                    Icons.remove_red_eye_outlined,
                    color: x[0] == 500 ? Colors.red : Colors.red[x[0]],
                    size: 40,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.red,
                  child: Icon(
                    Icons.remove_red_eye_outlined,
                    color: x[1] == 500 ? Colors.red : Colors.red[x[1]],
                    size: 40,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.green,
                  child: Icon(
                    Icons.remove_red_eye_outlined,
                    color: x[2] == 500 ? Colors.red : Colors.red[x[2]],
                    size: 40,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.blue,
                  child: Icon(
                    Icons.remove_red_eye_outlined,
                    color: x[3] == 500 ? Colors.red : Colors.red[x[3]],
                    size: 40,
                  ),
                ),
              ),
            ],
          ))
        ],
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    String dataString = String.fromCharCodes(buffer);
    //print("Received is: ${dataString}");
    if (int.parse(dataString) == 1) {
      toggleRecording();
    }
  }

  void sendMessage(String text) async {
    text = text.trim();
    // textEditingController.clear();

    if (text.length > 0) {
      // try {
      connection.output.add(utf8.encode(text + "\r\n"));
      await connection.output.allSent;
    }
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

  void updateCoordi(String nav_command) {
    print(nav_command);
    HtmlTags.removeTag(
        htmlString: nav_command,
        callback: (string) {
          var SpeakInt = SpeakThis();
          SpeakInt.initTts();
          SpeakInt.speak_tts(string);
        });
  }

  Future toggleRecording() => SpeechApi.toggleRecording(
        onResult: (text) => setState(() => this.text = text),
        onListening: (isListening) {
          setState(() => this.isListening = isListening);
          print("before !islistening");
          if (!isListening) {
            Future.delayed(Duration(seconds: 1), () {
              globals.navMode = Utils.scanText1(text);
              dest = Utils.scanText(text);
              print("listening over");
              if (!globals.navMode) {
                print("In navMode");
                searchPlace(dest);
              } else {
                var SpeakInt = SpeakThis();
                SpeakInt.initTts();
                SpeakInt.speak_tts(
                    "Starting Indoor Navigation.Taking you to the nearest potted plant");
                // SpeakInt.speak_tts("Taking you to the nearest potted plant");
              }
            });
          }
        },
      );

  initTts() {
    flutterTts = FlutterTts();

    flutterTts.setStartHandler(() {
      setState(() {
        print("playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });
    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future speak_tts(String _newVoiceText) async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);
    await flutterTts.setLanguage("en-IN");

    if (_newVoiceText != null) {
      if (_newVoiceText.isNotEmpty) {
        var result = await flutterTts.speak(_newVoiceText);
        if (result == 1) setState(() => ttsState = TtsState.playing);
      }
    }
  }
}
