import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:convert';

//Example usage:
// String imgString = base64String(new File(path).readAsBytesSync());
// Image _image = ImageUtils.imageFromBase64String(imgString);
class ImageUtils {
  //Converts image into base 64 string
  Image imageFromBase64String(String base64String) {
    return Image.memory(
      base64Decode(base64String),
      fit: BoxFit.fill,
    );
  }

  //Converts base 64 string to unsigned 8 bit integers
  Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  //Converts unsigned 8 bit integers to base 64 string
  String base64String(Uint8List data) {
    return base64Encode(data);
  }
}
