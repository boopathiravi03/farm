class CropPassport {
  final String passportId;
  final String cropName;
  final String farmerName;
  final String quantity;
  final String location;
  final String harvestDate;
  final double expectedPrice;
  final String qualityGrade;
  final int qualityScore;
  final int qualityConfidence;
  final String status;

  CropPassport({
    required this.passportId,
    required this.cropName,
    required this.farmerName,
    required this.quantity,
    required this.location,
    required this.harvestDate,
    required this.expectedPrice,
    required this.qualityGrade,
    required this.qualityScore,
    required this.qualityConfidence,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'passportId': passportId,
      'cropName': cropName,
      'farmerName': farmerName,
      'quantity': quantity,
      'location': location,
      'harvestDate': harvestDate,
      'expectedPrice': expectedPrice,
      'qualityGrade': qualityGrade,
      'qualityScore': qualityScore,
      'qualityConfidence': qualityConfidence,
      'status': status,
    };
  }

  factory CropPassport.fromJson(Map<String, dynamic> json) {
    return CropPassport(
      passportId: json['passportId'] ?? '',
      cropName: json['cropName'] ?? '',
      farmerName: json['farmerName'] ?? '',
      quantity: json['quantity'] ?? '',
      location: json['location'] ?? '',
      harvestDate: json['harvestDate'] ?? '',
      expectedPrice: (json['expectedPrice'] as num?)?.toDouble() ?? 0,
      qualityGrade: json['qualityGrade'] ?? 'B',
      qualityScore: json['qualityScore'] ?? 0,
      qualityConfidence: json['qualityConfidence'] ?? 0,
      status: json['status'] ?? 'Active',
    );
  }
}
