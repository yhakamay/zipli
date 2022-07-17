//import 'package:flutter/material.dart';
//import 'package:tripper/others/trip_details.dart';

//import '../atoms/filled_tonal_button.dart';

//class PlacesColumn extends StatelessWidget {
//  final TripDetails tripDetails;
//  final VoidCallback removePlace;
//  final VoidCallback addPlace;

//  const PlacesColumn({
//    Key? key,
//    required this.tripDetails,
//    required this.removePlace,
//    required this.addPlace,
//  }) : super(key: key);

//  @override
//  Widget build(BuildContext context) {
//    return Column(
//      children: [
//        tripDetails.places.isEmpty
//            ? SizedBox(
//                width: double.infinity,
//                height: 80.0,
//                child: Center(
//                  child: Text(
//                    'Add some!',
//                    style: Theme.of(context).textTheme.headline6,
//                  ),
//                ),
//              )
//            : ListView.builder(
//                shrinkWrap: true,
//                itemCount: tripDetails.places.length,
//                itemBuilder: (context, index) {
//                  return ListTile(
//                    title: Text(tripDetails.places[index].name ?? 'Unknown'),
//                    subtitle: Text(tripDetails.places[index].city ?? 'Unknown'),
//                    trailing: IconButton(
//                      icon: const Icon(Icons.delete),
//                      onPressed: () {
//                        setState(() {
//                          _tripDetails.places.removeAt(index);
//                        });
//                      },
//                    ),
//                  );
//                },
//              ),
//        FilledTonalButton(
//          onPressed: addPlace,
//          child: const Icon(Icons.add),
//        ),
//      ],
//    );
//  }
//}
