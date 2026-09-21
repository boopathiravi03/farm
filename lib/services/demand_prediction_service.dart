import '../models/demand_prediction.dart';

class DemandPredictionService {
  static Future<DemandPrediction> predictDemand({
    required String cropName,
    required double currentPrice,
    required double quantity,
    required String location,
  }) async {
    // Simulate AI processing
    await Future.delayed(const Duration(seconds: 1));

    /*
      Prototype prediction engine.

      Final architecture:

      Flutter
          ↓
      FastAPI
          ↓
      Feature Engineering
          ↓
      XGBoost / ML Model
          ↓
      Demand Prediction
    */

    double currentDemand = 72;
    double expectedChange = 8;

    final crop = cropName.toLowerCase();

    if (crop == 'tomato') {
      currentDemand = 88;
      expectedChange = 18;
    } else if (crop == 'onion') {
      currentDemand = 82;
      expectedChange = 12;
    } else if (crop == 'potato') {
      currentDemand = 68;
      expectedChange = 5;
    } else if (crop == 'brinjal') {
      currentDemand = 76;
      expectedChange = 10;
    }

    String demandLevel;

    if (currentDemand >= 80) {
      demandLevel = 'HIGH';
    } else if (currentDemand >= 60) {
      demandLevel = 'MEDIUM';
    } else {
      demandLevel = 'LOW';
    }

    String bestSellingWindow;

    if (expectedChange >= 15) {
      bestSellingWindow = 'Next 3–5 days';
    } else if (expectedChange >= 8) {
      bestSellingWindow = 'Next 5–7 days';
    } else {
      bestSellingWindow = 'Monitor market conditions';
    }

    final List<double> forecast = [
      currentDemand,
      currentDemand + expectedChange * 0.20,
      currentDemand + expectedChange * 0.40,
      currentDemand + expectedChange * 0.60,
      currentDemand + expectedChange * 0.80,
      currentDemand + expectedChange,
      currentDemand + expectedChange * 0.90,
    ];

    final int confidence = quantity > 500 ? 88 : 81;

    return DemandPrediction(
      cropName: cropName,
      currentDemand: currentDemand,
      expectedChange: expectedChange,
      demandLevel: demandLevel,
      bestSellingWindow: bestSellingWindow,
      forecast: forecast,
      confidence: confidence,
    );
  }
}
