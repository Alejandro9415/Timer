import 'package:flutter/material.dart';
import 'package:timer/screen/home_page.dart';

void main() => runApp(FocusScope(child: MyApp()));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Timer App',
      home: HomePage(),
    );
  }
}
