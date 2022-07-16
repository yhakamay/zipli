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
}
