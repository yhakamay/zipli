import 'package:tripper/others/place_details.dart';

class TripDetails {
  TripDetails({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
    required this.places,
  });

  String id;
  String? title;
  String? description;
  DateTime startDate;
  DateTime endDate;
  DateTime createdAt;
  DateTime updatedAt;
  List<PlaceDetails> places;

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'places': places.map((place) => place.toFirestore()).toList(),
    };
  }

  factory TripDetails.fromFirestore(Map<String, dynamic> firestore) {
    return TripDetails(
      id: firestore['id'],
      title: firestore['title'],
      description: firestore['description'],
      startDate: DateTime.fromMillisecondsSinceEpoch(firestore['startDate']),
      endDate: DateTime.fromMillisecondsSinceEpoch(firestore['endDate']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(firestore['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(firestore['updatedAt']),
      places: firestore['places']
          .map<PlaceDetails>((place) => PlaceDetails.fromFirestore(place))
          .toList(),
    );
  }
}
