import '../models/supply_chain_node.dart';
import '../models/supply_chain_twin.dart';

class SupplyChainService {
  static Future<SupplyChainTwin> simulate({
    required String crop,
    required double quantity,
    required double farmerPrice,
  }) async {
    final nodes = [
      SupplyChainNode(
        name: 'Farmer',
        type: 'Production',
        icon: '👨🌾',
        location: 'Panruti',
        pricePerKg: farmerPrice,
        quantity: quantity,
        distanceFromPrevious: 0,
        transportCost: 0,
        deliveryHours: 0,
      ),

      SupplyChainNode(
        name: 'Local Buyer',
        type: 'Collection',
        icon: '🚚',
        location: 'Panruti',
        pricePerKg: farmerPrice * 1.12,
        quantity: quantity * 0.99,
        distanceFromPrevious: 8,
        transportCost: 600,
        deliveryHours: 2,
      ),

      SupplyChainNode(
        name: 'Warehouse',
        type: 'Storage',
        icon: '🏪',
        location: 'Cuddalore',
        pricePerKg: farmerPrice * 1.27,
        quantity: quantity * 0.97,
        distanceFromPrevious: 28,
        transportCost: 1200,
        deliveryHours: 4,
      ),

      SupplyChainNode(
        name: 'Retailer',
        type: 'Distribution',
        icon: '🏬',
        location: 'Puducherry',
        pricePerKg: farmerPrice * 1.52,
        quantity: quantity * 0.95,
        distanceFromPrevious: 42,
        transportCost: 1800,
        deliveryHours: 6,
      ),

      SupplyChainNode(
        name: 'Consumer',
        type: 'End Market',
        icon: '🛒',
        location: 'Puducherry',
        pricePerKg: farmerPrice * 1.80,
        quantity: quantity * 0.94,
        distanceFromPrevious: 5,
        transportCost: 300,
        deliveryHours: 1,
      ),
    ];

    const double traditionalCost = 3900;

    final double optimizedCost = quantity > 500 ? 2600 : 3000;

    final double potentialSavings = traditionalCost - optimizedCost;

    final double savingsPercent = (potentialSavings / traditionalCost) * 100;

    return SupplyChainTwin(
      crop: crop,
      initialQuantity: quantity,
      finalQuantity: nodes.last.quantity,
      traditionalCost: traditionalCost,
      optimizedCost: optimizedCost,
      potentialSavings: potentialSavings,
      savingsPercent: savingsPercent,
      nodes: nodes,
    );
  }
}
