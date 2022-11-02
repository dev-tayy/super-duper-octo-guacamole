import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_reader/models/result.dart';
import 'package:money_reader/utils/camera.dart';
import 'package:money_reader/utils/tf_lite_helper.dart';
import 'package:money_reader/utils/tts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Money Reader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DetectScreen(),
    );
  }
}

class DetectScreen extends StatefulWidget {
  const DetectScreen({Key? key}) : super(key: key);

  @override
  _DetectScreenPageState createState() => _DetectScreenPageState();
}

class _DetectScreenPageState extends State<DetectScreen>
    with TickerProviderStateMixin {
  bool isDetecting = true;

  List<Result> outputs = [];
  List<Result> outputs2 = [];

  @override
  void initState() {
    super.initState();

    TTSHelper.speak('Please wait while we run the model').then((value) {
      //Load TFLite Model
      TFLiteHelper.loadModel().then((value) {
        setState(() {
          TFLiteHelper.modelLoaded = true;
        });
      });

      //Initialize Camera
      CameraHelper.initializeCamera();

      //Subscribe to TFLite's Classify events
      TFLiteHelper.tfLiteResultsController.stream.listen(
          (value) {
            //Set Results
            outputs = value;

            //Update results on screen
            setState(() {
              //Set bit to false to allow detection again
              CameraHelper.isDetecting = false;
              isDetecting = false;
            });
          },
          onDone: () {},
          onError: (error) {
            debugPrint("listen $error");
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    print(CameraHelper.isDetecting);
    // if (!isDetecting) {
    //   if (outputs[0].confidence > 0.8) {
    //     TTSHelper.speak(outputs[0].label.substring(2));
    //   }
    // }

    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Reader'),
      ),
      body: FutureBuilder<void>(
        future: CameraHelper.initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            print('outputss  $outputs');
            return GestureDetector(
              onTap: (){
                CameraHelper.takePicture();
              },
              child: Stack(
                children: <Widget>[
                  CameraPreview(CameraHelper.camera),
                  _buildResultsWidget(width, outputs)
                ],
              ),
            );
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    TFLiteHelper.disposeModel();
    CameraHelper.camera.dispose();
    super.dispose();
  }

  Widget _buildResultsWidget(double width, List<Result> outputs) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 200.0,
          width: width,
          color: Colors.white,
          child: outputs.isNotEmpty
              ? ListView.builder(
                  itemCount: outputs.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(20.0),
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: <Widget>[
                        Text(
                          outputs[index].label,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                          ),
                        ),
                        Text(
                          "${(outputs[index].confidence * 100.0).toStringAsFixed(2)} %",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    );
                  })
              : const Center(
                  child: Text("Waiting for model to detect..",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                      ))),
        ),
      ),
    );
  }

  //  List<Widget> renderBoxes(Size screen, List<Result> _recognitions) {
  //   if (_imageWidth == null || _imageHeight == null) return [];

  //   double factorX = screen.width;
  //   double factorY = _imageHeight / _imageHeight * screen.width;

  //   Color blue = Colors.blue;

  //   return _recognitions.map((re) {
  //     return Container(
  //       child: Positioned(
  //         left: re["rect"]["x"] * factorX,
  //         top: re["rect"]["y"] * factorY,
  //         width: re["rect"]["w"] * factorX,
  //         height: re["rect"]["h"] * factorY,
  //         child: ((re["confidenceInClass"] > 0.50))? Container(
  //             decoration: BoxDecoration(
  //               border: Border.all(
  //               color: blue,
  //               width: 3,
  //             )
  //           ),
  //           child: Text(
  //             "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
  //             style: TextStyle(
  //               background: Paint()..color = blue,
  //               color: Colors.white,
  //               fontSize: 15,
  //             ),
  //           ),
  //         ) : Container()
  //       ),
  //     );
  //   }).toList();
  // }

}
