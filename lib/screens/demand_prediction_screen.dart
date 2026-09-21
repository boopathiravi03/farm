import 'package:flutter/material.dart';

class DemandPredictionScreen extends StatefulWidget {
  const DemandPredictionScreen({super.key});

  @override
  State<DemandPredictionScreen> createState() => _DemandPredictionScreenState();
}

class _DemandPredictionScreenState extends State<DemandPredictionScreen> {
  String selectedCrop = 'Tomato';
  DateTime selectedDate = DateTime.now().add(const Duration(days: 2));
  final quantityController = TextEditingController(text: '500');
  final locationController = TextEditingController(text: 'Panruti');

  bool forecasted = true;
  bool isForecasting = false;

  final List<Map<String, String>> crops = [
    {'name': 'Tomato', 'icon': '🍅'},
    {'name': 'Onion', 'icon': '🧅'},
    {'name': 'Potato', 'icon': '🥔'},
    {'name': 'Chilli', 'icon': '🌶️'},
    {'name': 'Paddy', 'icon': '🌾'},
  ];

  final Map<String, List<Map<String, dynamic>>> weeklyDemand = {
    'Tomato': [
      {'day': 'Mon', 'level': 'High', 'score': 0.82, 'color': Colors.green},
      {
        'day': 'Tue',
        'level': 'Very High',
        'score': 0.95,
        'color': Color(0xFF1B5E20),
      },
      {'day': 'Wed', 'level': 'Medium', 'score': 0.60, 'color': Colors.orange},
      {'day': 'Thu', 'level': 'High', 'score': 0.78, 'color': Colors.green},
      {
        'day': 'Fri',
        'level': 'Very High',
        'score': 0.92,
        'color': Color(0xFF1B5E20),
      },
      {'day': 'Sat', 'level': 'Medium', 'score': 0.55, 'color': Colors.orange},
      {'day': 'Sun', 'level': 'Low', 'score': 0.35, 'color': Colors.redAccent},
    ],
    'Onion': [
      {'day': 'Mon', 'level': 'Medium', 'score': 0.65, 'color': Colors.orange},
      {'day': 'Tue', 'level': 'High', 'score': 0.80, 'color': Colors.green},
      {'day': 'Wed', 'level': 'High', 'score': 0.85, 'color': Colors.green},
      {
        'day': 'Thu',
        'level': 'Very High',
        'score': 0.90,
        'color': Color(0xFF1B5E20),
      },
      {'day': 'Fri', 'level': 'High', 'score': 0.75, 'color': Colors.green},
      {'day': 'Sat', 'level': 'Medium', 'score': 0.60, 'color': Colors.orange},
      {'day': 'Sun', 'level': 'Medium', 'score': 0.50, 'color': Colors.orange},
    ],
    'Potato': [
      {'day': 'Mon', 'level': 'Medium', 'score': 0.55, 'color': Colors.orange},
      {'day': 'Tue', 'level': 'Medium', 'score': 0.60, 'color': Colors.orange},
      {'day': 'Wed', 'level': 'High', 'score': 0.75, 'color': Colors.green},
      {'day': 'Thu', 'level': 'High', 'score': 0.82, 'color': Colors.green},
      {
        'day': 'Fri',
        'level': 'Very High',
        'score': 0.90,
        'color': Color(0xFF1B5E20),
      },
      {'day': 'Sat', 'level': 'Medium', 'score': 0.65, 'color': Colors.orange},
      {'day': 'Sun', 'level': 'Low', 'score': 0.40, 'color': Colors.redAccent},
    ],
    'Chilli': [
      {'day': 'Mon', 'level': 'High', 'score': 0.85, 'color': Colors.green},
      {'day': 'Tue', 'level': 'High', 'score': 0.88, 'color': Colors.green},
      {
        'day': 'Wed',
        'level': 'Very High',
        'score': 0.96,
        'color': Color(0xFF1B5E20),
      },
      {'day': 'Thu', 'level': 'High', 'score': 0.84, 'color': Colors.green},
      {'day': 'Fri', 'level': 'Medium', 'score': 0.65, 'color': Colors.orange},
      {'day': 'Sat', 'level': 'Medium', 'score': 0.58, 'color': Colors.orange},
      {'day': 'Sun', 'level': 'Low', 'score': 0.30, 'color': Colors.redAccent},
    ],
    'Paddy': [
      {'day': 'Mon', 'level': 'High', 'score': 0.75, 'color': Colors.green},
      {'day': 'Tue', 'level': 'High', 'score': 0.78, 'color': Colors.green},
      {'day': 'Wed', 'level': 'High', 'score': 0.80, 'color': Colors.green},
      {
        'day': 'Thu',
        'level': 'Very High',
        'score': 0.88,
        'color': Color(0xFF1B5E20),
      },
      {'day': 'Fri', 'level': 'High', 'score': 0.82, 'color': Colors.green},
      {'day': 'Sat', 'level': 'Medium', 'score': 0.60, 'color': Colors.orange},
      {'day': 'Sun', 'level': 'Medium', 'score': 0.50, 'color': Colors.orange},
    ],
  };

  void _forecast() async {
    setState(() => isForecasting = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      isForecasting = false;
      forecasted = true;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  void dispose() {
    quantityController.dispose();
    locationController.dispose();
    super.dispose();
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
            // ─────────────────────────────
            // INPUT CARD
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
                    'Which crop?',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

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
                          color: isSelected
                              ? const Color(0xFF1565C0)
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

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      // Quantity
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'How much quantity?',
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
                                enabledBorder: OutlineInputBorder(
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

                      // Expected Selling Date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Expected selling date?',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: _pickDate,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9F9F9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_month,
                                      size: 18,
                                      color: Color(0xFF1565C0),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${selectedDate.day}/${selectedDate.month}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
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

                  const SizedBox(height: 18),

                  const Text(
                    'Your location',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: locationController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.location_on,
                        color: Color(0xFF1565C0),
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

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isForecasting ? null : _forecast,
                      icon: isForecasting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.auto_graph),
                      label: const Text(
                        '🔮 Forecast Demand',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
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
            if (forecasted) ...[
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFBBDEFB),
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
                        Text(
                          '$selectedCrop Demand',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.trending_up,
                                size: 16,
                                color: Color(0xFF167D39),
                              ),
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

                    const SizedBox(height: 6),
                    const Text(
                      'Next 7 Days Demand Timeline',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),

                    const SizedBox(height: 18),

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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
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
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
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

                    const Divider(height: 28),

                    // Key metrics
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Expected demand:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'HIGH',
                                style: TextStyle(
                                  color: Color(0xFF167D39),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Market movement:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              '↗ Increasing (+18%)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

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
                          Icon(
                            Icons.lightbulb_outline,
                            color: Color(0xFF1565C0),
                            size: 22,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI Suggestion',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xFF1565C0),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Consider listing your crop within the next 2–3 days when demand reaches its peak (Tuesday/Friday).',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
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
                          Navigator.pushNamed(context, '/add-crop');
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text(
                          'List Crop for Upcoming Demand',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
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
}
