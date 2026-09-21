import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/crop.dart';
import '../services/crop_service.dart';

class AddCropScreen extends StatefulWidget {
  final String? initialCrop;

  const AddCropScreen({super.key, this.initialCrop});

  @override
  State<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();
  final locationController = TextEditingController();

  String selectedUnit = 'Kg';
  String quality = 'Good';
  String imagePath = '';
  DateTime selectedDate = DateTime.now();

  final ImagePicker picker = ImagePicker();

  // Known crops with reference market price ranges
  final Map<String, Map<String, dynamic>> cropDatabase = {
    'Tomato': {'icon': '🍅', 'min': 28.0, 'max': 35.0, 'avg': 32.0},
    'Onion': {'icon': '🧅', 'min': 30.0, 'max': 42.0, 'avg': 36.0},
    'Potato': {'icon': '🥔', 'min': 22.0, 'max': 28.0, 'avg': 25.0},
    'Paddy': {'icon': '🌾', 'min': 19.0, 'max': 24.0, 'avg': 22.0},
    'Chilli': {'icon': '🌶️', 'min': 45.0, 'max': 60.0, 'avg': 52.0},
    'Carrot': {'icon': '🥕', 'min': 35.0, 'max': 48.0, 'avg': 40.0},
  };

  final List<String> suggestions = [
    'Tomato',
    'Onion',
    'Potato',
    'Paddy',
    'Chilli',
    'Carrot',
  ];

  @override
  void initState() {
    super.initState();
    locationController.text = 'Panruti, Tamil Nadu';
    quantityController.text = '500';

    if (widget.initialCrop != null && widget.initialCrop!.isNotEmpty) {
      _selectCrop(widget.initialCrop!);
    } else {
      _selectCrop('Tomato');
    }
  }

  void _selectCrop(String cropName) {
    setState(() {
      nameController.text = cropName;
      final info = cropDatabase[cropName];
      if (info != null) {
        priceController.text = info['avg'].toStringAsFixed(0);
      }
    });
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final image = await picker.pickImage(source: source, imageQuality: 80);

      if (image != null) {
        setState(() {
          imagePath = image.path;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Image selection failed: $e')));
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_camera,
                  color: Color(0xFF167D39),
                ),
                title: const Text('Take Photo from Camera'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF167D39),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPreviewModal() {
    if (!_formKey.currentState!.validate()) return;

    final cropName = nameController.text.trim();
    final qty = double.tryParse(quantityController.text.trim()) ?? 0;
    final price = double.tryParse(priceController.text.trim()) ?? 0;
    final gross = qty * price;
    final icon = cropDatabase[cropName]?['icon'] ?? '🌱';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Listing Preview',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 40)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cropName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Quality: $quality • ${locationController.text}',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _previewRow(
                'Quantity',
                '${qty.toStringAsFixed(0)} $selectedUnit',
              ),
              _previewRow(
                'Asking Price',
                '₹${price.toStringAsFixed(0)} / $selectedUnit',
              ),
              _previewRow(
                'Est. Total Value',
                '₹${gross.toStringAsFixed(0)}',
                isBold: true,
              ),
              _previewRow(
                'Harvest Date',
                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    saveCrop();
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Confirm & Publish Crop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF167D39),
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
        );
      },
    );
  }

  Widget _previewRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isBold ? const Color(0xFF167D39) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> saveCrop() async {
    if (!_formKey.currentState!.validate()) return;

    final crop = Crop(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameController.text.trim(),
      quantity: double.parse(quantityController.text.trim()),
      unit: selectedUnit,
      expectedPrice: double.parse(priceController.text.trim()),
      harvestDate:
          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
      location: locationController.text.trim(),
      imagePath: imagePath,
    );

    await CropService.addCrop(crop);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF167D39),
        content: Text('Crop listed successfully in Marketplace! 🌾'),
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    priceController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentCrop = nameController.text.trim();
    final cropInfo = cropDatabase[currentCrop];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Add Your Crop',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─────────────────────────────
              // CROP SELECTION
              // ─────────────────────────────
              const Text(
                'What are you selling?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Search or type crop (e.g. Tomato)...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF167D39),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Enter crop name'
                    : null,
                onChanged: (val) {
                  setState(() {});
                },
              ),

              const SizedBox(height: 10),

              // Suggestions chips
              const Text(
                'Suggestions',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: suggestions.map((crop) {
                  final isSelected =
                      currentCrop.toLowerCase() == crop.toLowerCase();
                  final icon = cropDatabase[crop]?['icon'] ?? '🌱';
                  return ChoiceChip(
                    label: Text('$icon $crop'),
                    selected: isSelected,
                    selectedColor: const Color(0xFFC8E6C9),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? const Color(0xFF167D39)
                          : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) _selectCrop(crop);
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Auto-loaded estimated market price banner
              if (cropInfo != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFA5D6A7)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        cropInfo['icon'],
                        style: const TextStyle(fontSize: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$currentCrop selected ${cropInfo['icon']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Current estimated market price: ₹${cropInfo['min'].toStringAsFixed(0)} – ₹${cropInfo['max'].toStringAsFixed(0)} / Kg',
                              style: const TextStyle(
                                color: Color(0xFF167D39),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // ─────────────────────────────
              // QUANTITY & UNIT
              // ─────────────────────────────
              const Text(
                'How much do you have?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '500',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      validator: (val) {
                        final n = double.tryParse(val ?? '');
                        if (n == null || n <= 0) return 'Enter quantity';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedUnit,
                          items: const [
                            DropdownMenuItem(value: 'Kg', child: Text('Kg')),
                            DropdownMenuItem(
                              value: 'Quintal',
                              child: Text('Quintal'),
                            ),
                            DropdownMenuItem(value: 'Ton', child: Text('Ton')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => selectedUnit = val);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Quick quantity increment buttons
              Row(
                children: [
                  _quickQtyButton('+100'),
                  const SizedBox(width: 8),
                  _quickQtyButton('+500'),
                  const SizedBox(width: 8),
                  _quickQtyButton('+1000'),
                ],
              ),

              const SizedBox(height: 20),

              // ─────────────────────────────
              // LOCATION
              // ─────────────────────────────
              const Text(
                'Where is the crop?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: 'Farm location (e.g. Panruti)',
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        locationController.text = 'Panruti, Cuddalore Dist';
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Location updated to Panruti 📍'),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.my_location,
                      size: 16,
                      color: Color(0xFF167D39),
                    ),
                    label: const Text(
                      'Use my location',
                      style: TextStyle(color: Color(0xFF167D39), fontSize: 12),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Enter location' : null,
              ),

              const SizedBox(height: 20),

              // ─────────────────────────────
              // EXPECTED PRICE
              // ─────────────────────────────
              const Text(
                'Your expected price',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  suffixText: '/ $selectedUnit',
                  hintText: '32',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                validator: (val) {
                  final n = double.tryParse(val ?? '');
                  if (n == null || n <= 0) return 'Enter price';
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ─────────────────────────────
              // QUALITY
              // ─────────────────────────────
              const Text(
                'Crop quality',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Row(
                children: ['Premium', 'Good', 'Average'].map((q) {
                  final isSelected = quality == q;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(q),
                      selected: isSelected,
                      selectedColor: const Color(0xFFC8E6C9),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? const Color(0xFF167D39)
                            : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => quality = q);
                      },
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // ─────────────────────────────
              // PHOTOS
              // ─────────────────────────────
              const Text(
                'Upload crop photos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _showImagePickerModal,
                    icon: const Icon(
                      Icons.add_a_photo,
                      color: Color(0xFF167D39),
                    ),
                    label: const Text(
                      'Add Photos',
                      style: TextStyle(color: Color(0xFF167D39)),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      side: const BorderSide(color: Color(0xFF167D39)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (imagePath.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(imagePath),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 30),

              // ─────────────────────────────
              // BUTTONS
              // ─────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showPreviewModal,
                      icon: const Icon(
                        Icons.visibility_outlined,
                        color: Color(0xFF167D39),
                      ),
                      label: const Text(
                        'Preview Listing',
                        style: TextStyle(color: Color(0xFF167D39)),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF167D39)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: saveCrop,
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text(
                        'Publish Crop',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF167D39),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickQtyButton(String text) {
    return ActionChip(
      label: Text(text, style: const TextStyle(fontSize: 12)),
      backgroundColor: Colors.white,
      onPressed: () {
        final current = double.tryParse(quantityController.text) ?? 0;
        final add = double.parse(text.replaceAll('+', ''));
        setState(() {
          quantityController.text = (current + add).toStringAsFixed(0);
        });
      },
    );
  }
}
