import 'package:flutter/material.dart';

import '../models/demand_prediction.dart';
import '../services/demand_prediction_service.dart';

class DemandPredictionScreen extends StatefulWidget {
  const DemandPredictionScreen({super.key});

  @override
  State<DemandPredictionScreen> createState() => _DemandPredictionScreenState();
}

class _DemandPredictionScreenState extends State<DemandPredictionScreen> {
  final cropController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();
  final locationController = TextEditingController();

  DemandPrediction? result;

  bool loading = false;

  Future<void> predictDemand() async {
    if (cropController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        quantityController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final price = double.tryParse(priceController.text);

    final quantity = double.tryParse(quantityController.text);

    if (price == null || quantity == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter valid numbers')));
      return;
    }

    setState(() {
      loading = true;
      result = null;
    });

    final prediction = await DemandPredictionService.predictDemand(
      cropName: cropController.text.trim(),
      currentPrice: price,
      quantity: quantity,
      location: locationController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      result = prediction;
      loading = false;
    });
  }

  @override
  void dispose() {
    cropController.dispose();
    priceController.dispose();
    quantityController.dispose();
    locationController.dispose();
    super.dispose();
  }

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Demand Prediction',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.indigo.shade400],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_graph, color: Colors.white, size: 38),

                  SizedBox(height: 12),

                  Text(
                    'AI Demand Predictor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 7),

                  Text(
                    'Understand future crop demand and plan your selling strategy.',
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
              decoration: inputDecoration('Crop Name', Icons.eco),
            ),

            const SizedBox(height: 14),

            // CURRENT PRICE
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: inputDecoration(
                'Current Market Price (₹/Kg)',
                Icons.currency_rupee,
              ),
            ),

            const SizedBox(height: 14),

            // QUANTITY
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: inputDecoration(
                'Available Quantity (Kg)',
                Icons.scale,
              ),
            ),

            const SizedBox(height: 14),

            // LOCATION
            TextField(
              controller: locationController,
              decoration: inputDecoration(
                'Market / Farm Location',
                Icons.location_on,
              ),
            ),

            const SizedBox(height: 22),

            // BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: loading ? null : predictDemand,
                icon: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_graph),
                label: Text(
                  loading ? 'Analysing Demand...' : 'Predict Demand',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            if (result != null) _buildResult(result!),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(DemandPrediction prediction) {
    final bool highDemand = prediction.demandLevel == 'HIGH';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Demand Forecast',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 14),

        // MAIN CARD
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: highDemand ? Colors.green.shade50 : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: highDemand
                  ? Colors.green.shade200
                  : Colors.orange.shade200,
            ),
          ),
          child: Column(
            children: [
              Text(
                prediction.cropName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                '${prediction.currentDemand.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: highDemand ? Colors.green : Colors.orange,
                ),
              ),

              const Text(
                'Current Demand',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: highDemand ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  prediction.demandLevel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        // CHANGE + CONFIDENCE
        Row(
          children: [
            Expanded(
              child: _statCard(
                'Expected Change',
                '+${prediction.expectedChange.toStringAsFixed(0)}%',
                Icons.trending_up,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _statCard(
                'AI Confidence',
                '${prediction.confidence}%',
                Icons.psychology,
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        // SELLING WINDOW
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_month, color: Colors.blue, size: 30),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Suggested Selling Window',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      prediction.bestSellingWindow,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          '7-Day Demand Forecast',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 15),

        _forecastChart(prediction.forecast),

        const SizedBox(height: 15),

        // EXPLANATION
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Colors.blue),

              SizedBox(width: 10),

              Expanded(
                child: Text(
                  'Demand prediction is an estimate based on available market information. Actual demand may change because of weather, supply, festivals, transport and other market conditions.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue),

          const SizedBox(height: 8),

          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _forecastChart(List<double> forecast) {
    final days = [
      'Today',
      'Day 2',
      'Day 3',
      'Day 4',
      'Day 5',
      'Day 6',
      'Day 7',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: List.generate(forecast.length, (index) {
          final value = forecast[index].clamp(0, 100);

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                SizedBox(
                  width: 55,
                  child: Text(
                    days[index],
                    style: const TextStyle(fontSize: 12),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: value / 100,
                      minHeight: 13,
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                SizedBox(
                  width: 38,
                  child: Text(
                    '${value.toStringAsFixed(0)}%',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
