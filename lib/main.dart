import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:share/share.dart';

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
  ShadesScreenState createState() => ShadesScreenState();
}

class ShadesScreenState extends State<ShadesScreen> {
  Color _baseColor = Colors.deepPurpleAccent;
  Mode _mode = Mode.neutral;
  int _count = 5;

  List<Color> get _colors {
    List<Color> colors = [_baseColor];
    int step = (255 / (2 * _count + 1)).floor();

    List.generate(_count, (int index) => index + 1).forEach((int index) {
      int value = step * index;
      Color hColor = Color(_baseColor.value)
          .withRed(up(_baseColor.red, value, _mode == Mode.coldToWarm))
          .withGreen(up(_baseColor.green, value, false))
          .withBlue(up(_baseColor.blue, value, _mode == Mode.warmToCold));

      Color sColor = Color(_baseColor.value)
          .withRed(down(_baseColor.red, value, _mode == Mode.warmToCold))
          .withGreen(down(_baseColor.green, value, false))
          .withBlue(down(_baseColor.blue, value, _mode == Mode.coldToWarm));

      colors.add(hColor);
      colors.insert(0, sColor);
    });

    return colors;
  }

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

  int down(int c, int value, bool dominating) =>
      max((c - value * (dominating ? 0.5 : 1)).round(), 0);

  int up(int c, int value, bool dominating) =>
      min((c + value * (dominating ? 1.5 : 1)).round(), 255);

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
            ),
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                Share.share(_colors
                    .map((color) =>
                        '#${color.value.toRadixString(16).substring(2)}')
                    .join('\n'));
              },
            ),
          ],
        ),
        body: ColorList(colors: _colors));
  }
}

enum Mode { warmToCold, neutral, coldToWarm }

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
