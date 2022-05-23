import 'package:flutter/material.dart';
import 'package:komikku/views/login.dart';
import 'package:komikku/views/shell.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Komikku',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      routes: {'/login': (context) => const Login()},
      home: const Shell(),
    );
  }
}
