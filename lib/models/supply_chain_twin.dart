import 'supply_chain_node.dart';

class SupplyChainTwin {
  final String crop;
  final double initialQuantity;
  final double finalQuantity;
  final double traditionalCost;
  final double optimizedCost;
  final double potentialSavings;
  final double savingsPercent;
  final List<SupplyChainNode> nodes;

  SupplyChainTwin({
    required this.crop,
    required this.initialQuantity,
    required this.finalQuantity,
    required this.traditionalCost,
    required this.optimizedCost,
    required this.potentialSavings,
    required this.savingsPercent,
    required this.nodes,
  });
}
