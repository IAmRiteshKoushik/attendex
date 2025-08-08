import 'package:flutter/material.dart';
import 'screens/event_page_home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AttenDex',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: EventPageHome(),
    );
  }
}