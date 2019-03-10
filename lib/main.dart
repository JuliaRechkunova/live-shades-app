import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

final String appTitle = 'Perfect Shades';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        primaryColor: Color(0xff383838),
      ),
      home: ShadesScreen(title: appTitle),
    );
  }
}

class ShadesScreen extends StatefulWidget {
  ShadesScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ShadesScreenState createState() => _ShadesScreenState();
}

class _ShadesScreenState extends State<ShadesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Shades(
          baseColor: Colors.deepPurpleAccent,
          count: 5,
        ));
  }
}

class Shades extends StatelessWidget {
  Shades({@required this.baseColor, @required this.count});

  final Color baseColor;
  final int count;

  @override
  Widget build(BuildContext context) {
    List<Color> colors = [baseColor];
    int step = (255 / (2 * count + 1)).floor();

    List.generate(count, (int index) => index + 1).forEach((int index) {
      Color nextColor = Color(baseColor.value)
          .withRed(min(baseColor.red + step * index, 255))
          .withGreen(min(baseColor.green + step * index, 255))
          .withBlue(min(baseColor.blue + step * index, 255));

      Color prevColor = Color(baseColor.value)
          .withRed(max(baseColor.red - step * index, 0))
          .withGreen(max(baseColor.green - step * index, 0))
          .withBlue(max(baseColor.blue - step * index, 0));

      colors.add(nextColor);
      colors.insert(0, prevColor);
    });

    return ColorList(colors: colors);
  }
}

class ColorList extends StatelessWidget {
  ColorList({@required this.colors});

  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: colors.length,
        itemBuilder: (BuildContext context, int position) {
          return ColorItem(color: colors[position]);
        });
  }
}

class ColorItem extends StatelessWidget {
  ColorItem({@required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(color: color),
      child: Text('#${color.value.toRadixString(16).substring(2)}'),
    );
  }
}
