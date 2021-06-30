import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:eyeofgod/flask_helpers/sendToFlask.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;
import 'package:image_picker/image_picker.dart';
import 'package:eyeofgod/camera_controllers/camera_converter.dart';
import 'package:eyeofgod/variables/globals.dart' as globals;
import 'package:eyeofgod/camera_controllers/live_camera.dart';

typedef void Callback(List<dynamic> list, int h, int w);

class CameraFeed extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;
  // The cameraFeed Class takes the cameras list and the setRecognitions
  // function as argument
  // CameraFeed(this.cameras, this.setRecognitions);
  final Function() updateColors;
  CameraFeed(
      this.cameras, this.setRecognitions, Key key, @required this.updateColors)
      : super(key: key);

  @override
  _CameraFeedState createState() => new _CameraFeedState();
}

int coun = 0;

class _CameraFeedState extends State<CameraFeed> {
  CameraController controller;
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();
    print(widget.cameras);
    if (widget.cameras == null || widget.cameras.length < 1) {
      print('No Cameras Found.');
    } else {
      controller = new CameraController(
        widget.cameras[0],
        ResolutionPreset.low,
      );
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }

        controller.startImageStream((CameraImage img) {
          if (!isDetecting) {
            isDetecting = true;
            if (coun % 3 == 0) {
              print(img);
              toFlask(img);
              widget.updateColors();
              setState(() {});
              // var k  = LiveFeed();
              // updateColor();
              print("gg${img.width}");
              print("gg1${img.height}");
            }
            coun = coun + 1;
            Tflite.detectObjectOnFrame(
              bytesList: img.planes.map((plane) {
                return plane.bytes;
              }).toList(),
              model: "SSDMobileNet",
              rotation: 180,
              imageHeight: img.height,
              imageWidth: img.width,
              imageMean: 127.5,
              imageStd: 127.5,
              numResultsPerClass: 7,
              threshold: 0.6,
            ).then((recognitions) {
              /*
              When setRecognitions is called here, the parameters are being passed on to the parent widget as callback. i.e. to the LiveFeed class
               */
              widget.setRecognitions(recognitions, img.height, img.width);
              isDetecting = false;
            });
          }
        });
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }

    var tmp = MediaQuery.of(context).size;

    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller.value.previewSize;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return OverflowBox(
        maxHeight: screenRatio > previewRatio
            ? screenH
            : screenW / previewW * previewH,
        maxWidth: screenRatio > previewRatio
            ? screenH / previewH * previewW
            : screenW,

        // maxHeight: previewH,
        // maxWidth: previewW,
        child: RotatedBox(
          quarterTurns: -1,
          child: Transform.scale(
            scale: 1 / controller.value.aspectRatio,
            child: Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: CameraPreview(controller),
              ),
            ),
          ),
        ));
  }
}
