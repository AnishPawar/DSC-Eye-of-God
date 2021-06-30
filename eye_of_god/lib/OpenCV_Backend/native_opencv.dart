import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'dart:convert';
import 'dart:convert' show utf8;

typedef _version_func = ffi.Pointer<Utf8> Function();

typedef sendToCVCPP = ffi.Pointer<Utf8> Function(
    ffi.Pointer<ffi.Int32> image,
    ffi.Pointer<ffi.Int32> coorList,
    ffi.Pointer<ffi.Int32> Labels,
    ffi.Pointer<ffi.Int32> coorlength);
typedef sendToCVCPP1 = ffi.Pointer<Utf8> Function(
    ffi.Pointer<ffi.Int32> image,
    ffi.Pointer<ffi.Int32> coorList,
    ffi.Pointer<ffi.Int32> Labels,
    ffi.Pointer<ffi.Int32> coorlength);

typedef signalColor0 = ffi.Pointer<Utf8> Function(ffi.Pointer<ffi.Int32> image,
    ffi.Pointer<ffi.Int32> coorList, ffi.Pointer<ffi.Int32> coorlength);
typedef signalColor1 = ffi.Pointer<Utf8> Function(ffi.Pointer<ffi.Int32> image,
    ffi.Pointer<ffi.Int32> coorList, ffi.Pointer<ffi.Int32> coorlength);

ffi.DynamicLibrary _lib = Platform.isAndroid
    ? ffi.DynamicLibrary.open('libnative_opencv.so')
    : ffi.DynamicLibrary.process();

// Looking for the functions
final _version_func _version =
    _lib.lookup<ffi.NativeFunction<_version_func>>('version').asFunction();

String opencvVersion() {
  var charPointer = _version();
  return charPointer.toDartString();
}

String sendToCV(dynamic ipImage, List<int> coorListIp, dynamic labelListIP) {
  print("Going");

  int length1 = coorListIp.length;
  List<int> coorLength1 = [length1];

  final imagePtr = intListToArray(ipImage);
  final coorListIPPointer = intListToArray(coorListIp);
  final labelListIPPointer = intListToArray(labelListIP);
  final coorLen = intListToArray(coorLength1);

  // print("test list:${labelListIP}");

  final funcPointer = _lib.lookup<ffi.NativeFunction<sendToCVCPP>>('cvProcess');
  final functionCV = funcPointer.asFunction<sendToCVCPP1>();
  var motorOP =
      functionCV(imagePtr, coorListIPPointer, labelListIPPointer, coorLen);

  // print("Returned OP is: ${motorOP.toDartString()}");
  return motorOP.toDartString();
}

String sendToCVIndoor(dynamic ipImage) {
  print("Going");

  List<int> coorLength1 = [0];

  final imagePtr = intListToArray(ipImage);
  final coorListIPPointer = intListToArray([0, 0, 0, 0]);
  final labelListIPPointer = intListToArray([0, 0, 0, 0]);
  final coorLen = intListToArray(coorLength1);

  // print("test list:${labelListIP}");

  final funcPointer = _lib.lookup<ffi.NativeFunction<sendToCVCPP>>('cvProcess');
  final functionCV = funcPointer.asFunction<sendToCVCPP1>();
  var motorOP =
      functionCV(imagePtr, coorListIPPointer, labelListIPPointer, coorLen);

  // print("Returned OP is: ${motorOP.toDartString()}");
  return motorOP.toDartString();
}

String sendToTraffic(dynamic ipImage, List<int> coorListIp) {
  print("Going");

  int length1 = coorListIp.length;
  List<int> coorLength1 = [length1];

  final imagePtr = intListToArray(ipImage);
  final coorListIPPointer = intListToArray(coorListIp);
  final coorLen = intListToArray(coorLength1);

  final funcPointer =
      _lib.lookup<ffi.NativeFunction<signalColor0>>('signalColor');
  final functionCV = funcPointer.asFunction<signalColor1>();
  var OP = functionCV(imagePtr, coorListIPPointer, coorLen);

  // print("Returned OP is: ${OP.toDartString()}");
  return OP.toDartString();
}

ffi.Pointer<ffi.Int32> intListToArray(List<int> list) {
  final ptr = malloc.allocate<ffi.Int32>(ffi.sizeOf<ffi.Int32>() * list.length);
  for (var i = 0; i < list.length; i++) {
    ptr.elementAt(i).value = list[i];
  }
  return ptr;
}
