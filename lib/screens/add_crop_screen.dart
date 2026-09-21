import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/crop.dart';
import '../services/crop_service.dart';

class AddCropScreen extends StatefulWidget {
  const AddCropScreen({super.key});

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
  DateTime? selectedDate;
  String imagePath = '';

  final ImagePicker picker = ImagePicker();

  Future<void> pickImage() async {
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        imagePath = image.path;
      });
    }
  }

  Future<void> selectDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> saveCrop() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select harvest date')),
      );
      return;
    }

    final crop = Crop(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameController.text.trim(),
      quantity: double.parse(quantityController.text),
      unit: selectedUnit,
      expectedPrice: double.parse(priceController.text),
      harvestDate:
          '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
      location: locationController.text.trim(),
      imagePath: imagePath,
    );

    await CropService.addCrop(crop);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Crop listed successfully 🌾')),
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

  InputDecoration fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Crop')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // IMAGE
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: imagePath.isEmpty
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 50,
                            color: Colors.green,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Upload Crop Image',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.file(File(imagePath), fit: BoxFit.cover),
                      ),
              ),
            ),

            const SizedBox(height: 22),

            // CROP NAME
            TextFormField(
              controller: nameController,
              decoration: fieldDecoration('Crop Name', Icons.eco),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter crop name';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // QUANTITY
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: fieldDecoration('Quantity', Icons.scale),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter quantity';
                      }

                      if (double.tryParse(value) == null) {
                        return 'Enter valid number';
                      }

                      return null;
                    },
                  ),
                ),

                const SizedBox(width: 12),

                SizedBox(
                  width: 100,
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedUnit,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Kg', child: Text('Kg')),
                      DropdownMenuItem(
                        value: 'Quintal',
                        child: Text('Quintal'),
                      ),
                      DropdownMenuItem(value: 'Ton', child: Text('Ton')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedUnit = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // EXPECTED PRICE
            TextFormField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: fieldDecoration(
                'Expected Price (₹)',
                Icons.currency_rupee,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter expected price';
                }

                if (double.tryParse(value) == null) {
                  return 'Enter valid price';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // HARVEST DATE
            InkWell(
              onTap: selectDate,
              child: InputDecorator(
                decoration: fieldDecoration(
                  'Harvest Date',
                  Icons.calendar_month,
                ),
                child: Text(
                  selectedDate == null
                      ? 'Select harvest date'
                      : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                ),
              ),
            ),

            const SizedBox(height: 16),

            // LOCATION
            TextFormField(
              controller: locationController,
              decoration: fieldDecoration('Farm Location', Icons.location_on),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter farm location';
                }
                return null;
              },
            ),

            const SizedBox(height: 28),

            // SAVE
            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                onPressed: saveCrop,
                icon: const Icon(Icons.check),
                label: const Text(
                  'List Crop',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
