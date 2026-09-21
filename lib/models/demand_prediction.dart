class DemandPrediction {
  final String cropName;
  final double currentDemand;
  final double expectedChange;
  final String demandLevel;
  final String bestSellingWindow;
  final List<double> forecast;
  final int confidence;

  DemandPrediction({
    required this.cropName,
    required this.currentDemand,
    required this.expectedChange,
    required this.demandLevel,
    required this.bestSellingWindow,
    required this.forecast,
    required this.confidence,
  });
}
