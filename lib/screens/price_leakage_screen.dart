import 'package:flutter/material.dart';
import '../models/price_leakage.dart';
import '../services/price_leakage_service.dart';

class PriceLeakageScreen extends StatefulWidget {
  const PriceLeakageScreen({super.key});

  @override
  State<PriceLeakageScreen> createState() => _PriceLeakageScreenState();
}

class _PriceLeakageScreenState extends State<PriceLeakageScreen> {
  final cropController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();
  String selectedCrop = 'Tomato';
  final quantityController = TextEditingController(text: '500');
  final priceController = TextEditingController(text: '32');
  final transportController = TextEditingController(text: '800');
  final commissionController = TextEditingController(text: '400');
  final otherController = TextEditingController(text: '300');

  PriceLeakage? analysis;
  bool loading = false;
  bool analyzed = true;
  bool isAnalyzing = false;

  Future<void> analyzePrice() async {
    final crop = cropController.text.trim();
  final List<Map<String, String>> crops = [
    {'name': 'Tomato', 'icon': '🍅'},
    {'name': 'Onion', 'icon': '🧅'},
    {'name': 'Potato', 'icon': '🥔'},
    {'name': 'Chilli', 'icon': '🌶️'},
    {'name': 'Paddy', 'icon': '🌾'},
  ];

    final quantity = double.tryParse(quantityController.text.trim());

    final price = double.tryParse(priceController.text.trim());

    if (crop.isEmpty ||
        quantity == null ||
        price == null ||
        quantity <= 0 ||
        price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid crop, quantity and price.'),
        ),
      );

      return;
    }

  void _analyze() async {
    setState(() => isAnalyzing = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      loading = true;
      analysis = null;
      isAnalyzing = false;
      analyzed = true;
    });

    final result = await PriceLeakageService.analyze(
      crop: crop,
      quantity: quantity,
      farmerPrice: price,
    );

    setState(() {
      analysis = result;
      loading = false;
    });
  }

  @override
  void dispose() {
    cropController.dispose();
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
    final leakagePercent = gross > 0 ? ((totalLeakage / gross) * 100).toStringAsFixed(1) : '0';

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
          'Price Leakage',
          style: TextStyle(fontWeight: FontWeight.bold),
          'Price Leakage Check',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Where Is Your Money Going?',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD84315)),
                  ),
                  const SizedBox(height: 16),

            const SizedBox(height: 6),
                  // Crop
                  const Text('Crop', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
                          color: isSelected ? const Color(0xFFD84315) : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => selectedCrop = c['name']!);
                        },
                      );
                    }).toList(),
                  ),

            const Text(
              'Understand how your crop price changes across the supply chain.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
                  const SizedBox(height: 16),

            const SizedBox(height: 20),
                  Row(
                    children: [
                      // Quantity
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Quantity', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

            _inputField(
              controller: cropController,
              label: 'Crop Name',
              hint: 'Example: Tomato',
              icon: Icons.agriculture,
            ),
                      // Selling price
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Selling price', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

            const SizedBox(height: 14),
                  const SizedBox(height: 16),

            _inputField(
              controller: quantityController,
              label: 'Quantity (Kg)',
              hint: 'Example: 500',
              icon: Icons.inventory_2,
              number: true,
            ),
                  // Financial Costs
                  Row(
                    children: [
                      Expanded(
                        child: _costInputField('Transport cost', transportController, '800'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _costInputField('Commission', commissionController, '400'),
                      ),
                    ],
                  ),

            const SizedBox(height: 14),
                  const SizedBox(height: 12),

            _inputField(
              controller: priceController,
              label: 'Farmer Selling Price / Kg',
              hint: 'Example: 25',
              icon: Icons.currency_rupee,
              decimal: true,
            ),
                  _costInputField('Other expenses (packaging, handling)', otherController, '300'),

            const SizedBox(height: 18),
                  const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: loading ? null : analyzePrice,
                icon: const Icon(Icons.analytics),
                label: Text(loading ? 'Analysing...' : 'Analyse Price Leakage'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isAnalyzing ? null : _analyze,
                      icon: isAnalyzing
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.search),
                      label: const Text('🔍 Analyse Price Leakage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD84315),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            const SizedBox(height: 24),

            if (loading) const Center(child: CircularProgressIndicator()),
            // ─────────────────────────────
            // WATERFALL RESULT CARD
            // ─────────────────────────────
            if (analyzed) ...[
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFFFCCBC), width: 1.5),
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
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$leakagePercent% Leakage',
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),

            if (analysis != null) _analysisView(analysis!),
          ],
        ),
      ),
    );
  }
                    const SizedBox(height: 16),

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool number = false,
    bool decimal = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: number || decimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
                    _receiptRow('Gross value', '₹${gross.toStringAsFixed(0)}', isPositive: true),
                    const SizedBox(height: 8),
                    _receiptRow('Transport', '- ₹${transport.toStringAsFixed(0)}', isDeduction: true),
                    _receiptRow('Commission', '- ₹${commission.toStringAsFixed(0)}', isDeduction: true),
                    _receiptRow('Other expenses', '- ₹${other.toStringAsFixed(0)}', isDeduction: true),

  Widget _analysisView(PriceLeakage data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _summaryCard(data),
                    const Divider(height: 28, thickness: 1.2),

        const SizedBox(height: 20),
                    // Net Received
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'You receive',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

        const Text(
          'Supply Chain Price Journey',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
                    const SizedBox(height: 6),

        const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total price leakage',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        Text(
                          '₹${totalLeakage.toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),

        ...data.stages.asMap().entries.map((entry) {
          final index = entry.key;
          final stage = entry.value;
                    const SizedBox(height: 20),

          return _stageCard(stage, index, data.stages.length);
        }),
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
                          const Text('Main cost:', style: TextStyle(fontSize: 12, color: Colors.black54)),
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
                            style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Compare nearby buyers or share transport before accepting the deal to save ₹300 – ₹600.',
                            style: TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),

        const SizedBox(height: 20),
                    const SizedBox(height: 18),

        _insightCard(data),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.orange.withValues(alpha: 0.10),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Colors.orange),

              SizedBox(width: 10),

              Expanded(
                child: Text(
                  'This is a prototype estimate. Actual supply-chain '
                  'margins vary by crop, location, season, transportation, '
                  'quality and market conditions.',
                  style: TextStyle(fontSize: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/buyer-matching');
                        },
                        icon: const Icon(Icons.people_outline),
                        label: const Text('Find Direct Nearby Buyers to Reduce Cost'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD84315),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
            const SizedBox(height: 20),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard(PriceLeakage data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.cropName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  'Farmer Value',
                  '₹${data.farmerRevenue.toStringAsFixed(0)}',
                ),
              ),

              Expanded(
                child: _summaryItem(
                  'Consumer Value',
                  '₹${data.consumerValue.toStringAsFixed(0)}',
                ),
              ),
            ],
          ),

          const Divider(height: 28),

          Text(
            'Estimated Price Gap',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            '₹${data.leakageAmount.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),

          Text(
            '${data.leakagePercent.toStringAsFixed(1)}% of consumer value',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String title, String value) {
  Widget _costInputField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12)),

        const SizedBox(height: 4),

        Text(
          value,
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: '₹ ',
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF9F9F9),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

  Widget _stageCard(PriceStage stage, int index, int total) {
    return Column(
  Widget _receiptRow(String label, String amount, {bool isPositive = false, bool isDeduction = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 25,
                  child: Text(stage.icon, style: const TextStyle(fontSize: 21)),
                ),

                if (index < total - 1)
                  Container(width: 2, height: 45, color: Colors.grey.shade300),
              ],
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stage.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              '₹${stage.pricePerKg.toStringAsFixed(2)} / Kg',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      Text(
                        '₹${stage.totalValue.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
            color: isDeduction ? Colors.red.shade700 : (isPositive ? Colors.black87 : Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _insightCard(PriceLeakage data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        color: Colors.green.withValues(alpha: 0.10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.green),

              SizedBox(width: 8),

              Text(
                'Smart Insight',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            'The estimated consumer price is '
            '${(data.consumerPrice / data.farmerPrice).toStringAsFixed(1)}× '
            'the farmer selling price.',
          ),

          const SizedBox(height: 8),

          const Text(
            'Direct farmer-to-buyer trading can potentially '
            'reduce unnecessary transaction layers and improve '
            'price transparency.',
          ),
        ],
      ),
    );
  }
}
