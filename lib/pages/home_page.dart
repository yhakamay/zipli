import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:tripper/atoms/profile_navigation_destination.dart';
import 'package:tripper/atoms/trips_navigation_destination.dart';
import 'package:tripper/molecules/my_trips_list_view.dart';
import 'package:tripper/pages/new_trip_page.dart';

class HomePage extends StatefulWidget {
  static const id = '/';

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tripper'),
      ),
      bottomNavigationBar: _buildNavigationBar(),
      body: [
        const MyTripsListView(),
        const ProfileScreen(),
      ][_currentPageIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _openNewTripPage,
        tooltip: 'New Trip',
        child: const Icon(Icons.add),
      ),
    );
  }

  NavigationBar _buildNavigationBar() {
    return NavigationBar(
      onDestinationSelected: (int index) {
        setState(() {
          _currentPageIndex = index;
        });
      },
      selectedIndex: _currentPageIndex,
      destinations: const [
        TripsNavigationDestination(),
        ProfileNavigationDestination(),
      ],
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
