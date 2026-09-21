import '../models/negotiation_result.dart';

class NegotiationService {
  static Future<NegotiationResult> analyze({
    required String crop,
    required double quantity,
    required double marketPrice,
    required double fairPrice,
    required double buyerOffer,
  }) async {
    /*
      Prototype negotiation engine.

      Final version:
      FastAPI
        ↓
      Market data
        ↓
      Fair-price model
        ↓
      Demand prediction
        ↓
      Buyer history
        ↓
      AI negotiation assistant
    */

    final double recommendedPrice = fairPrice > marketPrice
        ? fairPrice
        : marketPrice;

    final double minimumPrice = recommendedPrice * 0.92;

    String strategy;
    String explanation;

    if (buyerOffer >= recommendedPrice) {
      strategy = 'Accept / Confirm';

      explanation =
          'The buyer offer is at or above the recommended '
          'fair-price level.';
    } else if (buyerOffer >= minimumPrice) {
      strategy = 'Negotiate Slightly';

      explanation =
          'The offer is close to the recommended price. '
          'Try negotiating toward the fair price.';
    } else {
      strategy = 'Counter Offer';

      explanation =
          'The offer is below the recommended range. '
          'A counter-offer is suggested.';
    }

    final double potentialRevenue = recommendedPrice * quantity;

    final String message =
        'Hello, I can supply $quantity Kg of $crop. '
        'Based on the current market price and fair-price '
        'estimate, I am looking for around '
        '₹${recommendedPrice.toStringAsFixed(0)}/Kg. '
        'Considering the quantity and quality, '
        'can we agree around ₹${recommendedPrice.toStringAsFixed(0)}/Kg?';

    return NegotiationResult(
      buyerOffer: buyerOffer,
      fairPrice: fairPrice,
      recommendedPrice: recommendedPrice,
      minimumAcceptablePrice: minimumPrice,
      potentialRevenue: potentialRevenue,
      strategy: strategy,
      explanation: explanation,
      message: message,
    );
  }
}
