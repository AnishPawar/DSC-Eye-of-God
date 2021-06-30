// import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:image/image.dart' as img;

class DepthMap {
  int inferenceTime = 0;
  // img.Image depthMap;
  List<int> depthMap;
  List<int> depthMapCV;
  List<int> OGImage;

  DepthMap({this.depthMap, this.depthMapCV, this.OGImage});
}
