import 'package:matrix2d/matrix2d.dart';

class PostProcessor {
  PostProcessor({this.depthImage});
  List depthImage;

  // Scaling to 0-255
  List convToDec(List depthImageFloat) {
    List<int> rangedDepthImage = [];
    // Finding Max and Min
    var maxval = depthImageFloat[0];
    var minval = depthImageFloat[0];
    for (var i = 0; i < depthImageFloat.length; i++) {
      if (depthImageFloat[i] > maxval) {
        maxval = depthImageFloat[i];
      }
      if (depthImageFloat[i] < minval) {
        minval = depthImageFloat[i];
      }
    }

    for (int j = 0; j < depthImageFloat.length; j++) {
      var r = (depthImageFloat[j] - minval) * (255 / (maxval - minval));
      int val = r.round();
      rangedDepthImage.add(val);
    }
    rangedDepthImage = rangedDepthImage.reshape(255, 255);
    return rangedDepthImage;
  }

  int noObjectFeedback(List depthMap, int quadNumber) {
    int i = 2 * (quadNumber - 1);
    int sumTemp = 0;
    for (int j = 0; j < depthMap.length; j++) {
      for (int k = i; k < (i + 2); k++) {
        var ll = depthMap[j][k];
        sumTemp += int.parse(ll.toString());
      }
    }
    var average = sumTemp / 16;

    if (average >= 120) {
      var mappedOutput = 0.02 * average * average - 3.55 * average + 300;
      return (mappedOutput.round());
    }

    return 0;
  }

  List objectDist(List coords, List depthMap) {
    int x1 = coords[0];
    int y1 = coords[1];
    int x2 = coords[2];
    int y2 = coords[3];

    int quadNumber = 0;
    var horizontalCenter = (x1 + x2) / 2;
    int roundedHorizontalCenter = horizontalCenter.round();
    if (0 < roundedHorizontalCenter && roundedHorizontalCenter <= 64) {
      quadNumber = 1;
    } else if (64 < roundedHorizontalCenter && roundedHorizontalCenter <= 128) {
      quadNumber = 2;
    } else if (128 < roundedHorizontalCenter &&
        roundedHorizontalCenter <= 192) {
      quadNumber = 3;
    } else if (192 < roundedHorizontalCenter &&
        roundedHorizontalCenter <= 255) {
      quadNumber = 4;
    }

    int sumTemp = 0;
    for (int i = x1; i <= x2; i++) {
      for (int j = y1; j <= y2; j++) {
        var ll = depthMap[i][j];
        print(ll);
        sumTemp += int.parse(ll.toString());
      }
    }
    int lenX = x2 - x1;
    int lenY = y2 - y1;
    var average = sumTemp / ((lenX.abs() * lenY.abs()));
    if (average >= 120) {
      var mappedOutput = 0.02 * average * average - 3.55 * average + 300;
      return ([quadNumber, mappedOutput]);
    }

    return [quadNumber, 0];
  }
}
