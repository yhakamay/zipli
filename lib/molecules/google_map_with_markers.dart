import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import '../others/place_details.dart';

class GoogleMapWithMarkers extends StatefulWidget {
  const GoogleMapWithMarkers({
    Key? key,
    required this.places,
  }) : super(key: key);

  final List<PlaceDetails> places;

  @override
  State<GoogleMapWithMarkers> createState() => _GoogleMapWithMarkersState();
}

class _GoogleMapWithMarkersState extends State<GoogleMapWithMarkers> {
  final completer = Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {
    final places = widget.places;
    final markers = _getMarkers(places);

    return SizedBox(
      width: double.infinity,
      height: 320.0,
      child: GoogleMap(
        mapType: MapType.normal,
        myLocationButtonEnabled: false,
        scrollGesturesEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          completer.complete(controller);
          Future.delayed(const Duration(milliseconds: 200), () {
            return controller.animateCamera(
              CameraUpdate.newLatLngBounds(
                _getLatLngBounds(places),
                60.0,
              ),
            );
          });
        },
        markers: markers,
        initialCameraPosition: CameraPosition(
          target: LatLng(
            places.first.location!.latitude,
            places.first.location!.longitude,
          ),
          zoom: 15,
        ),
      ),
    );
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

  LatLngBounds _getLatLngBounds(List<PlaceDetails> places) {
    assert(places.isNotEmpty);

    double? x0, x1, y0, y1;
    final List<LatLng> latLngs = places.map((place) {
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
}
