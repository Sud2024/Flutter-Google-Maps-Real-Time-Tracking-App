import 'package:flutter/material.dart';
import 'package:google_maps_tracker/pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp(homeScreen: HomePage(),));
}

class MyApp extends StatefulWidget {

  final Widget homeScreen;

  const MyApp({Key? key, required this.homeScreen}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: this.widget.homeScreen,
    );
  }

}

