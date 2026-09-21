import 'package:flutter/material.dart';

import '../models/market_price.dart';
import '../services/market_price_service.dart';

class MarketPriceScreen extends StatefulWidget {
  const MarketPriceScreen({super.key});

  @override
  State<MarketPriceScreen> createState() => _MarketPriceScreenState();
}

class _MarketPriceScreenState extends State<MarketPriceScreen> {
  final cropController = TextEditingController();
  final quantityController = TextEditingController();

  String selectedMarket = 'Panruti';
  String selectedCrop = 'Tomato';
  bool hasChecked = true;
  List<MarketPrice> allPrices = [];
  bool loading = false;

  final List<String> markets = [
    'Panruti',
    'Cuddalore',
    'Chennai',
    'Villupuram',
  ];

  final List<String> popularCrops = [
    'Tomato',
    'Onion',
    'Potato',
    'Chilli',
    'Brinjal',
  ];

  // Reference pricing data per market
  final Map<String, Map<String, dynamic>> cropPriceData = {
    'Tomato': {
      'icon': '🍅',
      'base': 32.0,
      'min': 28.0,
      'max': 35.0,
      'trend': 8.4,
      'nearby': {
        'Panruti': 32.0,
        'Cuddalore': 30.0,
        'Chennai': 36.0,
        'Villupuram': 31.0,
      },
      'tip':
          'Selling in Chennai may give a higher gross price, but check transport cost before deciding.',
    },
    'Onion': {
      'icon': '🧅',
      'base': 38.0,
      'min': 34.0,
      'max': 44.0,
      'trend': -2.5,
      'nearby': {
        'Panruti': 38.0,
        'Cuddalore': 36.0,
        'Chennai': 42.0,
        'Villupuram': 37.0,
      },
      'tip':
          'Onion prices are stable today. Storing for a few days may yield better returns.',
    },
    'Potato': {
      'icon': '🥔',
      'base': 26.0,
      'min': 22.0,
      'max': 30.0,
      'trend': 3.1,
      'nearby': {
        'Panruti': 26.0,
        'Cuddalore': 25.0,
        'Chennai': 29.0,
        'Villupuram': 25.5,
      },
      'tip':
          'Steady local demand in Cuddalore district. Good time for wholesale offload.',
    },
    'Chilli': {
      'icon': '🌶️',
      'base': 55.0,
      'min': 48.0,
      'max': 64.0,
      'trend': 11.2,
      'nearby': {
        'Panruti': 55.0,
        'Cuddalore': 52.0,
        'Chennai': 60.0,
        'Villupuram': 53.0,
      },
      'tip':
          'Strong price surge in Chennai wholesale market due to supply crunch.',
    },
    'Brinjal': {
      'icon': '🍆',
      'base': 28.0,
      'min': 24.0,
      'max': 33.0,
      'trend': 1.5,
      'nearby': {
        'Panruti': 28.0,
        'Cuddalore': 27.0,
        'Chennai': 31.0,
        'Villupuram': 27.0,
      },
      'tip': 'Fresh harvest is commanding premium in local Panruti mandi.',
    },
  };

  @override
  void initState() {
    super.initState();
    cropController.text = 'Tomato';
    quantityController.text = '500';
    loadAllPrices();
  }

  Future<void> loadAllPrices() async {
    setState(() => loading = true);
    final data = await MarketPriceService.getMarketPrices();
    if (!mounted) return;
    setState(() {
      allPrices = data;
      loading = false;
    });
  }

  void _onSelectCrop(String crop) {
    setState(() {
      selectedCrop = crop;
      cropController.text = crop;
      hasChecked = true;
    });
  }

  @override
  void dispose() {
    cropController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cropKey = cropPriceData.keys.firstWhere(
      (k) => k.toLowerCase() == selectedCrop.toLowerCase(),
      orElse: () => 'Tomato',
    );
    final currentData = cropPriceData[cropKey]!;
    final icon = currentData['icon'] as String;
    final nearbyMap = currentData['nearby'] as Map<String, double>;
    final currentMarketPrice =
        nearbyMap[selectedMarket] ?? currentData['base'] as double;
    final qty = double.tryParse(quantityController.text.trim()) ?? 500;
    final totalEstimatedValue = currentMarketPrice * qty;
    final trend = currentData['trend'] as double;
    final isUp = trend >= 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          "Today's Market Price",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─────────────────────────────
            // NATURAL QUERY CARD
            // ─────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What crop are you checking?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: cropController,
                    decoration: InputDecoration(
                      hintText: 'Search crop...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF167D39),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF6F9F6),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        selectedCrop = val.trim();
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  // Quick crop chips
                  Wrap(
                    spacing: 8,
                    children: popularCrops.map((c) {
                      final isSelected =
                          selectedCrop.toLowerCase() == c.toLowerCase();
                      final cIcon = cropPriceData[c]?['icon'] ?? '🌱';
                      return ChoiceChip(
                        label: Text('$cIcon $c'),
                        selected: isSelected,
                        selectedColor: const Color(0xFFC8E6C9),
                        backgroundColor: const Color(0xFFF1F8E9),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? const Color(0xFF167D39)
                              : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                        onSelected: (val) {
                          if (val) _onSelectCrop(c);
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      // Market Selector
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Which market?',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6F9F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: selectedMarket,
                                  items: markets.map((m) {
                                    return DropdownMenuItem(
                                      value: m,
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            size: 16,
                                            color: Color(0xFF167D39),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            m,
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => selectedMarket = val);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Quantity Selector
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quantity to sell',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: quantityController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '500',
                                suffixText: 'Kg',
                                filled: true,
                                fillColor: const Color(0xFFF6F9F6),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          hasChecked = true;
                        });
                      },
                      icon: const Icon(Icons.analytics_outlined),
                      label: const Text(
                        'Check Price',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF167D39),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─────────────────────────────
            // RESULT CARD
            // ─────────────────────────────
            if (hasChecked) ...[
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFC8E6C9),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(icon, style: const TextStyle(fontSize: 32)),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cropKey,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '$selectedMarket Market',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isUp
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isUp ? Icons.trending_up : Icons.trending_down,
                                size: 16,
                                color: isUp ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${isUp ? '+' : ''}$trend% from yesterday',
                                style: TextStyle(
                                  color: isUp
                                      ? Colors.green.shade800
                                      : Colors.red.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Price display
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '₹${currentMarketPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF167D39),
                          ),
                        ),
                        const Text(
                          ' / Kg',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          "Today's estimated price",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Market range
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Market range',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        Text(
                          '₹${(currentData['min'] as double).toStringAsFixed(0)} ───────── ₹${(currentData['max'] as double).toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 28),

                    // Estimated value for quantity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'For ${qty.toStringAsFixed(0)} Kg',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Estimated value',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              '₹${totalEstimatedValue.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF167D39),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Nearby markets comparison
                    const Text(
                      'Nearby markets',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FBF9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: nearbyMap.entries.map((entry) {
                          final isCurrent = entry.key == selectedMarket;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    if (isCurrent)
                                      const Icon(
                                        Icons.check_circle,
                                        size: 14,
                                        color: Color(0xFF167D39),
                                      )
                                    else
                                      const Icon(
                                        Icons.circle_outlined,
                                        size: 14,
                                        color: Colors.black26,
                                      ),
                                    const SizedBox(width: 8),
                                    Text(
                                      entry.key,
                                      style: TextStyle(
                                        fontWeight: isCurrent
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isCurrent
                                            ? const Color(0xFF167D39)
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '₹${entry.value.toStringAsFixed(0)}/Kg',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isCurrent
                                        ? const Color(0xFF167D39)
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tip box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFE082)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              currentData['tip'] as String,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Action Button to Sell
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/add-crop');
                        },
                        icon: const Icon(Icons.sell_outlined),
                        label: const Text('Sell My Crop at This Price'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF167D39),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ─────────────────────────────
            // LIVE MANDI BOARD
            // ─────────────────────────────
            const Text(
              'Live Tamil Nadu Mandi Board',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Column(
                children: allPrices.take(6).map((item) {
                  final isItemUp = item.changePercent >= 0;
                  return Card(
                    elevation: 0,
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFE8F5E9),
                        child: Text(
                          item.commodity.isNotEmpty ? item.commodity[0] : '🌱',
                          style: const TextStyle(
                            color: Color(0xFF167D39),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        item.commodity,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${item.market} • ${item.district}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${item.modalPrice.toStringAsFixed(0)}/kg',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${isItemUp ? '+' : ''}${item.changePercent}%',
                            style: TextStyle(
                              color: isItemUp ? Colors.green : Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      onTap: () => _onSelectCrop(item.commodity),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
