library my_prj.globals;

// import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'dart:ui';

import 'package:flutter/material.dart';

String imagePath;
var x;
var y;
var w;
var h;
var detectedClass;
var re;
List<dynamic> recogthis;
List<dynamic> fin;
var speech;
// List<dynamic> motorbg;
// List<Color> motorfg = [Colors.cyan, Colors.cyan, Colors.cyan, Colors.cyan];
// List<Color> motorbg = [Colors.white, Colors.white, Colors.white, Colors.white];
Size imageSizeIn;
bool navMode = false;

// List<int> colors = [50, 50, 50, 50];
List<String> classToSpeak;

Map<String, int> impClasses = {
  // "person": 1,
  "bicycle": 2,
  "car": 3,
  "motorcycle": 4,
  // "bus": 5,
  // "train": 6,
  // "truck": 7,
  // "boat": 8,
  "traffic light": 9,
  // "fire hydrant": 10,
  "stop sign": 11,
  // "bench": 12,
  // "dog": 13,
  // "cow": 14,
  // "elephant": 15,
  // "bear": 16,
  // "frisbee": 17,
  // "sports ball": 18,
  // "skateboard": 19,
  // "chair": 20,
  // "couch": 21,
  // "toilet": 22,
  // "backpack": 23,
  // "umbrella": 24,
  // "bed": 25,
  // "dining table": 26,
  // "laptop": 27,
  // "potted plant": 28,
  // "tv": 29
};

Map<int, String> impClassesRev = {
  0: "No Class",
  // 1: "person",
  2: "bicycle",
  3: "car",
  4: "motorcycle",
  // 5: "bus",
  // 6: "train",
  // 7: "truck",
  // 8: "boat",
  9: "traffic light",
  // 10: "fire hydrant",
  11: "stop sign",
  // 12: "bench",
  // 13: "dog",
  // 14: "cow",
  // 15: "elephant",
  // 16: "bear",
  // 17: "frisbee",
  // 18: "sports ball",
  // 19: "skateboard",
  // 20: "chair",
  // 21: "couch",
  // 22: "toilet",
  // 23: "backpack",
  // 24: "umbrella",
  // // 25: "bed",
  // 26: "dining table",
  // // 27: "laptop",
  // 28: "potted plant",
  // 29: "tv"
};

List<int> sendCoordList = [];
List<int> encodedLabelList = [];
