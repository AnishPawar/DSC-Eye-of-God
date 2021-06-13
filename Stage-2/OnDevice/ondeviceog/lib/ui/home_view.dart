import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ondeviceog/tflite/recognition.dart';
import 'package:ondeviceog/tflite/stats.dart';
import 'package:ondeviceog/depthModel/depthMapRes.dart';
import 'package:ondeviceog/ui/box_widget.dart';
import 'package:ondeviceog/ui/camera_view_singleton.dart';
import 'package:image/image.dart' as img;
import 'camera_view.dart';
import 'dart:typed_data';
import 'package:image_crop/image_crop.dart';

// import 'package:image_cropper/image_cropper.dart';
final cropKey = GlobalKey<CropState>();

/// [HomeView] stacks [CameraView] and [BoxWidget]s with bottom sheet for stats
class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  /// Results to draw bounding boxes
  List<Recognition> results;

  /// Realtime stats
  Stats stats;

  DepthMap depthMap;

  List<int> imageData = [];
  Uint8List list11;

  /// Scaffold Key
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          CameraView(resultsCallback, statsCallback, depthMapCallback),

          // Container(
          //   width: 255,
          //   height: 255,
          //   color: Colors.black,
          //   padding: const EdgeInsets.all(20.0),
          //   child: Crop(
          //     key: cropKey,
          //     image: Image.memory(Uint8List.fromList(imageData))),
          //     // image: MemoryImage(Uint8List.fromList(imageData)),
          //     aspectRatio: 1,
          //     maximumScale: 0.5,
          //   ),
          // ),
          // SizedBox(
          //   child: AspectRatio(
          //     child: Image.memory(Uint8List.fromList(imageData)),
          //     aspectRatio: 2,
          //   ),
          //   width: 255,
          //   height: 255,
          // ),
          RotatedBox(
            quarterTurns: 1,
            child: Align(
              alignment: new Alignment(0.0, 0.6),
              child: new Container(
                width: 255,
                height: 255,
                decoration: new BoxDecoration(
                    image: new DecorationImage(
                  fit: BoxFit.none,
                  alignment: FractionalOffset.topLeft,
                  image: MemoryImage(Uint8List.fromList(imageData)),
                )),
              ),
            ),
          ),

          // Bounding boxes
          // boundingBoxes(results),
          RotatedBox(quarterTurns: 1, child: boundingBoxes(results)),

          // Bottom Sheet
          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: DraggableScrollableSheet(
          //     initialChildSize: 0.4,
          //     minChildSize: 0.1,
          //     maxChildSize: 0.5,
          //     builder: (_, ScrollController scrollController) => Container(
          //       width: double.maxFinite,
          //       decoration: BoxDecoration(
          //           color: Colors.white.withOpacity(0.9),
          //           borderRadius: BORDER_RADIUS_BOTTOM_SHEET),
          //       child: SingleChildScrollView(
          //         controller: scrollController,
          //         child: Center(
          //           child: Column(
          //             mainAxisSize: MainAxisSize.min,
          //             children: [
          //               Icon(Icons.keyboard_arrow_up,
          //                   size: 48, color: Colors.orange),
          //               (stats != null)
          //                   ? Padding(
          //                       padding: const EdgeInsets.all(8.0),
          //                       child: Column(
          //                         children: [
          //                           StatsRow('Inference time:',
          //                               '${stats.inferenceTime} ms'),
          //                           StatsRow('Total prediction time:',
          //                               '${stats.totalElapsedTime} ms'),
          //                           StatsRow('Pre-processing time:',
          //                               '${stats.preProcessingTime} ms'),
          //                           StatsRow('Frame',
          //                               '${CameraViewSingleton.inputImageSize?.width} X ${CameraViewSingleton.inputImageSize?.height}'),
          //                         ],
          //                       ),
          //                     )
          //                   : Container()
          //             ],
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }

  /// Returns Stack of bounding boxes
  Widget boundingBoxes(List<Recognition> results) {
    if (results == null) {
      return Container();
    }
    return Stack(
      children: results
          .map((e) => BoxWidget(
                result: e,
              ))
          .toList(),
    );
  }

  /// Callback to get inference results from [CameraView]
  void resultsCallback(List<Recognition> results) {
    setState(() {
      this.results = results;
    });
  }

  void depthMapCallback(DepthMap depthMap) {
    setState(() {
      this.depthMap = depthMap;
      imageData = depthMap.depthMap;
      // print(depthMap.depthMap.data);
      print(depthMap.depthMap);
      print("Im in");
    });
  }

  /// Callback to get inference stats from [CameraView]
  void statsCallback(Stats stats) {
    setState(() {
      this.stats = stats;
    });
  }

  static const BOTTOM_SHEET_RADIUS = Radius.circular(24.0);
  static const BORDER_RADIUS_BOTTOM_SHEET = BorderRadius.only(
      topLeft: BOTTOM_SHEET_RADIUS, topRight: BOTTOM_SHEET_RADIUS);
}

/// Row for one Stats field
class StatsRow extends StatelessWidget {
  final String left;
  final String right;

  StatsRow(this.left, this.right);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(left), Text(right)],
      ),
    );
  }
}
