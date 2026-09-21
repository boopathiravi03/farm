class Buyer {
  final String id;
  final String name;
  final String company;
  final String crop;
  final double requiredQuantity;
  final double maxPrice;
  final String location;
  final double latitude;
  final double longitude;

  Buyer({
    required this.id,
    required this.name,
    required this.company,
    required this.crop,
    required this.requiredQuantity,
    required this.maxPrice,
    required this.location,
    required this.latitude,
    required this.longitude,
  });
}
