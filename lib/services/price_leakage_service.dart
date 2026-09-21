import '../models/price_leakage.dart';

class PriceLeakageService {
  static Future<PriceLeakage> analyze({
    required String crop,
    required double quantity,
    required double farmerPrice,
  }) async {
    /*
      Prototype estimation model.

      In the final version these values will come from:
      - Market prices
      - Historical transaction data
      - Transportation costs
      - Wholesale prices
      - Retail prices
    */

    final double traderPrice = farmerPrice * 1.12;

    final double wholesalerPrice = farmerPrice * 1.28;

    final double retailerPrice = farmerPrice * 1.55;

    final double consumerPrice = farmerPrice * 1.80;

    final stages = [
      PriceStage(
        name: 'Farmer',
        icon: '👨🌾',
        pricePerKg: farmerPrice,
        totalValue: farmerPrice * quantity,
      ),

      PriceStage(
        name: 'Local Trader',
        icon: '🚚',
        pricePerKg: traderPrice,
        totalValue: traderPrice * quantity,
      ),

      PriceStage(
        name: 'Wholesaler',
        icon: '🏪',
        pricePerKg: wholesalerPrice,
        totalValue: wholesalerPrice * quantity,
      ),

      PriceStage(
        name: 'Retailer',
        icon: '🏬',
        pricePerKg: retailerPrice,
        totalValue: retailerPrice * quantity,
      ),

      PriceStage(
        name: 'Consumer',
        icon: '🛒',
        pricePerKg: consumerPrice,
        totalValue: consumerPrice * quantity,
      ),
    ];

    final double farmerRevenue = farmerPrice * quantity;

    final double consumerValue = consumerPrice * quantity;

    final double leakageAmount = consumerValue - farmerRevenue;

    final double leakagePercent = (leakageAmount / consumerValue) * 100;

    return PriceLeakage(
      cropName: crop,
      quantity: quantity,
      farmerPrice: farmerPrice,
      consumerPrice: consumerPrice,
      farmerRevenue: farmerRevenue,
      consumerValue: consumerValue,
      leakageAmount: leakageAmount,
      leakagePercent: leakagePercent,
      stages: stages,
    );
  }
}
