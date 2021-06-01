import 'package:camera/camera.dart';
import 'package:eyeofgod/camera_controllers/live_camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:eyeofgod/bluetooth_helpers/connection.dart';

// Map + Speech Imports
import 'dart:async';

List<CameraDescription> cameras;
double latitude = 19.079790;
double longitude = 72.904050;
enum TtsState { playing, stopped }
Future<void> main() async {
  // initialize the cameras when the app starts
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();

  // running the app
  runApp(MaterialApp(
    home: MyApp(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DSC Challenge App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder(
        future: FlutterBluetoothSerial.instance.requestEnable(),
        builder: (context, future) {
          if (future.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Container(
                height: double.infinity,
                child: Center(
                  child: Icon(
                    Icons.remove_red_eye_outlined,
                    size: 200.0,
                    color: Colors.cyanAccent,
                  ),
                ),
              ),
            );
          } else if (future.connectionState == ConnectionState.done) {
            return Home();
          } else {
            return Home();
          }
        },
      ),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      // appBar: AppBar(
      //   title: Text('Connection'),
      // ),
      body: SelectBondedDevicePage(
        onCahtPage: (device1) {
          BluetoothDevice device = device1;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return LiveFeed(cameras, device);
              },
            ),
          );
          // var datavar = SendData();
        },
      ),
    ));
  }
}
