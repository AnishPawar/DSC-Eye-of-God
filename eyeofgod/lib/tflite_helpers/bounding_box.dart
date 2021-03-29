import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:eyeofgod/variables/globals.dart' as globals;

Future<List> getBoundingBox() async {
  // var valuex = globals.x;

  // math.max(0, int.parse(globals.x));

  return ([globals.x, globals.y, globals.w, globals.h, globals.detectedClass]);
}

class BoundingBox extends StatelessWidget {
  final List<dynamic> results;
  final int previewH;
  final int previewW;
  final double screenH;
  final double screenW;

  BoundingBox(
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
      print("Res is");
      print(previewH);
      print(previewW);
      print(screenW);
      print(screenH);
      return results.map((re) {
        var _x = re["rect"]["x"];
        var _w = re["rect"]["w"];
        var _y = re["rect"]["y"];
        var _h = re["rect"]["h"];
        var scaleW, scaleH;
        print("this is class:");
        print(re["detectedClass"].runtimeType);
        globals.detectedClass = re["detectedClass"];
        //var x, y, w, h;

        if (screenH / screenW > previewH / previewW) {
          scaleW = screenH / previewH * previewW;
          scaleH = screenH;
          var difW = (scaleW - screenW) / scaleW;
          globals.x = (_x - difW / 2) * scaleW;
          globals.w = _w * scaleW;
          if (_x < difW / 2) globals.w -= (difW / 2 - _x) * scaleW;
          globals.y = _y * scaleH;
          globals.h = _h * scaleH;
        } else {
          scaleH = screenW / previewW * previewH;
          scaleW = screenW;
          var difH = (scaleH - screenH) / scaleH;
          globals.x = _x * scaleW;
          globals.w = _w * scaleW;
          globals.y = (_y - difH / 2) * scaleH;
          globals.h = _h * scaleH;

          //print(re["detectedClass"]);
          if (_y < difH / 2) globals.h -= (difH / 2 - _y) * scaleH;
        }

        return Positioned(
          left: math.max(0, globals.x),
          top: math.max(0, globals.y),
          width: globals.w,
          height: globals.h,
          child: Container(
            padding: EdgeInsets.only(top: 5.0, left: 5.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color.fromRGBO(37, 213, 253, 1.0),
                width: 3.0,
              ),
            ),
            child: Text(
              "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
              style: TextStyle(
                color: Color.fromRGBO(37, 213, 253, 1.0),
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList();
    }

    return Stack(
      children: _renderBox(),
    );
  }
}
