import 'package:flutter/material.dart';

import '../others/place_details.dart';

class PlaceListTile extends StatelessWidget {
  const PlaceListTile({
    Key? key,
    required this.place,
  }) : super(key: key);

  final PlaceDetails place;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(place.name ?? 'Unknown'),
      subtitle: Text(place.city ?? 'Unknown'),
      trailing: const Icon(Icons.reorder),
      visualDensity: const VisualDensity(
        horizontal: 0,
        vertical: -4,
      ),
    );
  }
}
