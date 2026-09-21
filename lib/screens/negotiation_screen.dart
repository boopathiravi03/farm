import 'package:flutter/material.dart';

import '../models/negotiation_result.dart';
import '../services/negotiation_service.dart';

class NegotiationScreen extends StatefulWidget {
  const NegotiationScreen({super.key});

  @override
  State<NegotiationScreen> createState() => _NegotiationScreenState();
}

class _NegotiationScreenState extends State<NegotiationScreen> {
  final cropController = TextEditingController();
  final quantityController = TextEditingController();
  final marketPriceController = TextEditingController();
  final fairPriceController = TextEditingController();
  final offerController = TextEditingController();

  NegotiationResult? result;
  bool loading = false;

  Future<void> analyzeNegotiation() async {
    final crop = cropController.text.trim();

    final quantity = double.tryParse(quantityController.text.trim());

    final marketPrice = double.tryParse(marketPriceController.text.trim());

    final fairPrice = double.tryParse(fairPriceController.text.trim());

    final buyerOffer = double.tryParse(offerController.text.trim());

    if (crop.isEmpty ||
        quantity == null ||
        marketPrice == null ||
        fairPrice == null ||
        buyerOffer == null ||
        quantity <= 0 ||
        marketPrice <= 0 ||
        fairPrice <= 0 ||
        buyerOffer <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all valid values.')),
      );

      return;
    }

    setState(() {
      loading = true;
      result = null;
    });

    final response = await NegotiationService.analyze(
      crop: crop,
      quantity: quantity,
      marketPrice: marketPrice,
      fairPrice: fairPrice,
      buyerOffer: buyerOffer,
    );

    setState(() {
      result = response;
      loading = false;
    });
  }

  @override
  void dispose() {
    cropController.dispose();
    quantityController.dispose();
    marketPriceController.dispose();
    fairPriceController.dispose();
    offerController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Negotiation Assistant',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Negotiate Smarter',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            const Text(
              'Get a suggested counter-offer using market and fair-price information.',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            _input(
              cropController,
              'Crop Name',
              'Example: Tomato',
              Icons.agriculture,
            ),

            const SizedBox(height: 13),

            _input(
              quantityController,
              'Quantity (Kg)',
              'Example: 500',
              Icons.inventory_2,
              number: true,
            ),

            const SizedBox(height: 13),

            _input(
              marketPriceController,
              'Current Market Price / Kg',
              'Example: 25',
              Icons.store,
              decimal: true,
            ),

            const SizedBox(height: 13),

            _input(
              fairPriceController,
              'AI Fair Price / Kg',
              'Example: 27',
              Icons.auto_awesome,
              decimal: true,
            ),

            const SizedBox(height: 13),

            _input(
              offerController,
              'Buyer Offer / Kg',
              'Example: 23',
              Icons.handshake,
              decimal: true,
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: loading ? null : analyzeNegotiation,
                icon: const Icon(Icons.auto_awesome),
                label: Text(
                  loading ? 'Analysing...' : 'Get AI Negotiation Advice',
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            if (loading) const Center(child: CircularProgressIndicator()),

            if (result != null) _resultView(result!),
          ],
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
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

  Widget _resultView(NegotiationResult data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _strategyCard(data),

        const SizedBox(height: 18),

        _priceComparison(data),

        const SizedBox(height: 18),

        _messageCard(data),

        const SizedBox(height: 18),

        _revenueCard(data),

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
                  'This is decision-support guidance, not a guaranteed '
                  'selling price. Actual negotiations depend on quality, '
                  'quantity, location, buyer demand and market conditions.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _strategyCard(NegotiationResult data) {
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
          const Row(
            children: [
              Icon(Icons.auto_awesome),

              SizedBox(width: 8),

              Text(
                'AI Strategy',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            data.strategy,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(data.explanation),
        ],
      ),
    );
  }

  Widget _priceComparison(NegotiationResult data) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price Comparison',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            _priceRow('Buyer Offer', data.buyerOffer),

            _priceRow('Market Price', data.fairPrice),

            _priceRow('Recommended Price', data.recommendedPrice),

            _priceRow('Minimum Suggested', data.minimumAcceptablePrice),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String title, double price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(child: Text(title)),

          Text(
            '₹${price.toStringAsFixed(2)}/Kg',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _messageCard(NegotiationResult data) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.chat),

                SizedBox(width: 8),

                Text(
                  'Suggested Message',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.withValues(alpha: 0.08),
              ),
              child: Text(data.message, style: const TextStyle(height: 1.5)),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Negotiation message copied for sending.'),
                    ),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy Message'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _revenueCard(NegotiationResult data) {
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
          const Text('Potential Revenue', style: TextStyle(fontSize: 14)),

          const SizedBox(height: 5),

          Text(
            '₹${data.potentialRevenue.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 5),

          const Text('Estimated revenue at the recommended price.'),
        ],
      ),
    );
  }
}
