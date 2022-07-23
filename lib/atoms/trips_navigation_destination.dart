import 'package:flutter/material.dart';

class TripsNavigationDestination extends StatelessWidget {
  const TripsNavigationDestination({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const NavigationDestination(
      icon: Icon(Icons.airplane_ticket_outlined),
      selectedIcon: Icon(Icons.airplane_ticket),
      label: 'Trips',
    );
  }
}
