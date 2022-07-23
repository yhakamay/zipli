import 'package:flutter/material.dart';
import 'package:zipli/atoms/place_list_tile.dart';
import 'package:zipli/atoms/trip_duration.dart';
import 'package:zipli/atoms/trip_title.dart';

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
    final tripDetails = widget.tripDetails;

    switch (widget.size) {
      case TripOverviewSize.small:
        return OutlinedCard(
          child: ListTile(
            title: TripTitle(tripDetails.title),
            subtitle: TripDuration(
              startDate: tripDetails.startDate,
              endDate: tripDetails.endDate,
            ),
          ),
        );
      default:
        return OutlinedCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TripTitle(tripDetails.title),
              TripDuration(
                startDate: tripDetails.startDate,
                endDate: tripDetails.endDate,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.tripDetails.places.length,
                  itemBuilder: (context, index) {
                    final place = widget.tripDetails.places[index];

                    return PlaceListTile(
                      place: place,
                      reorderable: false,
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
