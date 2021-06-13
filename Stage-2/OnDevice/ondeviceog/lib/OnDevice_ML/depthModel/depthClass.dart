import 'package:image/image.dart' as imageLib;

import 'package:logger/logger.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

import 'dart:async';

class depthModel {
  Interpreter interpreter;
  InterpreterOptions _interpreterOptions;

  var logger = Logger();

  List<int> _inputShape;
  List<int> _outputShape;

  imageLib.Image Test;

  TensorImage _inputImage;
  TensorBuffer _outputBuffer;
  TensorImage _outputImage;

  TfLiteType _outputType = TfLiteType.float32;

  var _outBufferProcessor;

  depthModel({Interpreter interpreter}) {
    final gpuDelegate = GpuDelegate(
      options: GpuDelegateOptions(true, TFLGpuDelegateWaitType.active),
    );
    _interpreterOptions = InterpreterOptions()..addDelegate(gpuDelegate);
    _interpreterOptions = InterpreterOptions();
    _interpreterOptions.threads = 2;
    loadModel(interpreter);
  }

  void loadModel(Interpreter inputInterpreter) async {
    try {
      interpreter = inputInterpreter ??
          await Interpreter.fromAsset("midas.tflite",
              options: _interpreterOptions);
      print('Interpreter Created Successfully');

      // print('Interpreter loaded successfully');
      interpreter.allocateTensors();

      // print(interpreter.getInputTensors());

      // print(interpreter.getOutputTensors());

      _inputShape = interpreter.getInputTensor(0).shape;
      _outputShape = interpreter.getOutputTensor(0).shape;
      _outputType = interpreter.getOutputTensor(0).type;

      // print(interpreter.getInputTensor(0).type);
      // print(_inputShape[1]);
      // print(_inputShape[2]);

      _outputBuffer = TensorBuffer.createFixedSize(_outputShape, _outputType);
      _outBufferProcessor =
          TensorProcessorBuilder().add(NormalizeOp(0.0, 255.0)).build();
    } catch (e) {
      print('Unable to create interpreter, Caught Exception: ${e.toString()}');
    }
  }

  TensorImage _preProcess() {
    return ImageProcessorBuilder()
        .add(ResizeOp(
            _inputShape[1], _inputShape[2], ResizeMethod.NEAREST_NEIGHBOUR))
        .add(NormalizeOp(0.0, 255.0))
        .build()
        .process(_inputImage);
  }

  TensorImage _postProcess() {
    return ImageProcessorBuilder()
        .add(new Rot90Op(1))
        .build()
        .process(_outputImage);
  }

  Future<List<int>> predict(imageLib.Image image) async {
    if (interpreter == null) {
      throw StateError('Cannot run inference, Intrepreter is null');
    }
    final pres = DateTime.now().millisecondsSinceEpoch;

    _inputImage = TensorImage.fromImage(image);
    _inputImage = _preProcess();
    final pre = DateTime.now().millisecondsSinceEpoch - pres;

    print('Time to load image: $pre ms');

    var k = _inputImage.buffer.asFloat32List();

    final runs = DateTime.now().millisecondsSinceEpoch;
    interpreter.run(_inputImage.buffer, _outputBuffer.getBuffer());
    final run = DateTime.now().millisecondsSinceEpoch - runs;

    print('Time to run inference: $run ms');

    List<int> Test = [for (var i = 0; i < 65025; i += 1) 0];

    var testret = imageLib.Image.fromBytes(255, 255, Test);
    imageLib.Image convertTensorBufferToImage(
        TensorBuffer buffer, imageLib.Image image) {
      List<int> shape = buffer.getShape();
      int h = 256;
      int w = 256;
      var bufferList = buffer.getDoubleList();

      var maxval = bufferList[0];
      var minval = bufferList[0];

      for (var i = 0; i < bufferList.length; i++) {
        if (bufferList[i] > maxval) {
          maxval = bufferList[i];
        }
        if (bufferList[i] < minval) {
          minval = bufferList[i];
        }
      }

      for (int i = 0, j = 0, wi = 0, hi = 0; j < bufferList.length; i++) {
        var r = (bufferList[j++] - minval) * (255 / (maxval - minval));

        int val = r.round();

        int finalVal = 4278190080 + val;

        image.setPixel(wi, hi, finalVal);

        wi++;
        if (wi % w == 0) {
          wi = 0;

          hi++;
        }
      }

      var k = image.data;
      var t = 0;
      var l = 0;
      for (var i = 0; i < k.length; i++) {
        if (k[i] > maxval) {
          t = k[i];
        }
        if (k[i] < minval) {
          l = k[i];
        }
      }

      // print('Max is $t and Min is $l');
      var immm = image.data;
      // print("OP is:$immm");
      return testret;
    }

    var imageop = convertTensorBufferToImage(_outputBuffer, image);
    // print(imageop);
    var bytes = imageLib.PngEncoder().encodeImage(image);

    return bytes;
  }

  void close() {
    if (interpreter != null) {
      interpreter.close();
    }
  }
}
