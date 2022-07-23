import 'package:flutter/material.dart';

class TripTitle extends StatelessWidget {
  const TripTitle(
    this.title, {
    Key? key,
  }) : super(key: key);

  final String? title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title ?? 'No title',
        style: Theme.of(context).textTheme.headline6,
      ),
    );
  }
}
