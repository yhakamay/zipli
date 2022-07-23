import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tripper/atoms/filled_button.dart';
import 'package:uuid/uuid.dart';

import '../atoms/filled_tonal_button.dart';
import '../atoms/outlined_card.dart';
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
    final completer = Completer<GoogleMapController>();
    final markers = _getMarkers(widget.tripDetails);

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
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  widget.tripDetails.title ?? 'No title',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
            ),
            Center(
              child: Text(
                '${DateFormat.yMMMd().format(widget.tripDetails.startDate)} - ${DateFormat.yMMMMd().format(widget.tripDetails.endDate)}',
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                if (widget.tripDetails.places.isEmpty)
                  SizedBox(
                    width: double.infinity,
                    height: 80.0,
                    child: Center(
                      child: Text(
                        'Add some!',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 180,
                    child: ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      onReorder: (int oldIndex, int newIndex) {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }

                        final place =
                            widget.tripDetails.places.removeAt(oldIndex);

                        setState(() {
                          widget.tripDetails.places.insert(newIndex, place);
                        });
                      },
                      itemCount: widget.tripDetails.places.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          key: ValueKey(widget.tripDetails.places[index]),
                          background: Container(
                            color: Theme.of(context).colorScheme.error,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.delete,
                                  color: Theme.of(context).colorScheme.onError,
                                ),
                                const SizedBox(width: 8.0),
                              ],
                            ),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              setState(() {
                                widget.tripDetails.places.removeAt(index);
                              });
                            }
                          },
                          child: ListTile(
                            title: Text(widget.tripDetails.places[index].name ??
                                'Unknown'),
                            subtitle: Text(
                                widget.tripDetails.places[index].city ??
                                    'Unknown'),
                            trailing: const Icon(Icons.reorder),
                            visualDensity: const VisualDensity(
                              horizontal: 0,
                              vertical: -4,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                FilledTonalButton(
                  onPressed: _showPlaceSearch,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            if (widget.tripDetails.places.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: OutlinedCard(
                  child: SizedBox(
                    height: 240.0,
                    child: GoogleMap(
                      mapType: MapType.normal,
                      myLocationButtonEnabled: false,
                      scrollGesturesEnabled: false,
                      onMapCreated: (GoogleMapController controller) {
                        completer.complete(controller);
                        Future.delayed(const Duration(milliseconds: 200), () {
                          return controller.animateCamera(
                            CameraUpdate.newLatLngBounds(
                              _getLatLngBounds(widget.tripDetails),
                              60.0,
                            ),
                          );
                        });
                      },
                      markers: markers,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          widget.tripDetails.places.first.location!.latitude,
                          widget.tripDetails.places.first.location!.longitude,
                        ),
                        zoom: 15,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _saveTripDetails(widget.tripDetails);
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

  Set<Marker> _getMarkers(TripDetails tripDetails) {
    final markers = <Marker>{};

    for (final place in tripDetails.places) {
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

  LatLngBounds _getLatLngBounds(TripDetails tripDetails) {
    assert(tripDetails.places.isNotEmpty);

    double? x0, x1, y0, y1;
    final List<LatLng> latLngs = tripDetails.places.map((place) {
      return LatLng(
        place.location!.latitude,
        place.location!.longitude,
      );
    }).toList();

    for (LatLng latLng in latLngs) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }

    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
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
}
