class MarketPrice {
  final String commodity;
  final String market;
  final String state;
  final String district;
  final double minPrice;
  final double maxPrice;
  final double modalPrice;
  final String date;
  final double changePercent;

  MarketPrice({
    required this.commodity,
    required this.market,
    required this.state,
    required this.district,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
    required this.date,
    required this.changePercent,
  });

  factory MarketPrice.fromJson(Map<String, dynamic> json) {
    return MarketPrice(
      commodity: json['commodity']?.toString() ?? '',
      market: json['market']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      minPrice: double.tryParse(
            json['min_price']?.toString() ?? '0',
          ) ??
          0,
      maxPrice: double.tryParse(
            json['max_price']?.toString() ?? '0',
          ) ??
          0,
      modalPrice: double.tryParse(
            json['modal_price']?.toString() ?? '0',
          ) ??
          0,
      date: json['date']?.toString() ?? '',
      changePercent: double.tryParse(
            json['change_percent']?.toString() ?? '0',
          ) ??
          0,
    );
  }
}
