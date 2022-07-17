import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../atoms/outlined_card.dart';
import '../others/trip_details.dart';

enum TripOverviewSize { small, medium, large }

class TripOverview extends StatelessWidget {
  final TripDetails tripDetails;
  final TripOverviewSize size;

  const TripOverview({
    Key? key,
    required this.tripDetails,
    this.size = TripOverviewSize.medium,
  }) : super(key: key);

  factory TripOverview.small(TripDetails tripDetails) {
    return TripOverview(
      tripDetails: tripDetails,
      size: TripOverviewSize.small,
    );
  }

  factory TripOverview.large(TripDetails tripDetails) {
    return TripOverview(
      tripDetails: tripDetails,
      size: TripOverviewSize.large,
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (size) {
      case TripOverviewSize.small:
        return OutlinedCard(
          child: ListTile(
            title: Text(tripDetails.title ?? 'Unknown'),
            subtitle: Text(
              '${DateFormat.yMMMMd().format(tripDetails.startDate)} - ${DateFormat.yMMMMd().format(tripDetails.endDate)}',
            ),
          ),
        );
      case TripOverviewSize.medium:
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
      default:
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
                padding: const EdgeInsets.symmetric(vertical: 24.0),
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
}
