// ignore_for_file: unnecessary_null_comparison

import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Paint 4 Kids',
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

class _MyHomePageState extends State<MyHomePage> {
  List<DrawingArea> points = [];
  late Color selectedColor;
  late double strokeWidth;

  @override
  void initState() {
    super.initState();
    selectedColor = Colors.black;
    strokeWidth = 2.0;
  }

  void selectColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Choose Your Color"),
        content: SingleChildScrollView(
          child: BlockPicker(
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
              child: Text('Close'))
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
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text(widget.title),
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
                  width: width * 0.8,
                  height: height * 0.8,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 5.0,
                            spreadRadius: 1.0),
                      ]),
                  child: GestureDetector(
                    onPanDown: (details) {
                      this.setState(() {
                        points.add(DrawingArea(
                            point: details.localPosition,
                            areaPaint: Paint()
                              ..strokeCap = StrokeCap.round
                              ..isAntiAlias = true
                              ..color = selectedColor
                              ..strokeWidth = strokeWidth));
                        print("down");
                        print(details.localPosition);
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
                        print("update");
                        print(details.localPosition);
                      });
                    },
                    onPanEnd: (details) {
                      this.setState(() {
                        // ignore: dead_code
                        points.add(DrawingArea(
                            point: Offset.zero, areaPaint: Paint()));
                      });
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      child: CustomPaint(
                        painter: MyCustomPainter(points: points),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: width * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          selectColor();
                        },
                        icon: Icon(Icons.color_lens),
                        iconSize: 20,
                        color: selectedColor,
                      ),
                      Expanded(
                          child: Slider(
                              min: 1.0,
                              max: 7.0,
                              activeColor: selectedColor,
                              value: strokeWidth,
                              onChanged: (value) {
                                this.setState(() {
                                  strokeWidth = value;
                                });
                              })),
                      IconButton(
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
                )
              ],
            ),
          )
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
    Paint background = Paint()..color = Colors.white;
    Rect box = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawRect(box, background);
    DrawingArea endPan =
        new DrawingArea(point: Offset.zero, areaPaint: Paint());
    // Paint drawing = Paint();
    // drawing.color = Colors.black;
    // drawing.strokeWidth = 2;
    // drawing.isAntiAlias = true;
    // drawing.strokeCap = StrokeCap.round;

    for (int x = 0; x < points.length - 1; x++) {

      if (points[x].point != Offset.zero && points[x + 1].point != Offset.zero) {
        Paint drawing = points[x].areaPaint;
        canvas.drawLine(points[x].point, points[x + 1].point, drawing);
      } else if (points[x].point != Offset.zero && points[x + 1].point == Offset.zero) {
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
