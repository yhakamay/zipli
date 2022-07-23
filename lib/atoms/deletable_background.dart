import 'package:flutter/material.dart';

class DeletableBackground extends StatelessWidget {
  const DeletableBackground({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
