class FairPrice {
  final String cropName;
  final double currentMarketPrice;
  final double recommendedPrice;
  final double minimumPrice;
  final double maximumPrice;
  final double demandScore;
  final int confidence;
  final String recommendation;
  final String reason;

  FairPrice({
    required this.cropName,
    required this.currentMarketPrice,
    required this.recommendedPrice,
    required this.minimumPrice,
    required this.maximumPrice,
    required this.demandScore,
    required this.confidence,
    required this.recommendation,
    required this.reason,
  });
}
