import '../models/fair_price.dart';

class FairPriceService {
  static Future<FairPrice> calculateFairPrice({
    required String cropName,
    required double marketPrice,
    required double quantity,
    required String location,
  }) async {
    // Simulate AI processing
    await Future.delayed(const Duration(seconds: 1));

    /*
      Prototype pricing engine.

      Final SIH version:

      Flutter
          ↓
      FastAPI
          ↓
      XGBoost Model
          ↓
      Market + Demand + Location + Quantity
          ↓
      Fair Price
    */

    double demandScore = 75;

    if (cropName.toLowerCase() == 'tomato') {
      demandScore = 88;
    } else if (cropName.toLowerCase() == 'onion') {
      demandScore = 82;
    } else if (cropName.toLowerCase() == 'potato') {
      demandScore = 68;
    }

    double recommendedPrice = marketPrice * (1 + ((demandScore - 70) / 1000));

    final minimumPrice = recommendedPrice * 0.92;

    final maximumPrice = recommendedPrice * 1.08;

    int confidence = 80;

    if (quantity > 500) {
      confidence = 87;
    }

    if (quantity > 1000) {
      confidence = 91;
    }

    String recommendation;

    if (recommendedPrice > marketPrice) {
      recommendation =
          'You may consider negotiating slightly above the current market price.';
    } else {
      recommendation =
          'The current market price is close to the estimated fair price.';
    }

    return FairPrice(
      cropName: cropName,
      currentMarketPrice: marketPrice,
      recommendedPrice: recommendedPrice,
      minimumPrice: minimumPrice,
      maximumPrice: maximumPrice,
      demandScore: demandScore,
      confidence: confidence,
      recommendation: recommendation,
      reason:
          'Recommendation considers current market price, crop demand, quantity and location.',
    );
  }
}
