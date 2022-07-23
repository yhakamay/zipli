import 'package:flutter/material.dart';

import '../others/place_details.dart';

class PlaceListTile extends StatelessWidget {
  const PlaceListTile({
    Key? key,
    required this.place,
    this.reorderable = true,
  }) : super(key: key);

  final PlaceDetails place;
  final bool reorderable;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(place.name ?? 'Unknown'),
      subtitle: Text(place.city ?? 'Unknown'),
      trailing: reorderable ? const Icon(Icons.reorder) : null,
      visualDensity: const VisualDensity(
        horizontal: 0,
        vertical: -4,
      ),
    );
  }
}
