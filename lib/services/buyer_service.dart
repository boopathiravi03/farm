import 'dart:math';
import '../models/buyer.dart';
import '../models/buyer_match.dart';

class BuyerService {
  static final List<Buyer> buyers = [
    Buyer(
      id: 'B001',
      name: 'Arun Traders',
      company: 'Arun Fresh Foods',
      crop: 'Tomato',
      requiredQuantity: 500,
      maxPrice: 28,
      location: 'Panruti',
      latitude: 11.776,
      longitude: 79.552,
    ),
    Buyer(
      id: 'B002',
      name: 'Kumar Foods',
      company: 'Kumar Agro Foods',
      crop: 'Tomato',
      requiredQuantity: 1000,
      maxPrice: 30,
      location: 'Cuddalore',
      latitude: 11.748,
      longitude: 79.771,
    ),
    Buyer(
      id: 'B003',
      name: 'Green Basket',
      company: 'Green Basket Wholesale',
      crop: 'Onion',
      requiredQuantity: 750,
      maxPrice: 36,
      location: 'Villupuram',
      latitude: 11.940,
      longitude: 79.487,
    ),
    Buyer(
      id: 'B004',
      name: 'Fresh Market',
      company: 'Fresh Market Suppliers',
      crop: 'Potato',
      requiredQuantity: 1200,
      maxPrice: 32,
      location: 'Cuddalore',
      latitude: 11.748,
      longitude: 79.771,
    ),
    Buyer(
      id: 'B005',
      name: 'Sri Agro',
      company: 'Sri Agro Wholesale',
      crop: 'Tomato',
      requiredQuantity: 300,
      maxPrice: 27,
      location: 'Neyveli',
      latitude: 11.531,
      longitude: 79.481,
    ),
  ];

  static Future<List<BuyerMatch>> findMatches({
    required String crop,
    required double quantity,
    required double expectedPrice,
  }) async {
    final List<BuyerMatch> matches = [];

    for (final buyer in buyers) {
      if (buyer.crop.toLowerCase() != crop.toLowerCase()) {
        continue;
      }

      final double quantityScore = _calculateQuantityScore(
        quantity,
        buyer.requiredQuantity,
      );

      final double priceScore = _calculatePriceScore(
        expectedPrice,
        buyer.maxPrice,
      );

      final double distanceKm = _calculateDistance(
        11.776,
        79.552,
        buyer.latitude,
        buyer.longitude,
      );

      final double distanceScore = _calculateDistanceScore(distanceKm);

      final double score =
          (quantityScore * 0.30) +
          (priceScore * 0.30) +
          (distanceScore * 0.20) +
          20;

      final double finalScore = score.clamp(0, 100);

      matches.add(
        BuyerMatch(
          buyer: buyer,
          matchScore: finalScore,
          distanceKm: distanceKm,
          reason: _generateReason(quantityScore, priceScore, distanceKm),
        ),
      );
    }

    matches.sort((a, b) => b.matchScore.compareTo(a.matchScore));

    return matches;
  }

  static double _calculateQuantityScore(
    double farmerQuantity,
    double buyerQuantity,
  ) {
    if (farmerQuantity >= buyerQuantity) {
      return 100;
    }

    final ratio = farmerQuantity / buyerQuantity;

    return (ratio * 100).clamp(0, 100);
  }

  static double _calculatePriceScore(double farmerPrice, double buyerMaxPrice) {
    if (farmerPrice <= buyerMaxPrice) {
      return 100;
    }

    final difference = ((farmerPrice - buyerMaxPrice) / buyerMaxPrice) * 100;

    return (100 - difference * 2).clamp(0, 100);
  }

  static double _calculateDistanceScore(double distance) {
    if (distance <= 10) return 100;
    if (distance <= 25) return 90;
    if (distance <= 50) return 75;
    if (distance <= 100) return 55;

    return 30;
  }

  static String _generateReason(
    double quantityScore,
    double priceScore,
    double distance,
  ) {
    if (quantityScore >= 90 && priceScore >= 90 && distance <= 25) {
      return 'Excellent match for quantity, price and location.';
    }

    if (priceScore >= 90) {
      return 'Buyer accepts your expected price.';
    }

    if (quantityScore >= 90) {
      return 'Buyer requirement closely matches your quantity.';
    }

    return 'Suitable buyer based on crop and overall compatibility.';
  }

  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371;

    final double dLat = _degreesToRadians(lat2 - lat1);

    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}
