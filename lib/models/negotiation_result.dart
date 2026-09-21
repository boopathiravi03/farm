class NegotiationResult {
  final double buyerOffer;
  final double fairPrice;
  final double recommendedPrice;
  final double minimumAcceptablePrice;
  final double potentialRevenue;
  final String strategy;
  final String explanation;
  final String message;

  NegotiationResult({
    required this.buyerOffer,
    required this.fairPrice,
    required this.recommendedPrice,
    required this.minimumAcceptablePrice,
    required this.potentialRevenue,
    required this.strategy,
    required this.explanation,
    required this.message,
  });
}
