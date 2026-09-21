import 'package:flutter/material.dart';
import '../models/buyer_match.dart';
import '../services/buyer_service.dart';

class BuyerMatchingScreen extends StatefulWidget {
  const BuyerMatchingScreen({super.key});

  @override
  State<BuyerMatchingScreen> createState() => _BuyerMatchingScreenState();
}

class _BuyerMatchingScreenState extends State<BuyerMatchingScreen> {
  final TextEditingController cropController = TextEditingController();

  final TextEditingController quantityController = TextEditingController();

  final TextEditingController priceController = TextEditingController();

  List<BuyerMatch> matches = [];

  bool loading = false;

  Future<void> findBuyers() async {
    final String crop = cropController.text.trim();

    final double? quantity = double.tryParse(quantityController.text.trim());

    final double? price = double.tryParse(priceController.text.trim());

    if (crop.isEmpty ||
        quantity == null ||
        price == null ||
        quantity <= 0 ||
        price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter crop, quantity and expected price.'),
        ),
      );

      return;
    }

    setState(() {
      loading = true;
      matches = [];
    });

    final result = await BuyerService.findMatches(
      crop: crop,
      quantity: quantity,
      expectedPrice: price,
    );

    setState(() {
      matches = result;
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
          'Find Buyers',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Find the Right Buyer',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            const Text(
              'We will find buyers who match your crop, quantity and price.',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: cropController,
              decoration: InputDecoration(
                labelText: 'Crop Name',
                hintText: 'Example: Tomato',
                prefixIcon: const Icon(Icons.agriculture),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 14),

            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantity (Kg)',
                hintText: 'Example: 500',
                prefixIcon: const Icon(Icons.inventory_2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 14),

            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Expected Price / Kg',
                hintText: 'Example: 25',
                prefixIcon: const Icon(Icons.currency_rupee),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: loading ? null : findBuyers,
                icon: const Icon(Icons.search),
                label: Text(
                  loading ? 'Finding Buyers...' : 'Find Matching Buyers',
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

            if (!loading && matches.isNotEmpty) ...[
              Text(
                '${matches.length} Matching Buyers Found',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              ...matches.map((match) => _buyerCard(match)),
            ],

            if (!loading && matches.isEmpty && cropController.text.isNotEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Text(
                    'No matching buyers found.\nTry another crop or quantity.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buyerCard(BuyerMatch match) {
    final buyer = match.buyer;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 27,
                  child: Text(
                    buyer.name[0],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        buyer.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        buyer.company,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.green.withValues(alpha: 0.12),
                  ),
                  child: Text(
                    '${match.matchScore.round()}% Match',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 25),

            Row(
              children: [
                Expanded(child: _infoItem(Icons.location_on, buyer.location)),

                Expanded(
                  child: _infoItem(
                    Icons.route,
                    '${match.distanceKm.toStringAsFixed(1)} km',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _infoItem(
                    Icons.inventory_2,
                    '${buyer.requiredQuantity.toStringAsFixed(0)} Kg needed',
                  ),
                ),

                Expanded(
                  child: _infoItem(
                    Icons.currency_rupee,
                    'Up to ₹${buyer.maxPrice.toStringAsFixed(0)}/Kg',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.blue.withValues(alpha: 0.08),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.auto_awesome, size: 20),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      match.reason,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Offer request sent to ${buyer.name}.'),
                    ),
                  );
                },
                icon: const Icon(Icons.send),
                label: const Text('Send Offer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18),

        const SizedBox(width: 6),

        Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
      ],
    );
  }
}
