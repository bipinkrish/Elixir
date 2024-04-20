import 'dart:io';
import 'package:flutter/material.dart';
import 'package:elixir/view/splash_screen.dart';
import 'package:window_size/window_size.dart';

void main() {
  // ignore: unused_local_variable
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle("Elixir");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Elixir",
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
