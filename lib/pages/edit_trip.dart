import 'package:flutter/material.dart';
import 'package:tripper/molecules/trip_overview.dart';

import '../others/trip_details.dart';

class EditTripPage extends StatelessWidget {
  final TripDetails tripDetails;

  const EditTripPage(this.tripDetails, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
          title: const Text('Edit Trip'),
        ),
        body: TripOverview.large(tripDetails),
      ),
    );
  }
}
