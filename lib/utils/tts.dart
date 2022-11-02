import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

class TTSHelper {
  static FlutterTts flutterTts = FlutterTts();

  static Future speak(String text) async {
    var result = await flutterTts.speak(text);
    return result;
  }

  static Future stop() async {
    var result = await flutterTts.stop();
    return result;
  }
}
