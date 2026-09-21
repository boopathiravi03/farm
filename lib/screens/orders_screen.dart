import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String selectedFilter = 'All';

  final List<Map<String, dynamic>> orders = [
    {
      'id': 'ORD-9821',
      'status': 'Processing',
      'statusColor': Colors.blue,
      'statusIcon': '🔵',
      'crop': 'Tomato',
      'cropIcon': '🍅',
      'quantity': '500 Kg',
      'buyer': 'Arun Traders',
      'buyerLocation': 'Panruti',
      'amount': '₹16,000',
      'date': 'Today, 10:30 AM',
      'step': 1,
    },
    {
      'id': 'ORD-9784',
      'status': 'In Transit',
      'statusColor': Colors.orange,
      'statusIcon': '🟡',
      'crop': 'Chilli',
      'cropIcon': '🌶️',
      'quantity': '200 Kg',
      'buyer': 'Cuddalore Wholesale',
      'buyerLocation': 'Cuddalore',
      'amount': '₹11,000',
      'date': 'Yesterday',
      'step': 2,
    },
    {
      'id': 'ORD-9650',
      'status': 'Delivered',
      'statusColor': Colors.green,
      'statusIcon': '🟢',
      'crop': 'Onion',
      'cropIcon': '🧅',
      'quantity': '300 Kg',
      'buyer': 'Kumar Agro Foods',
      'buyerLocation': 'Panruti',
      'amount': '₹9,600',
      'date': '19 Sep 2026',
      'step': 3,
    },
  ];

  void _showTrackingModal(Map<String, dynamic> o) {
    final step = o['step'] as int;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Track Order ${o['id']}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${o['crop']} (${o['quantity']}) • ${o['buyer']}',
                        style: const TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),

              _timelineStep('Order Placed & Accepted', 'Payment secured in Farm Trading Escrow', step >= 0),
              _timelineStep('Harvest Packaging Complete', 'Quality verified Good • Ready for pickup', step >= 1),
              _timelineStep('Vehicle Dispatched / In Transit', 'Driver assigned (TN-31-AB-4812)', step >= 2),
              _timelineStep('Delivered & Funds Released', 'Direct transfer to your registered bank account', step >= 3),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF167D39),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Close Tracking'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _timelineStep(String title, String subtitle, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? const Color(0xFF167D39) : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                    color: isCompleted ? Colors.black87 : Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: isCompleted ? Colors.black54 : Colors.grey.shade400, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = selectedFilter == 'All'
        ? orders
        : orders.where((o) => o['status'] == selectedFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'My Orders',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status filters
            Row(
              children: ['All', 'Processing', 'In Transit', 'Delivered'].map((f) {
                final isSelected = selectedFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: isSelected,
                    selectedColor: const Color(0xFFC8E6C9),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF167D39) : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => selectedFilter = f);
                    },
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            Column(
              children: filtered.map((o) {
                final color = o['statusColor'] as MaterialColor;
                final isDelivered = o['status'] == 'Delivered';

                return Card(
                  elevation: 0,
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Text(o['statusIcon']),
                                  const SizedBox(width: 6),
                                  Text(
                                    o['status'],
                                    style: TextStyle(
                                      color: color.shade800,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              o['date'],
                              style: const TextStyle(color: Colors.black45, fontSize: 12),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Text(o['cropIcon'], style: const TextStyle(fontSize: 32)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${o['crop']} • ${o['quantity']}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Buyer: ${o['buyer']} (${o['buyerLocation']})',
                                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              o['amount'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 19,
                                color: Color(0xFF167D39),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: isDelivered
                              ? OutlinedButton.icon(
                                  onPressed: () => _showTrackingModal(o),
                                  icon: const Icon(Icons.receipt_long, color: Color(0xFF167D39), size: 18),
                                  label: const Text('View Delivery Details', style: TextStyle(color: Color(0xFF167D39))),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFF167D39)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                )
                              : ElevatedButton.icon(
                                  onPressed: () => _showTrackingModal(o),
                                  icon: const Icon(Icons.local_shipping_outlined, size: 18),
                                  label: const Text('Track Order Live'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: color.shade700,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

