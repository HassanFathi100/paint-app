// ignore_for_file: unnecessary_null_comparison

import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:paint_app/my_custom_icons_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Paint',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Paint'),
    );
  }
}

/// Class that defines the area for each point
/// :Point (Offset): the cartesian coordinates for each drawn point
/// :areaPaint (Paint): it controls the charactristics of each point
class DrawingArea {
  late Offset point;
  late Paint areaPaint;

  DrawingArea({required this.point, required this.areaPaint});
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

late Color canvasColor;
bool eraserFlag = false;

class _MyHomePageState extends State<MyHomePage> {
  List<DrawingArea> points = [];
  late Color selectedColor;
  late double strokeWidth;

  final controller = ScreenshotController();
  final widgetImageController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    selectedColor = Colors.black;
    canvasColor = Colors.white;
    strokeWidth = 2.0;
  }

  Future<String> saveImage(Uint8List bytes) async {
    await [Permission.storage].request();

    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '-')
        .replaceAll(':', '-');

    final name = 'Painting_$time';
    final result = await ImageGallerySaver.saveImage(bytes, name: name);
    return result['filePath'];
  }

  Widget canvas() => CustomPaint(painter: MyCustomPainter(points: points));

  Widget painter() => GestureDetector(
        onPanDown: (details) {
          this.setState(() {
            points.add(DrawingArea(
                point: details.localPosition,
                areaPaint: Paint()
                  ..strokeCap = StrokeCap.round
                  ..isAntiAlias = true
                  ..color = selectedColor
                  ..strokeWidth = strokeWidth));
          });
        },
        onPanUpdate: (details) {
          this.setState(() {
            points.add(DrawingArea(
                point: details.localPosition,
                areaPaint: Paint()
                  ..strokeCap = StrokeCap.round
                  ..isAntiAlias = true
                  ..color = selectedColor
                  ..strokeWidth = strokeWidth));
          });
        },
        onPanEnd: (details) {
          this.setState(() {
            points.add(DrawingArea(point: Offset.zero, areaPaint: Paint()));
          });
        },
        child: ClipRRect(
          // borderRadius: BorderRadius.all(Radius.circular(20)),
          child: canvas(),
        ),
      );

  void selectBrushColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Choose Your Color"),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: (color) {
              this.setState(() {
                selectedColor = color;
              });
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Select'))
        ],
      ),
    );
  }

  void selectCanvasColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Choose Your Color"),
        content: SingleChildScrollView(
          child: MaterialPicker(
            pickerColor: canvasColor,
            onColorChanged: (color) {
              this.setState(() {
                canvasColor = color;
              });
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Select'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  Color.fromARGB(255, 155, 40, 200),
                  Color.fromARGB(255, 46, 22, 182)
                ])),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    width: width,
                    height: height,
                    child: Screenshot(
                        controller: widgetImageController, child: painter())),
              ],
            ),
          ),
          Positioned(
            left: width * 0.25,
            right: width * 0.25,
            bottom: height * 0.05,
            child: Container(
              width: width * 0.65,
              height: height * 0.05,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 5.0,
                      spreadRadius: 1.0),
                ],
              ),
              child: Row(
                children: <Widget>[
                  IconButton(
                    // Brush
                    onPressed: () {
                      selectedColor = Colors.black;
                    },
                    icon: Icon(Icons.brush),
                    iconSize: 20,
                    color: Colors.black,
                  ),
                  IconButton(
                      onPressed: () {
                        selectBrushColor();
                      },
                      icon: Icon(Icons.color_lens)),
                  Expanded(
                      child: Slider(
                          min: 1.0,
                          max: 7.0,
                          activeColor: Colors.black,
                          value: strokeWidth,
                          onChanged: (value) {
                            this.setState(() {
                              strokeWidth = value;
                            });
                          })),
                  IconButton(
                    // Eraser
                    onPressed: () {
                      setState(() {
                        selectedColor = Colors.white;
                      });
                    },
                    icon: Icon(MyCustomIcons.eraser_fill),
                  ),
                  IconButton(
                    // Clear Canvas
                    onPressed: () {
                      setState(() {
                        points.clear();
                      });
                    },
                    icon: Icon(Icons.layers_clear),
                    iconSize: 20,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        foregroundColor: Colors.white,
        // backgroundColor: Color.fromARGB(255, 255, 255, 255),

        children: [
          SpeedDialChild(
              // Load photo
              // backgroundColor: Color.fromARGB(255, 155, 40, 200),
              // foregroundColor: Colors.white,
              child: Icon(Icons.upload_file)),
          SpeedDialChild(
              // Save Painting
              // backgroundColor: Color.fromARGB(255, 155, 40, 200),
              // foregroundColor: Colors.white,
              label: 'Save Painting',
              child: Icon(Icons.save),
              onTap: () async {
                final paintingImage = await widgetImageController.capture();

                if (paintingImage == null) return;
                await saveImage(paintingImage);
              })
        ],
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  List<DrawingArea> points = [];

  MyCustomPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint background = Paint()..color = canvasColor;
    Rect box = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawRect(box, background);
    final blendMode = BlendMode.clear;

    for (int x = 0; x < points.length - 1; x++) {
      if (points[x].point != Offset.zero &&
          points[x + 1].point != Offset.zero) {
        Paint drawing = points[x].areaPaint;
        canvas.drawLine(points[x].point, points[x + 1].point, drawing);
      } else if (points[x].point != Offset.zero &&
          points[x + 1].point == Offset.zero) {
        Paint drawing = points[x].areaPaint;
        canvas.drawPoints(PointMode.points, [points[x].point], drawing);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
