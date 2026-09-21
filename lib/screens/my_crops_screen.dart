import 'dart:io';

import 'package:flutter/material.dart';

import '../models/crop.dart';
import '../services/crop_service.dart';

class MyCropsScreen extends StatefulWidget {
  const MyCropsScreen({super.key});

  @override
  State<MyCropsScreen> createState() => _MyCropsScreenState();
}

class _MyCropsScreenState extends State<MyCropsScreen> {
  List<Crop> crops = [];

  @override
  void initState() {
    super.initState();
    loadCrops();
  }

  Future<void> loadCrops() async {
    final data = await CropService.getCrops();

    if (!mounted) return;

    setState(() {
      crops = data;
    });
  }

  Future<void> deleteCrop(String id) async {
    await CropService.deleteCrop(id);
    await loadCrops();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Crops')),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add-crop');

          if (result == true) {
            loadCrops();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Crop'),
      ),

      body: crops.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.agriculture,
                    size: 80,
                    color: Colors.green.shade300,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'No crops listed yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Add your first crop to start trading'),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: loadCrops,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: crops.length,
                itemBuilder: (context, index) {
                  final crop = crops[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // IMAGE
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child:
                                crop.imagePath.isNotEmpty &&
                                    File(crop.imagePath).existsSync()
                                ? Image.file(
                                    File(crop.imagePath),
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 90,
                                    height: 90,
                                    color: Colors.green.shade50,
                                    child: const Icon(
                                      Icons.eco,
                                      size: 40,
                                      color: Colors.green,
                                    ),
                                  ),
                          ),

                          const SizedBox(width: 14),

                          // DETAILS
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  crop.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  '${crop.quantity} ${crop.unit}',
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  '₹${crop.expectedPrice.toStringAsFixed(0)} / ${crop.unit}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  'Harvest: ${crop.harvestDate}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),

                                Text(
                                  crop.location,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // DELETE
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Delete Crop?'),
                                    content: const Text(
                                      'This crop listing will be removed.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          deleteCrop(crop.id);
                                        },
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
