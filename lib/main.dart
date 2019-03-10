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
      theme: ThemeData(
        primaryColor: Colors.white,
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
  Color _baseColor = Colors.deepPurpleAccent;
  ShadesMode _mode = ShadesMode.neutral;

  void _menuItemSelected(ShadesMode mode) {
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
                pickerColor: _baseColor,
                onColorChanged: _colorChanged,
                enableLabel: true,
                pickerAreaHeightPercent: 0.8,
              )));
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
              onPressed: () {
                _changeColor(context);
              },
            ),
            PopupMenuButton(
              icon: Icon(Icons.tune),
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                      value: ShadesMode.neutral, child: Text('Neutral')),
                  PopupMenuItem(
                      value: ShadesMode.warmToCold,
                      child: Text('Warm to Cold')),
                  PopupMenuItem(
                      value: ShadesMode.coldToWarm,
                      child: Text('Cold to Warm')),
                ];
              },
              onSelected: _menuItemSelected,
            )
          ],
        ),
        body: Shades(
          baseColor: _baseColor,
          count: 5,
          mode: _mode,
        ));
  }
}

enum ShadesMode { warmToCold, neutral, coldToWarm }

class Shades extends StatelessWidget {
  Shades({@required this.baseColor, @required this.count, @required this.mode});

  final Color baseColor;
  final int count;
  final ShadesMode mode;

  @override
  Widget build(BuildContext context) {
    List<Color> colors = [baseColor];
    int step = (255 / (2 * count + 1)).floor();

    List.generate(count, (int index) => index + 1).forEach((int index) {
      Color nextColor = Color(baseColor.value)
          .withRed(min(
              (baseColor.red +
                      step * index * (mode == ShadesMode.coldToWarm ? 2 : 1))
                  .round(),
              255))
          .withGreen(min(baseColor.green + step * index, 255))
          .withBlue(min(
              (baseColor.blue +
                      step * index * (mode == ShadesMode.warmToCold ? 2 : 1))
                  .round(),
              255));

      Color prevColor = Color(baseColor.value)
          .withRed(max(
              (baseColor.red -
                      step * index * (mode == ShadesMode.warmToCold ? 0.5 : 1))
                  .round(),
              0))
          .withGreen(max(baseColor.green - step * index, 0))
          .withBlue(max(
              (baseColor.blue -
                      step * index * (mode == ShadesMode.coldToWarm ? 0.5 : 1))
                  .round(),
              0));

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: colors
          .map((color) => Expanded(
                child: ColorItem(color: color),
              ))
          .toList(),
    );
  }
}

class ColorItem extends StatelessWidget {
  ColorItem({@required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(color: color);
  }
}
