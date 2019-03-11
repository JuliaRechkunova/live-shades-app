import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share/share.dart';

void main() => runApp(App());

final String appName = 'Shading Palette';
final List<String> shadingModes = ['Neutral', 'Warm to Cold', 'Cold to Warm', 'Neutral to Warm', 'Neutral to Cold', 'Warm to Neurtal', 'Cold to Neutral', 'Warm to Warm', 'Cold to Cold'];

enum Mode { n, w2c, c2w, n2w, n2c, w2n, c2n, w2w, c2c }

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

  Color baseColor;
  Mode mode = Mode.n;
  int count = 5;

  List<Color> get colors {
    List<Color> colors = [baseColor];
    int step = (255 / (2 * count + 1)).floor();
    List.generate(count, (int index) => index + 1).forEach((int index) {
      int value = step * index;
      Color hColor = Color(baseColor.value)
          .withRed(up(baseColor.red, value, mode == Mode.c2w || mode == Mode.n2w || mode == Mode.w2w))
          .withGreen(up(baseColor.green, value, false))
          .withBlue(up(baseColor.blue, value, mode == Mode.w2c || mode == Mode.n2c || mode == Mode.c2c));
      Color sColor = Color(baseColor.value)
          .withRed(down(baseColor.red, value, mode == Mode.w2c || mode == Mode.w2n || mode == Mode.w2w))
          .withGreen(down(baseColor.green, value, false))
          .withBlue(down(baseColor.blue, value, mode == Mode.c2w || mode == Mode.c2n || mode == Mode.c2c));
      colors.add(hColor);
      colors.insert(0, sColor);
    });
    return colors;
  }

  @override
  void initState() { super.initState(); load(); }

  int up(int c, int value, bool faster) => min((c + value * (faster ? 1.5 : 1)).round(), 255);

  int down(int c, int value, bool slower) => max((c - value * (slower ? 0.5 : 1)).round(), 0);

  String toHex(Color c) => '#${c.value.toRadixString(16).substring(2)}';

  void load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      baseColor = Color(prefs.getInt('color') ?? Colors.deepPurpleAccent.value);
      mode = Mode.values[prefs.getInt('mode') ?? mode.index];
      count = prefs.getInt('count') ?? count;
    });
  }

  void save(key, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value);
  }

  void modeChanged(Mode m) { setState(() => mode = m); save('mode', m.index); }

  void colorChanged(Color c) { setState(() => baseColor = c); save('color', c.value); }

  void countChanged(int c) { setState(() => count = c); save('count', c); }

  void changeColor(BuildContext ctx) {
    showDialog(context: ctx, builder: (BuildContext _) => AlertDialog(
      title: Text('Change base color'),
      content: SingleChildScrollView(child: ColorPicker(enableAlpha: false, pickerColor: baseColor, onColorChanged: colorChanged))));
  }

  void _onTap(Color c) {
    final snackBar = SnackBar(
      backgroundColor: Colors.white,
      content: Text(toHex(c), style: TextStyle(color: Colors.black87)),
      action: SnackBarAction(label: 'COPY', onPressed: () {Clipboard.setData(ClipboardData(text: toHex(c)));}),
    );
    sKey.currentState.hideCurrentSnackBar(); sKey.currentState.showSnackBar(snackBar);
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
              return Mode.values.map((Mode m) => PopupMenuItem(value: m,
                child: Text(shadingModes[m.index], style: TextStyle(fontWeight: mode == m ? FontWeight.bold : FontWeight.normal)))).toList();
            },
            onSelected: modeChanged,
          ),
          PopupMenuButton(
            icon: Icon(Icons.filter_list),
            itemBuilder: (BuildContext _) {
              return [5, 4, 3, 2, 1].map((int c) => PopupMenuItem(value: c,
                child: Text('${c * 2 + 1} shades', style: TextStyle(fontWeight: count == c ? FontWeight.bold : FontWeight.normal)))).toList();
            },
            onSelected: countChanged,
          ),
          IconButton(icon: Icon(Icons.share), onPressed: () {Share.share('$appName (${shadingModes[mode.index]}):\n${colors.map((c) => toHex(c)).join('\n')}');}),
        ],
      ),
      body: baseColor != null ? Palette(colors: colors, onTap: _onTap) : Center(child: CircularProgressIndicator())
    );
  }
}

class Palette extends StatelessWidget {
  Palette({@required this.colors, @required this.onTap});

  final List<Color> colors;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: colors.map((color) => Expanded(child: GestureDetector(onTap: () {onTap(color);}, child: Container(color: color)))).toList(),);
  }
}
