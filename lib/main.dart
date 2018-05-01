import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(new CalcApp());

class CalcApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Ricalc',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.green,
      ),
      home: Ricalc(title: 'Flutter Ricalc'),
    );
  }
}

class Ricalc extends StatefulWidget {
  Ricalc({Key key, this.title}) : super(key: key);
  final String title;

  @override
  RicalcState createState() => new RicalcState();
}

/// Class that builds the layout, doesn't have state
class RicalcLayout extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final state = DataHolder.of(context);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Flutter Ricalc"),
      ),
      body: new Column(
        children: <Widget>[
          Expanded(
            child: new Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.green.withOpacity(0.25),
              child: Row(
                children: <Widget>[
                  Text(
                    state.inputValue ?? '0',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 48.0, 
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: new Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  generateButtons('Cs%:'),
                  generateButtons('789x'),
                  generateButtons('456-'),
                  generateButtons('123+'),
                  generateButtons('0d.=')
                ],
              )
            ),
          )
        ],
      ),
    );
  }
}

class RicalcState extends State<Ricalc> {
  String input = "";
  double value;
  String op = "q";
  bool resultShown = false;
  
  bool isNumber(String numberString) {
    if (numberString == null) {
      return false;
    } else {
      return double.parse(numberString, (e) => null) != null;
    }
  }

  void pressButton(keyvalue) {
    switch(keyvalue) {
      case 'C':
        op = null;
        value = 0.0;
        setState(() => input = "");
        break;
      case '+':
      case '-':
      case '\u{00F7}':
      case '\u{00D7}':
      case '%':
        op = keyvalue;
        if (!resultShown) {
          value = double.parse(input);
        }
        setState(() => input = "");
        break;
      case "=":
        if (op != null && op != 'q') {
          resultShown = true;
          setState(() {
            switch(op) {
              case '\u{00D7}':
                value *= double.parse(input);
                input = value.toStringAsFixed(4);
                break;
              case '\u{00F7}':
                value /= double.parse(input);
                input = value.toStringAsFixed(4);
                break;
              case '+':
                value += double.parse(input);
                input = value.toStringAsFixed(4);
                break;
              case '-':
                value -= double.parse(input);
                input = value.toStringAsFixed(4);
                break;
              case '%':
                value %= double.parse(input);
                input = value.toStringAsFixed(4);
                break;
            }
          });
        }
        break;
      case 'd':
        setState(() => input = input + "00");
        break;
      case '\u{221A}':
        double currentValue = double.parse(input);
        currentValue = sqrt(currentValue);
        value = currentValue;
        setState(() => input = currentValue.toStringAsPrecision(4));
        break;
      default:
        if (isNumber(keyvalue) || keyvalue == '.') {
          if (resultShown) {
            resultShown = false;
            setState(() => input = keyvalue);
          } else {
            setState(() => input = input + keyvalue);
          }
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DataHolder(
      inputValue: input,
      value: value,
      op: op,
      onPressed: pressButton,
      child: RicalcLayout(),
    );
  }
}

/// DataHolder does nothing but keeps the data
class DataHolder extends InheritedWidget {
  DataHolder({
    Key key,
    this.inputValue,
    this.prevValue,
    this.value,
    this.op,
    this.onPressed,
    Widget child
  }) : super(key: key, child: child);

  final String inputValue;
  final double prevValue;
  final double value;
  final String op;
  final Function onPressed;

  static DataHolder of (BuildContext context) {
    return context.inheritFromWidgetOfExactType(DataHolder);
  }

  @override
  bool updateShouldNotify(DataHolder oldWidget) {
    return inputValue != oldWidget.inputValue;
  }
}

Widget generateButtons(String row) {
  List<String> token = row.split("");
  return Expanded(
    flex: 1,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: token.map((e) => new CalculatorButton(
        keyvalue: e == 's' ? "\u{221A}" : e == 'd' ? "00" : e == 'x' ? "\u{00D7}" : e == ':' ? "\u{00F7}" : e,
      )).toList(),
    )
  );
}

class CalculatorButton extends StatelessWidget {
  CalculatorButton({this.keyvalue});

  final String keyvalue;

  @override
  Widget build(BuildContext context) {
    final state = DataHolder.of(context);
    return Expanded(
      flex: 1,
      child: FlatButton(
        color: Colors.white,
        child: Text(
          keyvalue,
          style: TextStyle(
            color: Colors.black,
            fontSize: 36.0,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.normal
          ),
        ),
        onPressed: () {
          state.onPressed(keyvalue);
        },
      )
    );
  } 
}