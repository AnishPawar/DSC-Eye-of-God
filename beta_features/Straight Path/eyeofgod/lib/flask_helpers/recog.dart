import 'package:eyeofgod/variables/globals.dart' as globals;

import 'dart:math';

// var classes = {
//   "???": 0,
//   "person": 1,
//   "bicycle": 2,
//   "car": 3,
//   "motorcycle": 4,
//   "airplane": 5,
//   "bus": 6,
//   "train": 7,
//   "truck": 8,
//   "boat": 8,
//   "traffic light": 9,
//   "fire hydrant": 10,
//   "???": 11,
//   "stop sign": 12,
//   "parking meter": 13,
//   "bench": 14,
//   "bird": 15,
//   "cat": 16,
//   "dog": 17,
//   "horse": 18,
//   "sheep": 19,
//   "cow": 20,
//   "elephant": 21,
//   "bear": 22,
//   "zebra": 23,
//   "giraffe": 24,
//   "???": 25,
//   "backpack": 26,
//   "umbrella": 27,
//   "???": 28,
//   "???": 29,
//   "handbag": 30,
//   "tie": 31,
//   "suitcase": 32,
//   "frisbee": 33,
//   "skis": 34,
//   "snowboard": 35,
//   "sports ball": 36,
//   "kite": 37,
//   "baseball bat": 38,
//   "baseball glove": 39,
//   "skateboard": 40,
//   "surfboard": 41,
//   "tennis racket": 42,
//   "bottle": 43,
//   "???": 44,
//   "wine glass": 45,
//   "cup": 46,
//   "fork": 47,
//   "knife": 48,
//   "spoon": 49,
//   "bowl": 50,
//   "banana": 51,
//   "apple": 52,
//   "sandwich": 53,
//   "orange": 54,
//   "broccoli": 55,
//   "carrot": 56,
//   "hot dog": 57,
//   "pizza": 58,
//   "donut": 59,
//   "cake": 60,
//   "chair": 61,
//   "couch": 62,
//   "potted plant": 63,
//   "bed": 64,
//   "???": 65,
//   "dining table": 66,
//   "???": 67,
//   "???": 68,
//   "toilet": 69,
//   "???": 70,
//   "tv": 71,
//   "laptop": 72,
//   "mouse": 73,
//   "remote": 74,
//   "keyboard": 75,
//   "cell phone": 76,
//   "microwave": 77,
//   "oven": 78,
//   "toaster": 79,
//   "sink": 80,
//   "refrigerator": 81,
//   "???": 82,
//   "book": 83,
//   "clock": 84,
//   "vase": 85,
//   "scissors": 86,
//   "teddy bear": 87,
//   "hair drier": 88,
//   "toothbrush": 89
// };

List<String> getRecog() {
  List<dynamic> recog = globals.recogthis;
  print(recog);

  // List<int> allx = [];
  // List<int> ally = [];
  // List<int> allw = [];
  // List<int> allh = [];
  // List<int> allclasses = [];
  String allx = '';
  String ally = '';
  String allw = '';
  String allh = '';
  String allclasses = '';

  for (var object1 in recog) {
    print("Object is: ${object1}");
    // print(object1['rect']['w']);

    var converted = calc(object1['rect']['x'], object1['rect']['y'],
        object1['rect']['w'], object1['rect']['h']);
    print("okay man ");

    allx += max(0, double.parse(converted[0].toString())).toString() + ",";
    ally += max(0, double.parse(converted[1].toString())).toString() + ",";
    allw += max(0, double.parse(converted[2].toString())).toString() + ",";
    allh += max(0, double.parse(converted[3].toString())).toString() + ",";
    allclasses += object1["detectedClass"] + ",";
  }
  print("all test:${allx} and ${allx}");
  return [allx, ally, allw, allh, allclasses];
  // print("All of them are:${allclasses}");
}

List calc(dynamic x, dynamic y, dynamic w, dynamic h) {
  var scaleW, scaleH;
  //print("this is class:");
  // print(re["detectedClass"].runtimeType);
  // globals.detectedClass = re["detectedClass"];
  var x1, y1, w1, h1;
  var previewH = 320;
  var previewW = 240;

  var screenH = 320;
  var screenW = 240;

  if (screenH / screenW > previewH / previewW) {
    scaleW = screenH / previewH * previewW;
    scaleH = screenH;
    var difW = (scaleW - screenW) / scaleW;
    x1 = (x - difW / 2) * scaleW;
    w1 = w * scaleW;
    if (x < difW / 2) globals.w -= (difW / 2 - x) * scaleW;
    y1 = y * scaleH;
    h1 = h * scaleH;
  } else {
    scaleH = screenW / previewW * previewH;
    scaleW = screenW;
    var difH = (scaleH - screenH) / scaleH;
    x1 = x * scaleW;
    w1 = w * scaleW;
    y1 = (y - difH / 2) * scaleH;
    h1 = h * scaleH;

    //print(re["detectedClass"]);
    if (y < difH / 2) globals.h -= (difH / 2 - y) * scaleH;
  }
  return [x1, y1, w1, h1];
}
