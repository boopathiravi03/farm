import 'package:flutter/material.dart';

class BuyerMatchingScreen extends StatefulWidget {
  const BuyerMatchingScreen({super.key});

  @override
  State<BuyerMatchingScreen> createState() => _BuyerMatchingScreenState();
}

class _BuyerMatchingScreenState extends State<BuyerMatchingScreen> {
  String selectedCrop = 'Tomato';
  final quantityController = TextEditingController(text: '500');
  final priceController = TextEditingController(text: '30');

  String selectedDistance = '10 km';
  bool typeTraders = true;
  bool typeShops = true;
  bool typeRestaurants = false;
  bool typeWholesalers = false;

  bool searched = true;
  bool isSearching = false;

  final List<Map<String, String>> crops = [
    {'name': 'Tomato', 'icon': '🍅'},
    {'name': 'Onion', 'icon': '🧅'},
    {'name': 'Potato', 'icon': '🥔'},
    {'name': 'Chilli', 'icon': '🌶️'},
    {'name': 'Paddy', 'icon': '🌾'},
  ];

  final List<String> distances = ['5 km', '10 km', '25 km', '50 km'];

  // Buyer database
  final List<Map<String, dynamic>> allBuyers = [
    {
      'name': 'Panruti Fresh Mart',
      'type': 'Shops',
      'distance': 2.5,
      'crop': 'Tomato',
      'needs': 250,
      'offer': 33.0,
      'payment': 'Instant UPI / Cash',
      'rating': 4.9,
      'verified': true,
    },
    {
      'name': 'Arun Traders',
      'type': 'Traders',
      'distance': 4.2,
      'crop': 'Tomato',
      'needs': 400,
      'offer': 32.0,
      'payment': 'Bank Transfer (Same Day)',
      'rating': 4.8,
      'verified': true,
    },
    {
      'name': 'Kumar Agro Foods',
      'type': 'Traders',
      'distance': 7.8,
      'crop': 'Tomato',
      'needs': 700,
      'offer': 31.0,
      'payment': 'Instant UPI',
      'rating': 4.7,
      'verified': true,
    },
    {
      'name': 'Cuddalore Wholesale Hub',
      'type': 'Wholesalers',
      'distance': 9.2,
      'crop': 'Tomato',
      'needs': 1200,
      'offer': 30.0,
      'payment': 'Direct Bank Deposit',
      'rating': 4.6,
      'verified': true,
    },
    {
      'name': 'Annapoorna Veg Chain',
      'type': 'Restaurants',
      'distance': 4.8,
      'crop': 'Tomato',
      'needs': 300,
      'offer': 34.0,
      'payment': 'Instant UPI',
      'rating': 4.9,
      'verified': true,
    },
  ];

  void _search() async {
    setState(() => isSearching = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      isSearching = false;
      searched = true;
    });
  }

  void _showBuyerDetails(Map<String, dynamic> b) {
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
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFFFFF3E0),
                        child: const Icon(
                          Icons.store,
                          color: Color(0xFFE65100),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                b['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (b['verified'])
                                const Icon(
                                  Icons.verified,
                                  size: 16,
                                  color: Color(0xFF167D39),
                                ),
                            ],
                          ),
                          Text(
                            '${b['type']} • 📍 ${b['distance']} km away',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                        ],
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
              _detailItem(
                Icons.eco,
                'Crop Requirement',
                '${b['crop']} (${b['needs']} Kg)',
              ),
              _detailItem(
                Icons.currency_rupee,
                'Current Offer',
                '₹${b['offer']} / Kg',
              ),
              _detailItem(
                Icons.payments_outlined,
                'Payment Terms',
                b['payment'],
              ),
              _detailItem(
                Icons.star,
                'Buyer Rating',
                '${b['rating']} ★ (140+ trades completed)',
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/negotiation');
                      },
                      icon: const Icon(Icons.handshake),
                      label: const Text('Negotiate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE65100),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFE65100)),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    quantityController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxDist = double.parse(selectedDistance.replaceAll(' km', ''));
    final filtered = allBuyers.where((b) {
      if (b['distance'] > maxDist) return false;
      if (b['type'] == 'Traders' && !typeTraders) return false;
      if (b['type'] == 'Shops' && !typeShops) return false;
      if (b['type'] == 'Restaurants' && !typeRestaurants) return false;
      if (b['type'] == 'Wholesalers' && !typeWholesalers) return false;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Find Buyers',
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
            // FILTER / SEARCH FORM
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
                    'What are you selling?',
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
                        selectedColor: const Color(0xFFFFE0B2),
                        backgroundColor: const Color(0xFFF5F5F5),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? const Color(0xFFE65100)
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
                      // Available Quantity
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Available quantity?',
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

                      // Minimum Price
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Minimum price?',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                prefixText: '₹ ',
                                suffixText: '/Kg',
                                hintText: '30',
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
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Distance Filter Chips
                  const Text(
                    'How far can you deliver?',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: distances.map((d) {
                      final isSelected = selectedDistance == d;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(d),
                          selected: isSelected,
                          selectedColor: const Color(0xFFFFE0B2),
                          backgroundColor: const Color(0xFFF5F5F5),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? const Color(0xFFE65100)
                                : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => selectedDistance = d);
                          },
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 18),

                  // Buyer Type Checkboxes
                  const Text(
                    'Buyer type',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: -8,
                    children: [
                      _buyerTypeCheckbox(
                        'Traders',
                        typeTraders,
                        (v) => setState(() => typeTraders = v!),
                      ),
                      _buyerTypeCheckbox(
                        'Shops',
                        typeShops,
                        (v) => setState(() => typeShops = v!),
                      ),
                      _buyerTypeCheckbox(
                        'Restaurants',
                        typeRestaurants,
                        (v) => setState(() => typeRestaurants = v!),
                      ),
                      _buyerTypeCheckbox(
                        'Wholesalers',
                        typeWholesalers,
                        (v) => setState(() => typeWholesalers = v!),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isSearching ? null : _search,
                      icon: isSearching
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.search),
                      label: const Text(
                        '🔎 Find Matching Buyers',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE65100),
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
            // RESULT BUYERS LIST
            // ─────────────────────────────
            if (searched) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filtered.length} Buyers Found',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'within $selectedDistance',
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (filtered.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Text(
                      'No buyers found with current filters.\nTry increasing delivery distance.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                )
              else
                Column(
                  children: filtered.map((b) {
                    final cropIcon = crops.firstWhere(
                      (c) => c['name'] == b['crop'],
                      orElse: () => {'icon': '🌱'},
                    )['icon']!;

                    return Card(
                      elevation: 0,
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          b['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        if (b['verified']) ...[
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.verified,
                                            size: 16,
                                            color: Color(0xFF167D39),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      '📍 ${b['distance']} km away • ${b['type']}',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '₹${b['offer']}/Kg',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF167D39),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  '$cropIcon ${b['crop']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Text(
                                  'Needs: ${b['needs']} Kg',
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _showBuyerDetails(b),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color(0xFFE65100),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                    ),
                                    child: const Text(
                                      'View',
                                      style: TextStyle(
                                        color: Color(0xFFE65100),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/negotiation',
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE65100),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                    ),
                                    child: const Text('Negotiate'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buyerTypeCheckbox(
    String title,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return SizedBox(
      width: 150,
      child: CheckboxListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(title, style: const TextStyle(fontSize: 13)),
        value: value,
        activeColor: const Color(0xFFE65100),
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: onChanged,
      ),
    );
  }
}
