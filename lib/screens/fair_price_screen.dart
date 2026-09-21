import 'package:flutter/material.dart';

class FairPriceScreen extends StatefulWidget {
  const FairPriceScreen({super.key});

  @override
  State<FairPriceScreen> createState() => _FairPriceScreenState();
}

class _FairPriceScreenState extends State<FairPriceScreen> {
  String selectedCrop = 'Tomato';
  String selectedQuality = 'Good';
  String timeframe = 'Today';
  final quantityController = TextEditingController(text: '500');
  final locationController = TextEditingController(text: 'Panruti');

  bool calculated = true;
  bool isCalculating = false;

  final List<Map<String, String>> crops = [
    {'name': 'Tomato', 'icon': '🍅'},
    {'name': 'Onion', 'icon': '🧅'},
    {'name': 'Potato', 'icon': '🥔'},
    {'name': 'Chilli', 'icon': '🌶️'},
    {'name': 'Paddy', 'icon': '🌾'},
  ];

  final Map<String, Map<String, dynamic>> priceMatrices = {
    'Tomato': {
      'base': 32.0,
      'Premium': {'min': 33.0, 'max': 37.0, 'suggested': 35.0},
      'Good': {'min': 30.0, 'max': 34.0, 'suggested': 33.0},
      'Average': {'min': 26.0, 'max': 29.0, 'suggested': 28.0},
    },
    'Onion': {
      'base': 38.0,
      'Premium': {'min': 40.0, 'max': 45.0, 'suggested': 42.0},
      'Good': {'min': 36.0, 'max': 41.0, 'suggested': 39.0},
      'Average': {'min': 31.0, 'max': 35.0, 'suggested': 33.0},
    },
    'Potato': {
      'base': 26.0,
      'Premium': {'min': 27.0, 'max': 31.0, 'suggested': 29.0},
      'Good': {'min': 24.0, 'max': 28.0, 'suggested': 26.0},
      'Average': {'min': 20.0, 'max': 24.0, 'suggested': 22.0},
    },
    'Chilli': {
      'base': 54.0,
      'Premium': {'min': 58.0, 'max': 66.0, 'suggested': 62.0},
      'Good': {'min': 52.0, 'max': 59.0, 'suggested': 56.0},
      'Average': {'min': 44.0, 'max': 50.0, 'suggested': 47.0},
    },
    'Paddy': {
      'base': 22.0,
      'Premium': {'min': 23.0, 'max': 26.0, 'suggested': 25.0},
      'Good': {'min': 21.0, 'max': 24.0, 'suggested': 23.0},
      'Average': {'min': 18.0, 'max': 21.0, 'suggested': 19.5},
    },
  };

  void _calculate() async {
    setState(() => isCalculating = true);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() {
      isCalculating = false;
      calculated = true;
    });
  }

  @override
  void dispose() {
    quantityController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matrix = priceMatrices[selectedCrop] ?? priceMatrices['Tomato']!;
    final range = matrix[selectedQuality] as Map<String, double>;
    final qty = double.tryParse(quantityController.text.trim()) ?? 500;
    final totalMin = (range['min']! * qty).toStringAsFixed(0);
    final totalMax = (range['max']! * qty).toStringAsFixed(0);
    final suggested = range['suggested']!;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'AI Fair Price',
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
            // CONVERSATIONAL INTRO CARD
            // ─────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5E35B1), Color(0xFF7E57C2)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Row(
                children: [
                  Text('✨', style: TextStyle(fontSize: 36)),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Fair Price Calculator',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Let's calculate a fair, transparent selling price for your harvest.",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ─────────────────────────────
            // GUIDED QUESTIONS
            // ─────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Q1: Crop
                  const Text(
                    'What crop do you have?',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: crops.map((c) {
                      final isSelected = selectedCrop == c['name'];
                      return ChoiceChip(
                        label: Text('${c['icon']} ${c['name']}'),
                        selected: isSelected,
                        selectedColor: const Color(0xFFEDE7F6),
                        backgroundColor: const Color(0xFFF5F5F5),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? const Color(0xFF5E35B1)
                              : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => selectedCrop = c['name']!);
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Q2: Quantity
                  const Text(
                    'How much?',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '500',
                            suffixText: 'Kg',
                            filled: true,
                            fillColor: const Color(0xFFF9F9F9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _qtyChip('+100'),
                      const SizedBox(width: 6),
                      _qtyChip('+500'),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Q3: Quality
                  const Text(
                    'How would you describe the quality?',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _qualityChip('Premium', '🟢'),
                      const SizedBox(width: 8),
                      _qualityChip('Good', '🔵'),
                      const SizedBox(width: 8),
                      _qualityChip('Average', '🟡'),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Q4: Location
                  const Text(
                    'Where are you selling?',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: locationController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.location_on,
                        color: Color(0xFF5E35B1),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9F9F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Q5: Timeframe
                  const Text(
                    'When do you plan to sell?',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: ['Today', 'Tomorrow', 'This week'].map((t) {
                      final isSelected = timeframe == t;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(t),
                          selected: isSelected,
                          selectedColor: const Color(0xFFEDE7F6),
                          backgroundColor: const Color(0xFFF5F5F5),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? const Color(0xFF5E35B1)
                                : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => timeframe = t);
                          },
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 22),

                  // Calculate Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isCalculating ? null : _calculate,
                      icon: isCalculating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: const Text(
                        '✨ Calculate Fair Price',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5E35B1),
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
            if (calculated) ...[
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFD1C4E9),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '✨ AI Fair Price Estimate',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5E35B1),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE7F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$selectedCrop • ${qty.toStringAsFixed(0)} Kg',
                            style: const TextStyle(
                              color: Color(0xFF5E35B1),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Recommended range
                    const Text(
                      'Recommended range',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${range['min']!.toStringAsFixed(0)} – ₹${range['max']!.toStringAsFixed(0)} / Kg',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF167D39),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Estimated total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Estimated total',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        Text(
                          '₹$totalMin – ₹$totalMax',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 28),

                    // Why? Checklist
                    const Text(
                      'Why?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _whyItem(
                      'Current mandi wholesale price (${matrix['base']} / Kg)',
                    ),
                    _whyItem('Crop quality adjustment ($selectedQuality tier)'),
                    _whyItem(
                      'Quantity scale (${qty.toStringAsFixed(0)} Kg batch)',
                    ),
                    _whyItem(
                      'Location (${locationController.text} market rates)',
                    ),
                    _whyItem('Recent local demand & timing ($timeframe)'),

                    const SizedBox(height: 16),

                    // Suggested asking price callout
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE7F6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Suggested asking price',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                '₹${suggested.toStringAsFixed(0)} / Kg',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5E35B1),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // CTA to Sell
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/add-crop');
                        },
                        icon: const Icon(Icons.storefront_outlined),
                        label: const Text(
                          'Sell My Crop at This Price',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _qtyChip(String label) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: const Color(0xFFEDE7F6),
      onPressed: () {
        final current = double.tryParse(quantityController.text) ?? 0;
        final add = double.parse(label.replaceAll('+', ''));
        setState(() {
          quantityController.text = (current + add).toStringAsFixed(0);
        });
      },
    );
  }

  Widget _qualityChip(String quality, String emoji) {
    final isSelected = selectedQuality == quality;
    return ChoiceChip(
      label: Text('$emoji $quality'),
      selected: isSelected,
      selectedColor: const Color(0xFFEDE7F6),
      backgroundColor: const Color(0xFFF5F5F5),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF5E35B1) : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (val) {
        if (val) setState(() => selectedQuality = quality);
      },
    );
  }

  Widget _whyItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const Icon(Icons.check, size: 16, color: Color(0xFF167D39)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
