import 'package:flutter/material.dart';

import '../models/fair_price.dart';
import '../services/fair_price_service.dart';

class FairPriceScreen extends StatefulWidget {
  const FairPriceScreen({super.key});

  @override
  State<FairPriceScreen> createState() => _FairPriceScreenState();
}

class _FairPriceScreenState extends State<FairPriceScreen> {
  final cropController = TextEditingController();

  final quantityController = TextEditingController();

  final marketPriceController = TextEditingController();

  final locationController = TextEditingController();

  FairPrice? result;

  bool loading = false;

  Future<void> calculatePrice() async {
    if (cropController.text.trim().isEmpty ||
        quantityController.text.trim().isEmpty ||
        marketPriceController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));

      return;
    }

    final quantity = double.tryParse(quantityController.text);

    final marketPrice = double.tryParse(marketPriceController.text);

    if (quantity == null || marketPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numbers')),
      );

      return;
    }

    setState(() {
      loading = true;
      result = null;
    });

    final data = await FairPriceService.calculateFairPrice(
      cropName: cropController.text.trim(),
      marketPrice: marketPrice,
      quantity: quantity,
      location: locationController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      result = data;
      loading = false;
    });
  }

  @override
  void dispose() {
    cropController.dispose();
    quantityController.dispose();
    marketPriceController.dispose();
    locationController.dispose();

    super.dispose();
  }

  InputDecoration fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Fair Price')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade700, Colors.green.shade400],
                ),

                borderRadius: BorderRadius.circular(22),
              ),

              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 35),

                  SizedBox(height: 10),

                  Text(
                    'AI Fair Price Advisor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    'Get an estimated fair selling price based on market conditions.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Crop Information',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            // CROP
            TextField(
              controller: cropController,
              decoration: fieldDecoration('Crop Name', Icons.eco),
            ),

            const SizedBox(height: 14),

            // QUANTITY
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: fieldDecoration('Quantity (Kg)', Icons.scale),
            ),

            const SizedBox(height: 14),

            // MARKET PRICE
            TextField(
              controller: marketPriceController,
              keyboardType: TextInputType.number,
              decoration: fieldDecoration(
                'Current Market Price (₹/Kg)',
                Icons.currency_rupee,
              ),
            ),

            const SizedBox(height: 14),

            // LOCATION
            TextField(
              controller: locationController,
              decoration: fieldDecoration(
                'Farm / Market Location',
                Icons.location_on,
              ),
            ),

            const SizedBox(height: 22),

            // BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed: loading ? null : calculatePrice,

                icon: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome),

                label: Text(
                  loading ? 'Analysing...' : 'Calculate Fair Price',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            if (result != null) _buildResult(result!),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(FairPrice result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          'AI Recommendation',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 14),

        // MAIN RESULT
        Container(
          width: double.infinity,

          padding: const EdgeInsets.all(22),

          decoration: BoxDecoration(
            color: Colors.green.shade50,

            borderRadius: BorderRadius.circular(22),

            border: Border.all(color: Colors.green.shade200),
          ),

          child: Column(
            children: [
              const Text(
                'Recommended Fair Price',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 5),

              Text(
                '₹${result.recommendedPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              const Text('per Kg', style: TextStyle(color: Colors.grey)),

              const SizedBox(height: 15),

              Text(
                'Suggested range: '
                '₹${result.minimumPrice.toStringAsFixed(0)}'
                ' - '
                '₹${result.maximumPrice.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        // STATS
        Row(
          children: [
            Expanded(
              child: _infoCard(
                'Market Price',
                '₹${result.currentMarketPrice.toStringAsFixed(0)}',
                Icons.store,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _infoCard(
                'Demand',
                '${result.demandScore.toStringAsFixed(0)}%',
                Icons.trending_up,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        _infoCard('AI Confidence', '${result.confidence}%', Icons.psychology),

        const SizedBox(height: 15),

        // REASON
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
          ),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Icon(Icons.lightbulb, color: Colors.blue),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  result.reason,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        // ACTION
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(16),
          ),

          child: Text(
            result.recommendation,
            style: TextStyle(
              color: Colors.orange.shade900,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'Note: This is an estimated recommendation, not a guaranteed selling price.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _infoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: Colors.grey.shade200),
      ),

      child: Row(
        children: [
          Icon(icon, color: Colors.green),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
