import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/crop_passport.dart';
import '../services/crop_passport_service.dart';

class CropPassportScreen extends StatefulWidget {
  const CropPassportScreen({super.key});

  @override
  State<CropPassportScreen> createState() => _CropPassportScreenState();
}

class _CropPassportScreenState extends State<CropPassportScreen> {
  final cropController = TextEditingController();

  final farmerController = TextEditingController(text: 'Farm Trading Farmer');

  final quantityController = TextEditingController();

  final locationController = TextEditingController(text: 'Panruti, Tamil Nadu');

  final harvestController = TextEditingController();

  final priceController = TextEditingController();

  String selectedGrade = 'A';

  int qualityScore = 88;

  int qualityConfidence = 91;

  CropPassport? passport;

  bool isCreating = false;

  @override
  void dispose() {
    cropController.dispose();
    farmerController.dispose();
    quantityController.dispose();
    locationController.dispose();
    harvestController.dispose();
    priceController.dispose();

    super.dispose();
  }

  Future<void> createPassport() async {
    if (cropController.text.trim().isEmpty ||
        quantityController.text.trim().isEmpty ||
        harvestController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );

      return;
    }

    setState(() {
      isCreating = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final newPassport = CropPassport(
      passportId: 'FT-$timestamp',
      cropName: cropController.text.trim(),
      farmerName: farmerController.text.trim(),
      quantity: quantityController.text.trim(),
      location: locationController.text.trim(),
      harvestDate: harvestController.text.trim(),
      expectedPrice: double.tryParse(priceController.text.trim()) ?? 0,
      qualityGrade: selectedGrade,
      qualityScore: qualityScore,
      qualityConfidence: qualityConfidence,
      status: 'Active',
    );

    await CropPassportService.savePassport(newPassport);

    if (!mounted) return;

    setState(() {
      passport = newPassport;
      isCreating = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Digital Crop Passport created!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Crop Passport'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 20),

              _buildInputSection(),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: isCreating ? null : createPassport,
                  icon: isCreating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.qr_code_2),
                  label: Text(
                    isCreating
                        ? 'Creating Passport...'
                        : 'Create Crop Passport',
                  ),
                ),
              ),

              if (passport != null) ...[
                const SizedBox(height: 25),
                _buildPassport(passport!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.green.shade800, Colors.green.shade500],
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified, color: Colors.white, size: 40),
          SizedBox(height: 12),
          Text(
            'Create Digital Crop Identity',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Give your crop a unique digital identity that buyers can verify.',
            style: TextStyle(color: Colors.white70, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Crop Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 14),

        _field(
          controller: cropController,
          label: 'Crop Name *',
          icon: Icons.agriculture,
          hint: 'Example: Tomato',
        ),

        _field(
          controller: quantityController,
          label: 'Quantity *',
          icon: Icons.scale,
          hint: 'Example: 500 Kg',
        ),

        _field(
          controller: locationController,
          label: 'Farm Location',
          icon: Icons.location_on,
          hint: 'Example: Panruti',
        ),

        _field(
          controller: harvestController,
          label: 'Harvest Date *',
          icon: Icons.calendar_month,
          hint: 'Example: 20-09-2026',
        ),

        _field(
          controller: priceController,
          label: 'Expected Price / Kg *',
          icon: Icons.currency_rupee,
          hint: 'Example: 28',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),

        const SizedBox(height: 8),

        const Text(
          'Quality Grade',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        DropdownButtonFormField<String>(
          initialValue: selectedGrade,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.grade),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          items: ['A', 'B', 'C']
              .map(
                (grade) =>
                    DropdownMenuItem(value: grade, child: Text('Grade $grade')),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              selectedGrade = value;

              if (value == 'A') {
                qualityScore = 88;
                qualityConfidence = 91;
              } else if (value == 'B') {
                qualityScore = 75;
                qualityConfidence = 85;
              } else {
                qualityScore = 58;
                qualityConfidence = 79;
              }
            });
          },
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _buildPassport(CropPassport passport) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.green.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'VERIFIED CROP PASSPORT',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),

            const SizedBox(height: 18),

            QrImageView(
              data: passport.passportId,
              size: 190,
              backgroundColor: Colors.white,
            ),

            const SizedBox(height: 10),

            Text(
              passport.passportId,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 22),

            _infoRow(Icons.agriculture, 'Crop', passport.cropName),

            _infoRow(Icons.person, 'Farmer', passport.farmerName),

            _infoRow(Icons.scale, 'Quantity', passport.quantity),

            _infoRow(Icons.location_on, 'Location', passport.location),

            _infoRow(Icons.calendar_month, 'Harvest', passport.harvestDate),

            _infoRow(
              Icons.currency_rupee,
              'Expected Price',
              '₹${passport.expectedPrice.toStringAsFixed(2)}/Kg',
            ),

            const Divider(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _qualityBox('Grade', passport.qualityGrade),
                _qualityBox('Score', '${passport.qualityScore}/100'),
                _qualityBox('Confidence', '${passport.qualityConfidence}%'),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Passport Status: Active',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Icon(icon, size: 21, color: Colors.green),
          const SizedBox(width: 10),
          SizedBox(
            width: 105,
            child: Text(title, style: TextStyle(color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qualityBox(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
