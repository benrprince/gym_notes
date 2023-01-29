import 'package:flutter/material.dart';
import 'routes/routes.dart' as route;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData.dark(),      
      onGenerateRoute: route.controller,
      initialRoute: route.homePage,
    );
  }
}
