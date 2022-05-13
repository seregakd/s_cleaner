import 'package:flutter/material.dart';

import 'file_manager_page.dart';
import 'info_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: FileManagerPage() // const InfoPage(), HomePage()
    );
  }
}

// storage/emulated/0
