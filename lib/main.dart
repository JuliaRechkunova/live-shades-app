import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() => runApp(MyApp());

final String appTitle = 'Perfect Shades';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(primaryColor: Colors.white),
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
  Color _baseColor = Colors.deepPurpleAccent;
  Mode _mode = Mode.neutral;

  void _modeChanged(Mode mode) {
    setState(() => _mode = mode);
  }

  void _colorChanged(Color color) {
    setState(() => _baseColor = color);
  }

  void _changeColor(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Change base color'),
              content: SingleChildScrollView(
                  child: ColorPicker(
                      pickerColor: _baseColor, onColorChanged: _colorChanged)));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.palette),
              onPressed: () => _changeColor(context),
            ),
            PopupMenuButton(
              icon: Icon(Icons.tune),
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(value: Mode.neutral, child: Text('Neutral')),
                  PopupMenuItem(
                      value: Mode.warmToCold, child: Text('Warm to Cold')),
                  PopupMenuItem(
                      value: Mode.coldToWarm, child: Text('Cold to Warm')),
                ];
              },
              onSelected: _modeChanged,
            )
          ],
        ),
        body: Shades(baseColor: _baseColor, count: 5, mode: _mode));
  }
}

enum Mode { warmToCold, neutral, coldToWarm }

class Shades extends StatelessWidget {
  Shades({@required this.baseColor, @required this.count, @required this.mode});

  final Color baseColor;
  final int count;
  final Mode mode;

  int down(int c, int value, bool dominating) =>
      max((c - value * (dominating ? 0.5 : 1)).round(), 0);

  int up(int c, int value, bool dominating) =>
      min((c + value * (dominating ? 1.5 : 1)).round(), 255);

  @override
  Widget build(BuildContext context) {
    List<Color> colors = [baseColor];
    int step = (255 / (2 * count + 1)).floor();

    List.generate(count, (int index) => index + 1).forEach((int index) {
      int value = step * index;
      Color hColor = Color(baseColor.value)
          .withRed(up(baseColor.red, value, mode == Mode.coldToWarm))
          .withGreen(up(baseColor.green, value, false))
          .withBlue(up(baseColor.blue, value, mode == Mode.warmToCold));

      Color sColor = Color(baseColor.value)
          .withRed(down(baseColor.red, value, mode == Mode.warmToCold))
          .withGreen(down(baseColor.green, value, false))
          .withBlue(down(baseColor.blue, value, mode == Mode.coldToWarm));

      colors.add(hColor);
      colors.insert(0, sColor);
    });

    return ColorList(colors: colors);
  }
}

class ColorList extends StatelessWidget {
  ColorList({@required this.colors});

  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: colors
          .map((color) => Expanded(
                child: Container(color: color),
              ))
          .toList(),
    );
  }
}
