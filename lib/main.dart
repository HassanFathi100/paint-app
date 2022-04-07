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
      title: 'Painter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Painter'),
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
int eraserFlag =
    0; // 0: Eraser NOT pressed - 1: Eraser pressed - 2: Brush pressed

class _MyHomePageState extends State<MyHomePage> {
  List<DrawingArea> points = [];
  late Color selectedColor;
  late double strokeWidth;
  late double eraserStrokeWidth;
  late Color lastSelectedColor;

  final controller = ScreenshotController();
  final widgetImageController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    selectedColor = Colors.black;
    lastSelectedColor = Colors.black;
    canvasColor = Colors.white;
    strokeWidth = 2.0;
    eraserStrokeWidth = 2 * strokeWidth;
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
                lastSelectedColor = color;
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
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
              left: width * 0.1,
              right: width * 0.1,
              bottom: height * 0.05,
              child: Container(
                width: width * 0.8,
                height: height * 0.05,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
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
                      tooltip: 'Brush',
                      onPressed: () {
                        // if eraser not pressed
                        if (eraserFlag == 0) {
                          selectedColor = Colors.black;
                          eraserFlag = 2;

                          // if eraser is pressed but brush not pressed
                        } else if (eraserFlag == 1) {
                          selectedColor = lastSelectedColor;

                          // if brush is pressed
                        } else if (eraserFlag == 2) {
                          return;
                        }
                      },
                      icon: Icon(Icons.brush),
                      iconSize: 20,
                      color: Colors.black,
                    ),
                    IconButton(
                      // Brush color
                      tooltip: 'Choose Color',
                      onPressed: () {
                        selectBrushColor();
                      },
                      icon: Icon(Icons.color_lens),
                      iconSize: 20,
                    ),
                    Expanded(
                        child: Slider(
                            min: 1.0,
                            max: 15.0,
                            activeColor: Colors.black,
                            value: strokeWidth,
                            onChanged: (value) {
                              this.setState(() {
                                strokeWidth = value;
                              });
                            })),
                    IconButton(
                      // Eraser
                      tooltip: 'Eraser',
                      onPressed: () {
                        eraserFlag = 1;
                        setState(() {
                          selectedColor = Colors.white;
                        });
                      },
                      icon: Icon(MyCustomIcons.eraser_fill),
                      iconSize: 20,
                    ),
                    IconButton(
                      // Clear Canvas
                      tooltip: 'Clear',
                      onPressed: () {
                        eraserFlag = 1;
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
        floatingActionButton: FloatingActionButton(
            tooltip: 'Save to Gallery',
            child: Icon(Icons.save),
            onPressed: () async {
              final paintingImage = await widgetImageController.capture();

              if (paintingImage == null) return;
              await saveImage(paintingImage);

              final snackBar = SnackBar(
                content: Text('Your ART is saved in the gallery'),
                action: SnackBarAction(
                  label: 'Dismiss',
                  onPressed: () {},
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop);
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
