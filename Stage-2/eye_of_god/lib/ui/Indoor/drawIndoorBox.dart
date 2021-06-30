import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class IndoorBoundingBox extends StatelessWidget {
  final List<TextBlock> results;
  final List<Widget> boxes = [];
  final int previewH;
  final int previewW;
  final int screenH;
  final int screenW;
  List colors = [
    Colors.red,
    Colors.green,
    Colors.yellow,
    Colors.amber,
    Colors.blue,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.pink,
    Colors.teal
  ];
  math.Random random = new math.Random();

  IndoorBoundingBox(
    this.results,
    this.previewH,
    this.previewW,
    this.screenH,
    this.screenW,
  );
  // var re = globals.ray;
  @override
  Widget build(BuildContext context) {
    List<Widget> _renderBox() {
      print("Res is $previewH $screenH");
      print(previewH);
      print(previewW);
      print(screenW);
      print(screenH);

      for (var result in results) {
        var x = result.cornerPoints[0].dx;
        x = x < 0 ? 0 : x;
        x = x > 375 ? 375 : x;
        x = (x * 255 / 375);

        var x1 = result.cornerPoints[2].dx;
        x1 = x1 < 0 ? 0 : x1;
        x1 = x1 > 288 ? 288 : x1;
        x1 = (x1 * 255 / 288);
        var w = x1 - x;

        var y = result.cornerPoints[0].dy;
        y = y < 0 ? 0 : y;
        y = y > 375 ? 375 : y;
        y = (y * 255 / 375);

        var y1 = result.cornerPoints[2].dy;
        y1 = y1 < 0 ? 0 : y1;
        y1 = y1 > 288 ? 288 : y1;
        y1 = (y1 * 255 / 288);
        var h = y1 - y;

        var detectedClass = result.text;

        var index = random.nextInt(9);

        boxes.add(Positioned(
          left: x,
          top: y,
          width: w,
          height: h,
          child: Container(
            // padding: EdgeInsets.only(top: 5.0, left: 5.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: colors[index],
                width: 3.0,
              ),
            ),
            child: Text(
              detectedClass,
              style: TextStyle(
                color: Colors.white,
                backgroundColor: colors[index],
                fontSize: 10.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ));
      }

      return boxes;
    }

    return Stack(
      children: _renderBox(),
    );
  }
}
