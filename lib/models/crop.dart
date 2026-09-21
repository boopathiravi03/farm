class Crop {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final double expectedPrice;
  final String harvestDate;
  final String location;
  final String imagePath;

  Crop({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.expectedPrice,
    required this.harvestDate,
    required this.location,
    required this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'expectedPrice': expectedPrice,
      'harvestDate': harvestDate,
      'location': location,
      'imagePath': imagePath,
    };
  }

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: json['id'],
      name: json['name'],
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'],
      expectedPrice: (json['expectedPrice'] as num).toDouble(),
      harvestDate: json['harvestDate'],
      location: json['location'],
      imagePath: json['imagePath'] ?? '',
    );
  }
}
