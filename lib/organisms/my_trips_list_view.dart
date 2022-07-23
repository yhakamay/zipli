import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:zipli/atoms/deletable_background.dart';
import 'package:zipli/molecules/trip_overview.dart';
import 'package:zipli/pages/edit_trip_page.dart';

import '../atoms/filled_button.dart';
import '../others/trip_details.dart';

class MyTripsListView extends StatelessWidget {
  const MyTripsListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final myTripsQuery = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('trips')
        .orderBy('createdAt', descending: true);

    return FirestoreListView(
      query: myTripsQuery,
      itemBuilder: (context, snapshot) {
        final tripDetails =
            TripDetails.fromFirestore(snapshot.data() as Map<String, dynamic>);

        return Dismissible(
          key: ValueKey(tripDetails.id),
          background: const DeletableBackground(),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection('trips')
                .doc(tripDetails.id)
                .delete();
          },
          confirmDismiss: (_) async {
            return await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => AlertDialog(
                title: const Text('Delete this trip?'),
                content: const Text('This action cannot be undone.'),
                actions: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  FilledButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              ),
            );
          },
          child: GestureDetector(
            onTap: () => _openTripDetailsPage(context, tripDetails),
            child: TripOverview.small(tripDetails),
          ),
        );
      },
    );
  }

  void _openTripDetailsPage(BuildContext context, TripDetails tripDetails) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return EditTripPage(tripDetails);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return const FadeUpwardsPageTransitionsBuilder().buildTransitions(
            MaterialPageRoute(builder: (context) => EditTripPage(tripDetails)),
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
