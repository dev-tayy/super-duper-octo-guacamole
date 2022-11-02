import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:money_reader/models/result.dart';
import 'package:money_reader/utils/tts.dart';
import 'package:tflite/tflite.dart';

class TFLiteHelper {
  static StreamController<List<Result>> tfLiteResultsController =
      StreamController.broadcast();
  static final List<Result> _outputs = [];
  static List<Result> output2 = [];

  List<Result> get outputs => output2;

  static bool modelLoaded = false;

  static Future<String?> loadModel() async {
    debugPrint("Loading model..");

    return Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  static classifyImage(XFile ximage) async {
    // await Tflite.detectObjectOnFrame(
    //   bytesList: image.planes.map((plane) {
    //     return plane.bytes;
    //   }).toList(),
    //   imageHeight: image.height,
    //   imageWidth: image.width,
    //   numResultsPerClass: 1,
    // ).then((value) {
    //   print('valueee $value');
    //   if (value!.isNotEmpty) {
    //     //debugPrint("Results loaded. ${value.length}");

    //     //Clear previous results
    //     _outputs.clear();

    //     for (var element in value) {
    //       _outputs.add(Result(
    //           element['confidence'], element['index'], element['label']));

    //       // debugPrint(
    //       //     "classifyImage::: ${element['confidence']} , ${element['index']}, ${element['label']}");
    //     }
    //   }

    //   //Sort results according to most confidence
    //   _outputs.sort((a, b) => a.confidence.compareTo(b.confidence));

    //   //Send results
    //   tfLiteResultsController.add(_outputs);
    // });

    // await Tflite.runModelOnFrame(
    //         bytesList: image.planes.map((plane) {
    //           return plane.bytes;
    //         }).toList(),
    //         imageHeight: image.height,
    //         imageWidth: image.width,
    //         numResults: 4,
    //         threshold: 0.1)
    //     .then((value) {
    //   print('valueee $value');
    //   if (value!.isNotEmpty) {
    //     //Clear previous results
    //     _outputs.clear();
    //     output2.clear();

    //     for (var element in value) {
    //       print(element);
    //       _outputs.add(Result(
    //           element['confidence'], element['index'], element['label']));
    //     }
    //   }
    //   //Send results
    //   output2 = _outputs;

    //   Future.delayed(const Duration(seconds: 3), () {
    //     tfLiteResultsController.add(output2);
    //     if (output2[0].confidence > 0.8) {
    //       TTSHelper.speak(output2[0].label.substring(2));
    //     } else {
    //       TTSHelper.speak("Can't detect currency");
    //     }
    //   });
    // });

    await Tflite.runModelOnImage(
      path: ximage.path,
      numResults: 5,
      threshold: 0.1,
    ).then((value) {
      print(value);
      if (value!.isNotEmpty) {
        //debugPrint("Results loaded. ${value.length}");

        //Clear previous results
        _outputs.clear();
        print('this is first output $value');

        for (var element in value) {
          print('element $element');
          _outputs.add(Result(
              element['confidence'], element['index'], element['label']));
        }

        //Send results
        Future.delayed(const Duration(seconds: 0), () {
          tfLiteResultsController.add(_outputs);
          if (_outputs[0].confidence > 0.8) {
            TTSHelper.speak(_outputs[0].label.substring(2));
          } else {
            TTSHelper.speak("Can't detect currency");
          }
        });
      }
    });
  }

  static void disposeModel() {
    Tflite.close();
    tfLiteResultsController.close();
  }
}
