import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:tripper/molecules/trip_overview.dart';

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

        return TripOverview.small(tripDetails);
      },
    );
  }
}
