import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'routes/routes.dart' as route;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData.dark(),
      onGenerateRoute: route.controller,
      initialRoute: route.homePage,
    );
  }
}
