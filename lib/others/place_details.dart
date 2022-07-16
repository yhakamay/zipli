class PlaceDetails {
  PlaceDetails({
    required this.name,
    required this.rating,
    required this.formattedAddress,
    required this.city,
  });

  final String? name;
  final String? formattedAddress;
  final double? rating;
  final String? city;
}
