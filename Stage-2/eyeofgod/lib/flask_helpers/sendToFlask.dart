import 'package:eyeofgod/LocationMethods/geodes.dart';
import 'package:eyeofgod/flask_helpers/recog.dart';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'dart:async';
import 'package:eyeofgod/variables/globals.dart' as globals;
import 'package:eyeofgod/camera_controllers/camera_converter.dart';
import 'package:http/http.dart';

import 'package:path_provider/path_provider.dart';

import 'dart:convert';

import 'package:eyeofgod/tflite_helpers/bounding_box.dart';

import 'package:eyeofgod/camera_controllers/live_camera.dart';

int counter = 1;

Future<void> toFlask(CameraImage image) async {
  globals.speech = null;

  var imageok = await convertYUV420toImageColor(image);

  String img64 = base64Encode(imageok);

  List<dynamic> coords = await getBoundingBox();
  print(coords);

  var dodge = json.encode({
    'x': coords[0].toString(),
    'y': coords[1].toString(),
    'w': coords[2].toString(),
    'h': coords[3].toString(),
    'dClasss': coords[4]
  });
  print(dodge);

  //SendMessage().sendMessage("255:0&0:0&0:0&0:0");
  // globals.speech = values[2].toString();

  print("Not Sending");
  List gast = getRecog();

  print('Detected Class: ${gast[4]}');

  List<String> ImpClasses = [
    "bicycle",
    "car",
    "motorcycle",
    "airplane",
    "bus",
    "train",
    "truck",
    "boat",
    "person",
    "traffic light",
    "stop sign",
    "bench",
    "potted plant",
    "laptop",
    "cell phone"
  ];

  print("Sending${gast[4]}");

  var gastitems = gast[4].split(',');
  final Map<int, String> values1 = {
    for (int i = 0; i < gastitems.length; i++) i: gastitems[i]
  };

  void notif(var k) {
    globals.colors = k;
  }

  if (!globals.navMode) {
    if (gastitems.length != 0) {
      for (String detected in gastitems) {
        print("Please");

        MultipartRequest request =
            MultipartRequest('POST', Uri.parse('http://4db6ec21913c.ngrok.io'));
        // Outdoor Navigation IP
        request.files.add(MultipartFile.fromString("Counter", img64));
        request.fields["x"] = gast[0];
        request.fields["y"] = gast[1];
        request.fields["w"] = gast[2];
        request.fields["h"] = gast[3];
        request.fields["dClass"] = gast[4];

        Response response = await Response.fromStream(await request.send());

        var feedback = jsonDecode(response.body);
        print("Returned is: $feedback");

        List<int> tempColors = [0, 0, 0, 0];
        // var k = feedback['1'];

        for (var i = 1; i < 5; i++) {
          var motor_reading_pre = feedback["$i"];

          if (motor_reading_pre != null) {
            var motor_reading = motor_reading_pre[0];
            print("idiot$motor_reading");
            if (motor_reading >= 0 && motor_reading <= 25) {
              globals.colors[i] = 50;
            } else if (motor_reading >= 26 && motor_reading <= 50) {
              globals.colors[i] = 100;
            } else if (motor_reading >= 51 && motor_reading <= 75) {
              globals.colors[i] = 200;
            } else if (motor_reading >= 76 && motor_reading <= 100) {
              globals.colors[i] = 300;
            } else if (motor_reading >= 101 && motor_reading <= 125) {
              globals.colors[i] = 400;
            } else if (motor_reading >= 126 && motor_reading <= 150) {
              globals.colors[i] = 500;
            } else if (motor_reading >= 151 && motor_reading <= 175) {
              globals.colors[i] = 600;
            } else if (motor_reading >= 176 && motor_reading <= 200) {
              globals.colors[i] = 700;
            } else if (motor_reading >= 201 && motor_reading <= 225) {
              globals.colors[i] = 800;
            } else if (motor_reading >= 226 && motor_reading <= 255) {
              globals.colors[i] = 900;
            }
          }
        }

        // globals.colors = tempColors;
        // print("THis is shit: $tempColors");
        // if (counter % 2 == 0) {
        //   globals.colors[0] = 600;
        //   globals.colors[1] = 900;
        //   globals.colors[2] = 500;
        //   globals.colors[3] = 50;
        // } else {
        //   globals.colors[0] = 50;
        //   globals.colors[1] = 900;
        //   globals.colors[2] = 500;
        //   globals.colors[3] = 50;
        // }
        // counter += 1;

        // print("Result: ${response.statusCode}");
        // print("Final OP:${response.body}");
        // print("length is : ${response.body.length}");
        // if (response.body.length != 0) {
        //   var split = response.body.split(':');
        //   final Map<int, String> values = {
        //     for (int i = 0; i < split.length; i++) i: split[i]
        //   };
        //   print("wtf is this");

        //   List motorpwms = [0, 0, 0, 0];
        //   //int counter = 0;
        //   print("values of 0 is : ${values[0]}");
        //   motorpwms[int.parse(values[0]) - 1] = values[1];

        //   print("PWM: ${motorpwms}");
        //   SendMessage().sendMessage(
        //       "${motorpwms[0]}:0&${motorpwms[1]}:0&${motorpwms[2]}:0&${motorpwms[3]}:0");
        //   globals.speech = values[2].toString();

        var SpeakInt = SpeakThis();
        // SpeakInt.initTts();
        //   print("OK Working");
        //   SpeakInt.speak_tts(values[2]);
        //   print("OK Working");
        // }
      }
    } else {
      // Empty Class
      // SendMessage().sendMessage("0:0&0:0&0:0&0:0");
      print("Empty");
    }
  } else {
    for (String detected in gastitems) {
      if ("potted plant" == detected) {
        print("Going to die");
        MultipartRequest request1 = MultipartRequest(
            'POST', Uri.parse('http://192.168.0.103:5000/back'));
        // Indoor Navigation IP
        request1.files.add(MultipartFile.fromString("Counter", img64));

        request1.fields["x"] = gast[0];
        request1.fields["y"] = gast[1];
        request1.fields["w"] = gast[2];
        request1.fields["h"] = gast[3];
        request1.fields["dClass"] = gast[4];

        Response response = await Response.fromStream(await request1.send());
        print("Result: ${response.statusCode}");
        print("Final OP:${response.body}");
        print("length is : ${response.body.length}");
        if (response.body.length != 0) {
          var split = response.body.split('.');
          final Map<int, String> values = {
            for (int i = 0; i < split.length; i++) i: split[i]
          };
          SendMessage().sendMessage("${values[0]}");
          // print("response ${values}");
          // var SpeakInt = SpeakThis();
          // SpeakInt.initTts();
          print("OK Working");
          // if (values[1] != '0') {
          //   SpeakInt.speak_tts(values[1]);
          // }
        }
      }
    }
  }
}
