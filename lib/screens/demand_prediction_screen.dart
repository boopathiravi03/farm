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
  String selectedCrop = 'Tomato';
  DateTime selectedDate = DateTime.now().add(const Duration(days: 2));
  final quantityController = TextEditingController(text: '500');
  final locationController = TextEditingController(text: 'Panruti');

  DemandPrediction? result;
  bool forecasted = true;
  bool isForecasting = false;

  bool loading = false;
  final List<Map<String, String>> crops = [
    {'name': 'Tomato', 'icon': '🍅'},
    {'name': 'Onion', 'icon': '🧅'},
    {'name': 'Potato', 'icon': '🥔'},
    {'name': 'Chilli', 'icon': '🌶️'},
    {'name': 'Paddy', 'icon': '🌾'},
  ];

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
  final Map<String, List<Map<String, dynamic>>> weeklyDemand = {
    'Tomato': [
      {'day': 'Mon', 'level': 'High', 'score': 0.82, 'color': Colors.green},
      {'day': 'Tue', 'level': 'Very High', 'score': 0.95, 'color': Color(0xFF1B5E20)},
      {'day': 'Wed', 'level': 'Medium', 'score': 0.60, 'color': Colors.orange},
      {'day': 'Thu', 'level': 'High', 'score': 0.78, 'color': Colors.green},
      {'day': 'Fri', 'level': 'Very High', 'score': 0.92, 'color': Color(0xFF1B5E20)},
      {'day': 'Sat', 'level': 'Medium', 'score': 0.55, 'color': Colors.orange},
      {'day': 'Sun', 'level': 'Low', 'score': 0.35, 'color': Colors.redAccent},
    ],
    'Onion': [
      {'day': 'Mon', 'level': 'Medium', 'score': 0.65, 'color': Colors.orange},
      {'day': 'Tue', 'level': 'High', 'score': 0.80, 'color': Colors.green},
      {'day': 'Wed', 'level': 'High', 'score': 0.85, 'color': Colors.green},
      {'day': 'Thu', 'level': 'Very High', 'score': 0.90, 'color': Color(0xFF1B5E20)},
      {'day': 'Fri', 'level': 'High', 'score': 0.75, 'color': Colors.green},
      {'day': 'Sat', 'level': 'Medium', 'score': 0.60, 'color': Colors.orange},
      {'day': 'Sun', 'level': 'Medium', 'score': 0.50, 'color': Colors.orange},
    ],
    'Potato': [
      {'day': 'Mon', 'level': 'Medium', 'score': 0.55, 'color': Colors.orange},
      {'day': 'Tue', 'level': 'Medium', 'score': 0.60, 'color': Colors.orange},
      {'day': 'Wed', 'level': 'High', 'score': 0.75, 'color': Colors.green},
      {'day': 'Thu', 'level': 'High', 'score': 0.82, 'color': Colors.green},
      {'day': 'Fri', 'level': 'Very High', 'score': 0.90, 'color': Color(0xFF1B5E20)},
      {'day': 'Sat', 'level': 'Medium', 'score': 0.65, 'color': Colors.orange},
      {'day': 'Sun', 'level': 'Low', 'score': 0.40, 'color': Colors.redAccent},
    ],
    'Chilli': [
      {'day': 'Mon', 'level': 'High', 'score': 0.85, 'color': Colors.green},
      {'day': 'Tue', 'level': 'High', 'score': 0.88, 'color': Colors.green},
      {'day': 'Wed', 'level': 'Very High', 'score': 0.96, 'color': Color(0xFF1B5E20)},
      {'day': 'Thu', 'level': 'High', 'score': 0.84, 'color': Colors.green},
      {'day': 'Fri', 'level': 'Medium', 'score': 0.65, 'color': Colors.orange},
      {'day': 'Sat', 'level': 'Medium', 'score': 0.58, 'color': Colors.orange},
      {'day': 'Sun', 'level': 'Low', 'score': 0.30, 'color': Colors.redAccent},
    ],
    'Paddy': [
      {'day': 'Mon', 'level': 'High', 'score': 0.75, 'color': Colors.green},
      {'day': 'Tue', 'level': 'High', 'score': 0.78, 'color': Colors.green},
      {'day': 'Wed', 'level': 'High', 'score': 0.80, 'color': Colors.green},
      {'day': 'Thu', 'level': 'Very High', 'score': 0.88, 'color': Color(0xFF1B5E20)},
      {'day': 'Fri', 'level': 'High', 'score': 0.82, 'color': Colors.green},
      {'day': 'Sat', 'level': 'Medium', 'score': 0.60, 'color': Colors.orange},
      {'day': 'Sun', 'level': 'Medium', 'score': 0.50, 'color': Colors.orange},
    ],
  };

    final price = double.tryParse(priceController.text);

    final quantity = double.tryParse(quantityController.text);

    if (price == null || quantity == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter valid numbers')));
      return;
    }

  void _forecast() async {
    setState(() => isForecasting = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      loading = true;
      result = null;
      isForecasting = false;
      forecasted = true;
    });
  }

    final prediction = await DemandPredictionService.predictDemand(
      cropName: cropController.text.trim(),
      currentPrice: price,
      quantity: quantity,
      location: locationController.text.trim(),
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (!mounted) return;

    setState(() {
      result = prediction;
      loading = false;
    });
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
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
    final days = weeklyDemand[selectedCrop] ?? weeklyDemand['Tomato']!;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'AI Demand Prediction',
          style: TextStyle(fontWeight: FontWeight.bold),
          'Demand Forecast',
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
            // HEADER
            // ─────────────────────────────
            // INPUT CARD
            // ─────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.indigo.shade400],
                ),
                borderRadius: BorderRadius.circular(22),
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
              child: const Column(
              child: Column(
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
                  const Text(
                    'Which crop?',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  SizedBox(height: 7),

                  Text(
                    'Understand future crop demand and plan your selling strategy.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  Wrap(
                    spacing: 8,
                    children: crops.map((c) {
                      final isSelected = selectedCrop == c['name'];
                      return ChoiceChip(
                        label: Text('${c['icon']} ${c['name']}'),
                        selected: isSelected,
                        selectedColor: const Color(0xFFE3F2FD),
                        backgroundColor: const Color(0xFFF5F5F5),
                        labelStyle: TextStyle(
                          color: isSelected ? const Color(0xFF1565C0) : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => selectedCrop = c['name']!);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
                  const SizedBox(height: 18),

            const Text(
              'Crop Information',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
                  Row(
                    children: [
                      // Quantity
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'How much quantity?',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

            const SizedBox(height: 15),
                      // Expected Selling Date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Expected selling date?',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: _pickDate,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9F9F9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_month, size: 18, color: Color(0xFF1565C0)),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${selectedDate.day}/${selectedDate.month}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

            // CROP
            TextField(
              controller: cropController,
              decoration: inputDecoration('Crop Name', Icons.eco),
            ),
                  const SizedBox(height: 18),

            const SizedBox(height: 14),
                  const Text(
                    'Your location',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: locationController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.location_on, color: Color(0xFF1565C0)),
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

            // CURRENT PRICE
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: inputDecoration(
                'Current Market Price (₹/Kg)',
                Icons.currency_rupee,
              ),
            ),
                  const SizedBox(height: 20),

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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isForecasting ? null : _forecast,
                      icon: isForecasting
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.auto_graph),
                      label: const Text('🔮 Forecast Demand', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
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

            const SizedBox(height: 28),
            const SizedBox(height: 24),

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

            // ─────────────────────────────
            // RESULT CARD
            // ─────────────────────────────
            if (forecasted) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: highDemand ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFBBDEFB), width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$selectedCrop Demand',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.trending_up, size: 16, color: Color(0xFF167D39)),
                              SizedBox(width: 4),
                              Text(
                                '↗ Increasing',
                                style: TextStyle(
                                  color: Color(0xFF167D39),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

        const SizedBox(height: 15),
                    const SizedBox(height: 6),
                    const Text('Next 7 Days Demand Timeline', style: TextStyle(color: Colors.black54, fontSize: 13)),

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
                    const SizedBox(height: 18),

            const SizedBox(width: 10),
                    // 7-day Demand Bar Chart
                    Column(
                      children: days.map((d) {
                        final score = d['score'] as double;
                        final color = d['color'] as Color;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 34,
                                child: Text(
                                  d['day'],
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: score,
                                      child: Container(
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 70,
                                child: Text(
                                  d['level'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

            Expanded(
              child: _statCard(
                'AI Confidence',
                '${prediction.confidence}%',
                Icons.psychology,
              ),
            ),
          ],
        ),
                    const Divider(height: 28),

        const SizedBox(height: 15),
                    // Key metrics
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Expected demand:', style: TextStyle(fontSize: 12, color: Colors.black54)),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'HIGH',
                                style: TextStyle(color: Color(0xFF167D39), fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Market movement:', style: TextStyle(fontSize: 12, color: Colors.black54)),
                            const SizedBox(height: 2),
                            const Text(
                              '↗ Increasing (+18%)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1565C0)),
                            ),
                          ],
                        ),
                      ],
                    ),

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
                    const SizedBox(height: 18),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Suggested Selling Window',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    // AI Suggestion Callout
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF90CAF9)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline, color: Color(0xFF1565C0), size: 22),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI Suggestion',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1565C0)),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Consider listing your crop within the next 2–3 days when demand reaches its peak (Tuesday/Friday).',
                                  style: TextStyle(fontSize: 13, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 4),
                    const SizedBox(height: 18),

                    Text(
                      prediction.bestSellingWindow,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/add-crop');
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('List Crop for Upcoming Demand', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
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
