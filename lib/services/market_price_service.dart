import '../models/market_price.dart';

class MarketPriceService {
  static Future<List<MarketPrice>> getMarketPrices() async {
    /*
      STEP 5 PROTOTYPE DATA

      The UI is ready for live API data.

      In the final SIH architecture:

      Flutter
          ↓
      FastAPI Backend
          ↓
      Government Market Data API
          ↓
      PostgreSQL / Redis Cache
          ↓
      Flutter
    */

    await Future.delayed(
      const Duration(milliseconds: 700),
    );

    return [
      MarketPrice(
        commodity: 'Tomato',
        market: 'Panruti',
        state: 'Tamil Nadu',
        district: 'Cuddalore',
        minPrice: 20,
        maxPrice: 30,
        modalPrice: 25,
        date: 'Today',
        changePercent: 8.2,
      ),

      MarketPrice(
        commodity: 'Onion',
        market: 'Panruti',
        state: 'Tamil Nadu',
        district: 'Cuddalore',
        minPrice: 28,
        maxPrice: 38,
        modalPrice: 33,
        date: 'Today',
        changePercent: 4.5,
      ),

      MarketPrice(
        commodity: 'Potato',
        market: 'Cuddalore',
        state: 'Tamil Nadu',
        district: 'Cuddalore',
        minPrice: 24,
        maxPrice: 32,
        modalPrice: 28,
        date: 'Today',
        changePercent: -2.1,
      ),

      MarketPrice(
        commodity: 'Brinjal',
        market: 'Cuddalore',
        state: 'Tamil Nadu',
        district: 'Cuddalore',
        minPrice: 25,
        maxPrice: 36,
        modalPrice: 31,
        date: 'Today',
        changePercent: 6.4,
      ),
    ];
  }
}
