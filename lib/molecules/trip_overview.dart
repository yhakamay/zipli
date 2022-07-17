import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../atoms/outlined_card.dart';
import '../others/trip_details.dart';

enum TripOverviewSize { small, medium, large }

class TripOverview extends StatefulWidget {
  final TripDetails tripDetails;
  final TripOverviewSize size;

  const TripOverview(
    this.tripDetails, {
    Key? key,
    this.size = TripOverviewSize.medium,
  }) : super(key: key);

  factory TripOverview.small(TripDetails tripDetails) {
    return TripOverview(
      tripDetails,
      size: TripOverviewSize.small,
    );
  }

  factory TripOverview.large(TripDetails tripDetails) {
    return TripOverview(
      tripDetails,
      size: TripOverviewSize.large,
    );
  }

  @override
  State<TripOverview> createState() => _TripOverviewState();
}

class _TripOverviewState extends State<TripOverview> {
  @override
  Widget build(BuildContext context) {
    switch (widget.size) {
      case TripOverviewSize.small:
        return OutlinedCard(
          child: ListTile(
            title: Text(widget.tripDetails.title ?? 'Unknown'),
            subtitle: Text(
              '${DateFormat.yMMMMd().format(widget.tripDetails.startDate)} - ${DateFormat.yMMMMd().format(widget.tripDetails.endDate)}',
            ),
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
                  widget.tripDetails.title ?? 'No title',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Text(
                '${DateFormat.yMMMd().format(widget.tripDetails.startDate)} - ${DateFormat.yMMMMd().format(widget.tripDetails.endDate)}',
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.tripDetails.places.length,
                  itemBuilder: (context, index) {
                    final place = widget.tripDetails.places[index];

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
