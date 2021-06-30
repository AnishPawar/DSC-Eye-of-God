import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eye_of_god/ui/Outdoor/outdoor.dart';
import 'package:eye_of_god/ui/Indoor/indoor.dart';
import 'package:eye_of_god/ui/selectorPage.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
// import 'package:eye_of_god/gg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fuzzy/fuzzy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeRight]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eye of God',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SelectorPage(),
      routes: {
        HomeView.id: (context) => HomeView(),
        Indoor.id: (context) => Indoor(),
      },
    );
  }
}
