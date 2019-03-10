import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:share/share.dart';
void main() => runApp(App());
final String appName = 'Shading Palette';
final List<String> shadingModes = ['Neutral', 'Warm to Cold', 'Cold to Warm'];
enum Mode { neutral, warmToCold, coldToWarm }
class App extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) => MaterialApp(title: appName, theme: ThemeData(primaryColor: Colors.white), home: Shades());
}
class Shades extends StatefulWidget {
  @override
  ShadesState createState() => ShadesState();
}
class ShadesState extends State<Shades> {
  final GlobalKey<ScaffoldState> sKey = new GlobalKey<ScaffoldState>();
  Color baseColor = Colors.deepPurpleAccent;
  Mode mode = Mode.neutral;
  int count = 5;
  List<Color> get _colors {
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
    return colors;
  }
  int up(int c, int value, bool faster) => min((c + value * (faster ? 1.5 : 1)).round(), 255);
  int down(int c, int value, bool slower) => max((c - value * (slower ? 0.5 : 1)).round(), 0);
  String toHex(Color c) => '#${c.value.toRadixString(16).substring(2)}';
  void modeChanged(Mode m) { setState(() => mode = m); }
  void colorChanged(Color c) { setState(() => baseColor = c); }
  void changeColor(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (BuildContext _) => AlertDialog(
        title: Text('Change base color'),
        content: SingleChildScrollView(child: ColorPicker(pickerColor: baseColor, onColorChanged: colorChanged))));
  }
  void _onTap(Color c) {
    final snackBar = SnackBar(
      backgroundColor: Colors.white,
      content: Text(toHex(c), style: TextStyle(color: Colors.black87)),
      action: SnackBarAction(label: 'COPY', onPressed: () {Clipboard.setData(ClipboardData(text: toHex(c)));}),
    );
    sKey.currentState.hideCurrentSnackBar();
    sKey.currentState.showSnackBar(snackBar);
  }
  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      key: sKey,
      appBar: AppBar(
        title: Text(appName),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.palette), onPressed: () => changeColor(ctx)),
          PopupMenuButton(
            icon: Icon(Icons.tune),
            itemBuilder: (BuildContext _) {
              return Mode.values
                .map((Mode m) => PopupMenuItem(
                  value: m,
                  child: Text(shadingModes[m.index], style: TextStyle(fontWeight: mode == m ? FontWeight.bold : FontWeight.normal))))
                .toList();
            },
            onSelected: modeChanged,
          ),
          IconButton(icon: Icon(Icons.share), onPressed: () {Share.share(_colors.map((c) => toHex(c)).join('\n'));}),
        ],
      ),
      body: Palette(colors: _colors, onTap: _onTap)
    );
  }
}
class Palette extends StatelessWidget {
  Palette({@required this.colors, @required this.onTap});
  final List<Color> colors;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: colors.map((color) => Expanded(child: GestureDetector(onTap: () {onTap(color);}, child: Container(color: color)))).toList(),
    );
  }
}
