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

  PriceLeakage? analysis;
  bool loading = false;

  Future<void> analyzePrice() async {
    final crop = cropController.text.trim();

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

    setState(() {
      loading = true;
      analysis = null;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Price Leakage',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Where Is Your Money Going?',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            const Text(
              'Understand how your crop price changes across the supply chain.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),

            const SizedBox(height: 20),

            _inputField(
              controller: cropController,
              label: 'Crop Name',
              hint: 'Example: Tomato',
              icon: Icons.agriculture,
            ),

            const SizedBox(height: 14),

            _inputField(
              controller: quantityController,
              label: 'Quantity (Kg)',
              hint: 'Example: 500',
              icon: Icons.inventory_2,
              number: true,
            ),

            const SizedBox(height: 14),

            _inputField(
              controller: priceController,
              label: 'Farmer Selling Price / Kg',
              hint: 'Example: 25',
              icon: Icons.currency_rupee,
              decimal: true,
            ),

            const SizedBox(height: 18),

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
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            if (loading) const Center(child: CircularProgressIndicator()),

            if (analysis != null) _analysisView(analysis!),
          ],
        ),
      ),
    );
  }

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

  Widget _analysisView(PriceLeakage data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _summaryCard(data),

        const SizedBox(height: 20),

        const Text(
          'Supply Chain Price Journey',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        ...data.stages.asMap().entries.map((entry) {
          final index = entry.key;
          final stage = entry.value;

          return _stageCard(stage, index, data.stages.length);
        }),

        const SizedBox(height: 20),

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
                ),
              ),
            ],
          ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12)),

        const SizedBox(height: 4),

        Text(
          value,
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _stageCard(PriceStage stage, int index, int total) {
    return Column(
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
