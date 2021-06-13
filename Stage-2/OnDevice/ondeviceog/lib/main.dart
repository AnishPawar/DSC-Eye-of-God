// import 'dart:io';
// import 'package:image/image.dart' as img;
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:ondeviceog/classifier.dart';
// import 'package:ondeviceog/depthModel/classifier_quant.dart';
// import 'package:logger/logger.dart';
// import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
// import 'package:flutter/services.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Image Classification',
//       theme: ThemeData(
//         primarySwatch: Colors.orange,
//       ),
//       home: MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key key, this.title}) : super(key: key);

//   final String title;

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   Classifier _classifier;

//   var logger = Logger();

//   File _image;
//   final picker = ImagePicker();

//   Image _imageWidget;

//   var fox;

//   Category category;

//   @override
//   void initState() {
//     super.initState();
//     _classifier = ClassifierQuant();
//   }

//   Future getImage() async {
//     final pickedFile = await picker.getImage(source: ImageSource.gallery);

//     setState(() {
//       _image = File(pickedFile.path);
//       _imageWidget = Image.file(_image);

//       _predict();
//     });
//   }

//   void _predict() async {
//     img.Image imageInput = img.decodeImage(_image.readAsBytesSync());
//     img.Image pred = await _classifier.predict(imageInput);

//     print("Pred issss: $pred");

//     setState(() {
//       _imageWidget = pred as Image;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('TfLite Flutter Helper',
//             style: TextStyle(color: Colors.white)),
//       ),
//       body: Column(
//         children: <Widget>[
//           Center(
//             child: _image == null
//                 ? Text('No image selected.')
//                 : Container(
//                     constraints: BoxConstraints(
//                         maxHeight: MediaQuery.of(context).size.height / 2),
//                     decoration: BoxDecoration(
//                       border: Border.all(),
//                     ),
//                     child: _imageWidget,
//                   ),
//           ),
//           SizedBox(
//             height: 36,
//           ),
//           Text(
//             category != null ? category.label : '',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//           ),
//           SizedBox(
//             height: 8,
//           ),
//           Text(
//             category != null
//                 ? 'Confidence: ${category.score.toStringAsFixed(3)}'
//                 : '',
//             style: TextStyle(fontSize: 16),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: getImage,
//         tooltip: 'Pick Image',
//         child: Icon(Icons.add_a_photo),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ondeviceog/ui/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
      home: HomeView(),
    );
  }
}
