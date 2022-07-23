import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../atoms/deletable_background.dart';
import '../atoms/filled_button.dart';
import '../atoms/filled_tonal_button.dart';
import '../atoms/no_locations.dart';
import '../atoms/outlined_card.dart';
import '../atoms/place_list_tile.dart';
import '../atoms/trip_duration.dart';
import '../atoms/trip_title.dart';
import '../molecules/google_map_with_markers.dart';
import '../others/place_api.dart';
import '../others/place_details.dart';
import '../others/place_search_delegate.dart';
import '../others/trip_details.dart';

class EditTripPage extends StatefulWidget {
  final TripDetails tripDetails;

  const EditTripPage(this.tripDetails, {Key? key}) : super(key: key);

  @override
  State<EditTripPage> createState() => _EditTripPageState();
}

class _EditTripPageState extends State<EditTripPage> {
  @override
  Widget build(BuildContext context) {
    final tripDetails = widget.tripDetails;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => AlertDialog(
                  title: const Text('Discard changes?'),
                  content: const Text('Changes you made will not be saved.'),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FilledButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.close),
          ),
          title: const Text('Edit Trip'),
        ),
        body: ListView(
          children: [
            Center(child: TripTitle(tripDetails.title)),
            Center(
              child: TripDuration(
                startDate: tripDetails.startDate,
                endDate: tripDetails.endDate,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                if (tripDetails.places.isEmpty)
                  const NoLocations()
                else
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    onReorder: _updatePlacesOrder,
                    itemCount: tripDetails.places.length,
                    itemBuilder: (context, index) => Dismissible(
                      key: ValueKey(tripDetails.places[index]),
                      background: const DeletableBackground(),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart) {
                          setState(() {
                            tripDetails.places.removeAt(index);
                          });
                        }
                      },
                      child: PlaceListTile(place: tripDetails.places[index]),
                    ),
                  ),
                FilledTonalButton(
                  onPressed: _showPlaceSearch,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            if (tripDetails.places.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: OutlinedCard(
                  child: GoogleMapWithMarkers(
                    places: tripDetails.places,
                  ),
                ),
              ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _saveTripDetails(tripDetails);
            Navigator.pop(context);
          },
          icon: const Icon(Icons.done),
          label: const Text('Save'),
        ),
      ),
    );
  }

  Future<void> _showPlaceSearch() async {
    final sessionToken = const Uuid().v4();
    final result = await showSearch(
      context: context,
      delegate: PlaceSearchDelegate(sessionToken),
    );

    final placeDetails = await _getPlaceDetails(result!.placeId);

    setState(() {
      widget.tripDetails.places.add(placeDetails);
    });
  }

  Future<PlaceDetails> _getPlaceDetails(String placeId) {
    final sessionToken = const Uuid().v4();
    final placeApiProvider = PlaceAPI(sessionToken: sessionToken);

    return placeApiProvider.getPlaceDetails(placeId);
  }

  Future<void> _saveTripDetails(TripDetails tripDetails) async {
    final users = FirebaseFirestore.instance.collection('users');
    final me = users.doc(FirebaseAuth.instance.currentUser!.uid);
    final myTrips = me.collection('trips');

    myTrips
        .doc(tripDetails.id)
        .update(tripDetails.toFirestore())
        .then((value) => print('Trip saved!'))
        .catchError((error) => print(error));
  }

  void _updatePlacesOrder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final place = widget.tripDetails.places.removeAt(oldIndex);

    setState(() {
      widget.tripDetails.places.insert(newIndex, place);
    });
  }
}
