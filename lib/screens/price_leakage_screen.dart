import 'package:flutter/material.dart';

class PriceLeakageScreen extends StatefulWidget {
  const PriceLeakageScreen({super.key});

  @override
  State<PriceLeakageScreen> createState() => _PriceLeakageScreenState();
}

class _PriceLeakageScreenState extends State<PriceLeakageScreen> {
  String selectedCrop = 'Tomato';
  final quantityController = TextEditingController(text: '500');
  final priceController = TextEditingController(text: '32');
  final transportController = TextEditingController(text: '800');
  final commissionController = TextEditingController(text: '400');
  final otherController = TextEditingController(text: '300');

  bool analyzed = true;
  bool isAnalyzing = false;

  final List<Map<String, String>> crops = [
    {'name': 'Tomato', 'icon': '🍅'},
    {'name': 'Onion', 'icon': '🧅'},
    {'name': 'Potato', 'icon': '🥔'},
    {'name': 'Chilli', 'icon': '🌶️'},
    {'name': 'Paddy', 'icon': '🌾'},
  ];

  void _analyze() async {
    setState(() => isAnalyzing = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      isAnalyzing = false;
      analyzed = true;
    });
  }

  @override
  void dispose() {
    quantityController.dispose();
    priceController.dispose();
    transportController.dispose();
    commissionController.dispose();
    otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qty = double.tryParse(quantityController.text.trim()) ?? 500;
    final price = double.tryParse(priceController.text.trim()) ?? 32;
    final transport = double.tryParse(transportController.text.trim()) ?? 800;
    final commission = double.tryParse(commissionController.text.trim()) ?? 400;
    final other = double.tryParse(otherController.text.trim()) ?? 300;

    final gross = qty * price;
    final totalLeakage = transport + commission + other;
    final netReceived = gross - totalLeakage;
    final leakagePercent = gross > 0
        ? ((totalLeakage / gross) * 100).toStringAsFixed(1)
        : '0';

    // Find main cost
    String mainCostName = 'Transport';
    String mainCostEmoji = '🚚';
    double mainCostValue = transport;

    if (commission > mainCostValue) {
      mainCostName = 'Commission';
      mainCostEmoji = '🤝';
      mainCostValue = commission;
    }
    if (other > mainCostValue) {
      mainCostName = 'Other Expenses';
      mainCostEmoji = '📦';
      mainCostValue = other;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Price Leakage Check',
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
            // FINANCIAL INPUTS
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
                  const Text(
                    "Let's see where your selling money is going.",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD84315),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Crop
                  const Text(
                    'Crop',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: crops.map((c) {
                      final isSelected = selectedCrop == c['name'];
                      return ChoiceChip(
                        label: Text('${c['icon']} ${c['name']}'),
                        selected: isSelected,
                        selectedColor: const Color(0xFFFFCCBC),
                        backgroundColor: const Color(0xFFF5F5F5),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? const Color(0xFFD84315)
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

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      // Quantity
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quantity',
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
                                fillColor: const Color(0xFFF9F9F9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Selling price
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selling price',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                prefixText: '₹ ',
                                suffixText: '/Kg',
                                hintText: '32',
                                filled: true,
                                fillColor: const Color(0xFFF9F9F9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Financial Costs
                  Row(
                    children: [
                      Expanded(
                        child: _costInputField(
                          'Transport cost',
                          transportController,
                          '800',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _costInputField(
                          'Commission',
                          commissionController,
                          '400',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _costInputField(
                    'Other expenses (packaging, handling)',
                    otherController,
                    '300',
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isAnalyzing ? null : _analyze,
                      icon: isAnalyzing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.search),
                      label: const Text(
                        '🔍 Analyse Price Leakage',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD84315),
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
            // WATERFALL RESULT CARD
            // ─────────────────────────────
            if (analyzed) ...[
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFFFCCBC),
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
                          'Your Sale Breakdown',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$leakagePercent% Leakage',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _receiptRow(
                      'Gross value',
                      '₹${gross.toStringAsFixed(0)}',
                      isPositive: true,
                    ),
                    const SizedBox(height: 8),
                    _receiptRow(
                      'Transport',
                      '- ₹${transport.toStringAsFixed(0)}',
                      isDeduction: true,
                    ),
                    _receiptRow(
                      'Commission',
                      '- ₹${commission.toStringAsFixed(0)}',
                      isDeduction: true,
                    ),
                    _receiptRow(
                      'Other expenses',
                      '- ₹${other.toStringAsFixed(0)}',
                      isDeduction: true,
                    ),

                    const Divider(height: 28, thickness: 1.2),

                    // Net Received
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'You receive',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₹${netReceived.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF167D39),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total price leakage',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '₹${totalLeakage.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Main cost highlight
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFFCC80)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Main cost:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$mainCostEmoji $mainCostName — ₹${mainCostValue.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD84315),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Possible saving:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Compare nearby buyers or share transport before accepting the deal to save ₹300 – ₹600.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/buyer-matching');
                        },
                        icon: const Icon(Icons.people_outline),
                        label: const Text(
                          'Find Direct Nearby Buyers to Reduce Cost',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD84315),
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

  Widget _costInputField(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: '₹ ',
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF9F9F9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _receiptRow(
    String label,
    String amount, {
    bool isPositive = false,
    bool isDeduction = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isPositive ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isPositive ? FontWeight.bold : FontWeight.w600,
            color: isDeduction
                ? Colors.red.shade700
                : (isPositive ? Colors.black87 : Colors.black87),
          ),
        ),
      ],
    );
  }
}
