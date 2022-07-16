import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'pages/new_trip_page.dart';

void main() {
  runApp(const Tripper());
}

class Tripper extends StatelessWidget {
  const Tripper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const HomePage(),
      initialRoute: HomePage.id,
      routes: {
        NewTripPage.id: (context) => const NewTripPage(),
      },
    );
  }
}
