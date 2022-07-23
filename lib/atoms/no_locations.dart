import 'package:flutter/material.dart';

class NoLocations extends StatelessWidget {
  const NoLocations({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 80.0,
      child: Center(
        child: Text(
          'Add some!',
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
    );
  }
}
