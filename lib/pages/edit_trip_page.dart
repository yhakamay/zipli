import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:uuid/uuid.dart';

import '../atoms/deletable_background.dart';
import '../atoms/filled_button.dart';
import '../atoms/filled_tonal_button.dart';
import '../atoms/no_locations.dart';
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
  late TripDetails tripDetails;

  @override
  void initState() {
    super.initState();
    tripDetails = widget.tripDetails;
  }

  @override
  Widget build(BuildContext context) {
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
          actions: [
            IconButton(
              onPressed: () {
                _saveTripDetails(tripDetails);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.done),
            )
          ],
          title: const Text('Edit Trip'),
        ),
        body: SlidingUpPanel(
          maxHeight: 1000,
          minHeight: 100,
          snapPoint: 0.4,
          panelSnapping: true,
          defaultPanelState: PanelState.CLOSED,
          backdropEnabled: true,
          body: tripDetails.places.isNotEmpty
              ? GoogleMapWithMarkers(
                  places: tripDetails.places,
                  markers: _getMarkers(tripDetails.places),
                  polylines: _getPolylines(tripDetails.places),
                )
              : const NoLocations(),
          panelBuilder: (sc) => ListView(
            controller: sc,
            children: [
              const SizedBox(
                height: 12.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 30,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: const BorderRadius.all(
                        Radius.circular(12.0),
                      ),
                    ),
                  ),
                ],
              ),
              Center(child: TripTitle(tripDetails.title)),
              Center(
                child: TripDuration(
                  startDate: tripDetails.startDate,
                  endDate: tripDetails.endDate,
                ),
              ),
              const SizedBox(height: 24),
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
            ],
          ),
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
      tripDetails.places.add(placeDetails);
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

    final place = tripDetails.places.removeAt(oldIndex);

    setState(() {
      tripDetails.places.insert(newIndex, place);
      tripDetails = tripDetails;
    });
  }

  Set<Marker> _getMarkers(List<PlaceDetails> places) {
    final markers = <Marker>{};

    for (final place in places) {
      markers.add(
        Marker(
          markerId: MarkerId(const Uuid().v4()),
          position: LatLng(
            place.location!.latitude,
            place.location!.longitude,
          ),
        ),
      );
    }

    return markers;
  }

  Set<Polyline> _getPolylines(List<PlaceDetails> places) {
    final polylines = <Polyline>{};
    final polylineId = PolylineId(const Uuid().v4());
    final points = <LatLng>[];

    for (final place in places) {
      points.add(
        LatLng(
          place.location!.latitude,
          place.location!.longitude,
        ),
      );
    }

    polylines.add(
      Polyline(
        polylineId: polylineId,
        visible: true,
        points: points,
        color: Colors.orange,
        width: 4,
      ),
    );

    return polylines;
  }
}
