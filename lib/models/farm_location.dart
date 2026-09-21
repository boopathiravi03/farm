class FarmLocation {
  final String id;
  final String name;
  final String type;
  final String location;
  final double latitude;
  final double longitude;
  final String crop;
  final double quantity;

  FarmLocation({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.crop,
    required this.quantity,
  });
}
