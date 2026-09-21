import 'buyer.dart';

class BuyerMatch {
  final Buyer buyer;
  final double matchScore;
  final double distanceKm;
  final String reason;

  BuyerMatch({
    required this.buyer,
    required this.matchScore,
    required this.distanceKm,
    required this.reason,
  });
}
