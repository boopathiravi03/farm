import 'package:flutter/material.dart';

import '../models/supply_chain_node.dart';
import '../models/supply_chain_twin.dart';
import '../services/supply_chain_service.dart';

class SupplyChainScreen extends StatefulWidget {
  const SupplyChainScreen({super.key});

  @override
  State<SupplyChainScreen> createState() => _SupplyChainScreenState();
}

class _SupplyChainScreenState extends State<SupplyChainScreen> {
  final cropController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();

  SupplyChainTwin? twin;
  bool loading = false;

  Future<void> runSimulation() async {
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
      twin = null;
    });

    final result = await SupplyChainService.simulate(
      crop: crop,
      quantity: quantity,
      farmerPrice: price,
    );

    setState(() {
      twin = result;
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
          'Supply-Chain Digital Twin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Simulate Your Supply Chain',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            const Text(
              'Visualize how your crop moves through the supply chain.',
              style: TextStyle(color: Colors.grey),
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
              hint: 'Example: 1000',
              icon: Icons.inventory_2,
              number: true,
            ),

            const SizedBox(height: 14),

            _inputField(
              controller: priceController,
              label: 'Farmer Price / Kg',
              hint: 'Example: 25',
              icon: Icons.currency_rupee,
              decimal: true,
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: loading ? null : runSimulation,
                icon: const Icon(Icons.play_arrow),
                label: Text(loading ? 'Simulating...' : 'Run Digital Twin'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            if (loading) const Center(child: CircularProgressIndicator()),

            if (twin != null) _buildResult(twin!),
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

  Widget _buildResult(SupplyChainTwin data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _summaryCard(data),

        const SizedBox(height: 22),

        const Text(
          'Live Supply-Chain Simulation',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 5),

        const Text(
          'Crop movement from farm to consumer',
          style: TextStyle(color: Colors.grey),
        ),

        const SizedBox(height: 15),

        ...data.nodes.asMap().entries.map((entry) {
          final index = entry.key;
          final node = entry.value;

          return _nodeCard(node, index, data.nodes.length);
        }),

        const SizedBox(height: 15),

        _optimizationCard(data),

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
                  'Digital Twin values are simulated for the prototype. '
                  'Final implementation will use real logistics, '
                  'market and transaction data.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(SupplyChainTwin data) {
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
            data.crop,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _stat(
                  'Initial',
                  '${data.initialQuantity.toStringAsFixed(0)} Kg',
                ),
              ),

              Expanded(
                child: _stat(
                  'Final',
                  '${data.finalQuantity.toStringAsFixed(0)} Kg',
                ),
              ),
            ],
          ),

          const Divider(height: 28),

          const Text(
            'Potential Logistics Savings',
            style: TextStyle(fontSize: 13),
          ),

          const SizedBox(height: 4),

          Text(
            '₹${data.potentialSavings.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),

          Text(
            '${data.savingsPercent.toStringAsFixed(1)}% estimated reduction',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _stat(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12)),

        const SizedBox(height: 4),

        Text(
          value,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _nodeCard(SupplyChainNode node, int index, int total) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 27,
              child: Text(node.icon, style: const TextStyle(fontSize: 22)),
            ),

            if (index < total - 1)
              Container(width: 3, height: 80, color: Colors.grey.shade300),
          ],
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          node.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Text(
                        node.type,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text('📍 ${node.location}'),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '💰 ₹${node.pricePerKg.toStringAsFixed(2)}/Kg',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),

                      Expanded(
                        child: Text(
                          '📦 ${node.quantity.toStringAsFixed(0)} Kg',
                        ),
                      ),
                    ],
                  ),

                  if (index > 0) ...[
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '📍 ${node.distanceFromPrevious.toStringAsFixed(0)} km',
                          ),
                        ),

                        Expanded(
                          child: Text(
                            '🚚 ₹${node.transportCost.toStringAsFixed(0)}',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '⏱️ ${node.deliveryHours} hour(s)',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _optimizationCard(SupplyChainTwin data) {
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
                'AI Optimization Insight',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            'Traditional logistics cost: '
            '₹${data.traditionalCost.toStringAsFixed(0)}',
          ),

          const SizedBox(height: 5),

          Text(
            'Optimized estimated cost: '
            '₹${data.optimizedCost.toStringAsFixed(0)}',
          ),

          const SizedBox(height: 10),

          Text(
            'Potential saving: '
            '₹${data.potentialSavings.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
