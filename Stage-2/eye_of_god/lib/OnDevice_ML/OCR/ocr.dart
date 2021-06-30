import 'package:image/image.dart';
import 'package:camera/camera.dart';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'dart:typed_data';
import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:eye_of_god/Globals/globals.dart' as globals;

class OcrManager {
  static Future<List<TextBlock>> scanText(CameraImage availableImage) async {
    print("scanning!...");

    /*
     * https://firebase.google.com/docs/ml-kit/android/recognize-text
     * .setWidth(480)   // 480x360 is typically sufficient for
     * .setHeight(360)  // image recognition
     */
    List<TextBlock> _elements = [];
    final FirebaseVisionImageMetadata metadata = FirebaseVisionImageMetadata(
        rawFormat: availableImage.format.raw,
        size: Size(
            availableImage.width.toDouble(), availableImage.height.toDouble()),
        planeData: availableImage.planes
            .map((currentPlane) => FirebaseVisionImagePlaneMetadata(
                bytesPerRow: currentPlane.bytesPerRow,
                height: currentPlane.height,
                width: currentPlane.width))
            .toList(),
        rotation: ImageRotation.rotation90);
    var imageSizeIn =
        Size(availableImage.width.toDouble(), availableImage.height.toDouble());
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromBytes(availableImage.planes[0].bytes, metadata);
    final TextRecognizer textRecognizer =
        FirebaseVision.instance.textRecognizer();
    final VisionText visionText =
        await textRecognizer.processImage(visionImage);

    print("--------------------visionText:${visionText.text}");

    for (TextBlock block in visionText.blocks) {
      var points = block.cornerPoints;
      var xcoord = points[0].dx;
      var ycoord = points[0].dy;
      var x1coord = points[2].dx;
      var y1coord = points[2].dy;
      print("giorno is $xcoord & $ycoord & $x1coord & $y1coord");
      final Rect boundingBox = block.boundingBox;
      print("john is: $boundingBox");
      // final List<Point<int>> cornerPoints = block.cornerPoints;
      print("okay man : ${block.text}");
      _elements.add(block);
      //final List<RecognizedLanguage> languages = block.recognizedLanguages;
      var textDetected;
      for (TextLine line in block.lines) {
        // Same getters as TextBlock
        print("thid : ${line.text}");
        for (TextElement element in line.elements) {
          // Same getters as TextBlock
          //_elements.add(element);
          var jojo = element.text;
          if (element.text == "Car") {
            textDetected = element;
          }
          print("jojo is alive in indoor: $jojo");
        }
      }
    }

    //return visionText.text;
    return _elements;
  }

  /*
    * code by
    * https://github.com/bparrishMines/mlkit_demo/blob/master/lib/main.dart
    */

  Uint8List concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    planes.forEach((Plane plane) => allBytes.putUint8List(plane.bytes));
    return allBytes.done().buffer.asUint8List();
  }

  FirebaseVisionImageMetadata buildMetaData(CameraImage image) {
    return FirebaseVisionImageMetadata(
      rawFormat: image.format.raw,
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: ImageRotation.rotation90,
      planeData: image.planes.map((Plane plane) {
        return FirebaseVisionImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      }).toList(),
    );
  }

  // Future<void> _getImageSize(CameraImage imageFile) async {
  //   final Completer<Size> completer = Completer<Size>();

  //   // final Image image = Image.file(imageFile);
  //   image.image.resolve(const ImageConfiguration()).addListener(
  //     ImageStreamListener((ImageInfo info, bool _) {
  //       completer.complete(Size(
  //         info.image.width.toDouble(),
  //         info.image.height.toDouble(),
  //       ));
  //     }),
  //   );

  //   // final Size imageSize = await completer.future;
  //   // setState(() {
  //   //   _imageSize = imageSize;
  //   // });
  // }
}
