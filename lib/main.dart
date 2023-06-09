import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:memogenerator/presentation/main/main_page.dart';

void main() async {
  EquatableConfig.stringify = true;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MainPage(),
    );
  }
}
