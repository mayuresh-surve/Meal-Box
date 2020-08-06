import 'package:flutter/material.dart';
import 'package:meal_box/root_page.dart';
import 'authentication.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meal Box',
      theme: ThemeData(
        primarySwatch: customPrimary,
      ),
      home: new RootPage(auth: new Auth()),
    );
  }
}

Map<int, Color> color =
{
  50:Color.fromRGBO(9, 62, 96, .1),
  100:Color.fromRGBO(9, 62, 96, .2),
  200:Color.fromRGBO(9, 62, 96, .3),
  300:Color.fromRGBO(9, 62, 96, .4),
  400:Color.fromRGBO(9, 62, 96, .5),
  500:Color.fromRGBO(9, 62, 96, .6),
  600:Color.fromRGBO(9, 62, 96, .7),
  700:Color.fromRGBO(9, 62, 96, .8),
  800:Color.fromRGBO(9, 62, 96, .9),
  900:Color.fromRGBO(9, 62, 96, 1),
};

MaterialColor customPrimary = MaterialColor(0xFF093E60, color);
