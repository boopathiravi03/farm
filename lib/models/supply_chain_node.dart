class SupplyChainNode {
  final String name;
  final String type;
  final String icon;
  final String location;
  final double pricePerKg;
  final double quantity;
  final double distanceFromPrevious;
  final double transportCost;
  final int deliveryHours;

  SupplyChainNode({
    required this.name,
    required this.type,
    required this.icon,
    required this.location,
    required this.pricePerKg,
    required this.quantity,
    required this.distanceFromPrevious,
    required this.transportCost,
    required this.deliveryHours,
  });
}
