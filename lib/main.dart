import 'package:flutter/material.dart';

import 'pages/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video App Using Agora API',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true, primaryColor: Color.fromARGB(255, 0, 92, 167)),
      home: IndexPage(),
    );
  }
}
