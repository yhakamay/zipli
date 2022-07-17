import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:intl/intl.dart';
import 'package:tripper/atoms/outlined_card.dart';
import 'package:tripper/others/trip_details.dart';
import 'package:tripper/pages/new_trip_page.dart';

class HomePage extends StatefulWidget {
  static const id = '/';

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentPageIndex = 0;
  final _myTripsQuery = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('trips')
      .orderBy('createdAt', descending: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tripper'),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        selectedIndex: _currentPageIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.airplane_ticket_outlined),
            selectedIcon: Icon(Icons.airplane_ticket),
            label: 'Trips',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_outlined),
            selectedIcon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
      body: [
        FirestoreListView(
          query: _myTripsQuery,
          itemBuilder: (context, snapshot) {
            final TripDetails trip = TripDetails.fromFirestore(
                snapshot.data() as Map<String, dynamic>);

            return OutlinedCard(
              child: ListTile(
                title: Text(trip.title ?? 'Unknown'),
                subtitle: Text(
                  '${DateFormat.yMMMMd().format(trip.startDate)} - ${DateFormat.yMMMMd().format(trip.endDate)}',
                ),
              ),
            );
          },
        ),
        const ProfileScreen(),
      ][_currentPageIndex],
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
