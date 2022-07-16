import 'package:flutter/material.dart';
import 'package:tripper/pages/new_trip_page.dart';

class HomePage extends StatefulWidget {
  static const id = '/';

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tripper'),
      ),
      body: const Center(
        child: Text('Hello World'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openNewTripPage,
        tooltip: 'New Trip',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openNewTripPage() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const NewTripPage();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return const FadeUpwardsPageTransitionsBuilder().buildTransitions(
            MaterialPageRoute(builder: (context) => const NewTripPage()),
            context,
            animation,
            secondaryAnimation,
            child,
          );
        },
      ),
    );
  }
}
