import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:money_reader/utils/tf_lite_helper.dart';
import 'package:money_reader/utils/tts.dart';

class CameraHelper {
  static late CameraController camera;

  static bool isDetecting = false;
  static const CameraLensDirection _direction = CameraLensDirection.back;
  static Future<void>? initializeControllerFuture;

  static Future<CameraDescription> _getCamera(CameraLensDirection dir) async {
    return await availableCameras()
        .then((List<CameraDescription> cameras) => cameras.firstWhere(
              (CameraDescription camera) => camera.lensDirection == dir,
            ));
  }

  static void initializeCamera() async {
    debugPrint("Initializing camera..");

    camera = CameraController(
      await _getCamera(_direction),
      ResolutionPreset.ultraHigh,
      enableAudio: false,
    );

    initializeControllerFuture = camera.initialize().then((value) {
      camera.setFlashMode(FlashMode.torch);
      debugPrint("Camera initialized, starting camera stream...");
      TTSHelper.speak('Please place the object in front of the camera')
          .whenComplete(() {
        // camera.startImageStream((CameraImage image) {
        //   if (!TFLiteHelper.modelLoaded) return;
        //   if (isDetecting) return;
        //   isDetecting = true;
        //   try {
        //     TFLiteHelper.classifyImage(image);
        //   } catch (e) {
        //     print(e);
        //   }
        // });
      });
    });
  }

  static void takePicture() {
    camera.takePicture().then((value) {
      if (!TFLiteHelper.modelLoaded) return;
      if (isDetecting) return;
      isDetecting = true;
      print(value.path);

      try {
        TFLiteHelper.classifyImage(value);
      } catch (e) {
        print(e);
      }
    });
  }
}
