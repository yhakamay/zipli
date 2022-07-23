import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class ProfileNavigationDestination extends StatelessWidget {
  const ProfileNavigationDestination({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const NavigationDestination(
      icon: Icon(Icons.account_circle_outlined),
      selectedIcon: Icon(Icons.account_circle),
      label: 'Profile',
    );
  }
}
