class PriceStage {
  final String name;
  final String icon;
  final double pricePerKg;
  final double totalValue;

  PriceStage({
    required this.name,
    required this.icon,
    required this.pricePerKg,
    required this.totalValue,
  });
}

class PriceLeakage {
  final String cropName;
  final double quantity;
  final double farmerPrice;
  final double consumerPrice;
  final double farmerRevenue;
  final double consumerValue;
  final double leakageAmount;
  final double leakagePercent;
  final List<PriceStage> stages;

  PriceLeakage({
    required this.cropName,
    required this.quantity,
    required this.farmerPrice,
    required this.consumerPrice,
    required this.farmerRevenue,
    required this.consumerValue,
    required this.leakageAmount,
    required this.leakagePercent,
    required this.stages,
  });
}
