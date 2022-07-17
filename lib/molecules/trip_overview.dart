import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../atoms/outlined_card.dart';
import '../others/trip_details.dart';

class TripOverview extends StatelessWidget {
  final TripDetails tripDetails;

  const TripOverview({
    Key? key,
    required this.tripDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              tripDetails.title ?? 'No title',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Text(
            '${DateFormat.yMMMd().format(tripDetails.startDate)} - ${DateFormat.yMMMMd().format(tripDetails.endDate)}',
          ),
          Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: tripDetails.places.length,
              itemBuilder: (context, index) {
                final place = tripDetails.places[index];

                return ListTile(
                  title: Text(place.name ?? 'Unknown'),
                  subtitle: Text(place.city ?? 'Unknown'),
                  visualDensity: const VisualDensity(
                    horizontal: 0,
                    vertical: -4,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
