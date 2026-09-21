import 'package:flutter/material.dart';

import '../models/market_price.dart';
import '../services/market_price_service.dart';

class MarketPriceScreen extends StatefulWidget {
  const MarketPriceScreen({super.key});

  @override
  State<MarketPriceScreen> createState() =>
      _MarketPriceScreenState();
}

class _MarketPriceScreenState
    extends State<MarketPriceScreen> {

  List<MarketPrice> prices = [];

  bool loading = true;

  String searchText = '';

  @override
  void initState() {
    super.initState();
    loadPrices();
  }

  Future<void> loadPrices() async {
    setState(() {
      loading = true;
    });

    final data =
        await MarketPriceService.getMarketPrices();

    if (!mounted) return;

    setState(() {
      prices = data;
      loading = false;
    });
  }

  List<MarketPrice> get filteredPrices {
    if (searchText.trim().isEmpty) {
      return prices;
    }

    return prices.where((price) {
      return price.commodity
              .toLowerCase()
              .contains(searchText.toLowerCase()) ||
          price.market
              .toLowerCase()
              .contains(searchText.toLowerCase());
    }).toList();
  }

  Color trendColor(double value) {
    if (value >= 0) {
      return Colors.green;
    }

    return Colors.red;
  }

  IconData trendIcon(double value) {
    if (value >= 0) {
      return Icons.trending_up;
    }

    return Icons.trending_down;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Market Prices',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: loadPrices,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: Column(
        children: [

          // LOCATION
          Container(
            margin: const EdgeInsets.fromLTRB(
              16,
              10,
              16,
              12,
            ),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.green,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Market Location',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Tamil Nadu • Cuddalore',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Change'),
                ),
              ],
            ),
          ),

          // SEARCH
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search crop or market...',
                prefixIcon: const Icon(
                  Icons.search,
                ),
                suffixIcon: searchText.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            searchText = '';
                          });
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // DATA SOURCE
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified,
                  size: 16,
                  color: Colors.green,
                ),
                const SizedBox(width: 6),
                Text(
                  'Market data • Updated today',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : filteredPrices.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No market price found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: loadPrices,
                        child: ListView.builder(
                          padding:
                              const EdgeInsets.all(16),
                          itemCount:
                              filteredPrices.length,
                          itemBuilder:
                              (context, index) {

                            final price =
                                filteredPrices[index];

                            return _marketPriceCard(
                              price,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _marketPriceCard(
    MarketPrice price,
  ) {
    final trendUp = price.changePercent >= 0;

    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            // HEADER
            Row(
              children: [

                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.eco,
                    color: Colors.green,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        price.commodity,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${price.market}, ${price.district}',
                        style: TextStyle(
                          color:
                              Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: trendUp
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        trendIcon(
                          price.changePercent,
                        ),
                        size: 17,
                        color: trendColor(
                          price.changePercent,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${price.changePercent.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          color: trendColor(
                            price.changePercent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // MODAL PRICE
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Modal Price',
                    style: TextStyle(
                      color:
                          Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${price.modalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight:
                          FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const Text(
                    'per Kg',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // MIN / MAX
            Row(
              children: [
                Expanded(
                  child: _priceBox(
                    'Minimum',
                    price.minPrice,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _priceBox(
                    'Maximum',
                    price.maxPrice,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // FOOTER
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 15,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 5),
                Text(
                  'Updated: ${price.date}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.verified,
                  size: 15,
                  color: Colors.green,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Market Data',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceBox(
    String title,
    double value,
  ) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '₹${value.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
