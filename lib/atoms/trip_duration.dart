import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TripDuration extends StatelessWidget {
  const TripDuration({
    Key? key,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  final DateTime startDate;
  final DateTime endDate;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${DateFormat.yMMMd().format(startDate)} - ${DateFormat.yMMMMd().format(endDate)}',
    );
  }
}
