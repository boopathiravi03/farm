import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/crop_quality.dart';
import '../services/crop_quality_service.dart';

class CropQualityScreen extends StatefulWidget {
  const CropQualityScreen({super.key});

  @override
  State<CropQualityScreen> createState() => _CropQualityScreenState();
}

class _CropQualityScreenState extends State<CropQualityScreen> {
  final ImagePicker _picker = ImagePicker();

  File? selectedImage;

  String selectedCrop = 'Tomato';

  bool isAnalyzing = false;

  CropQuality? result;

  final List<String> crops = ['Tomato', 'Onion', 'Potato', 'Brinjal'];

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (image == null) return;

      setState(() {
        selectedImage = File(image.path);
        result = null;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to select image: $e')));
    }
  }

  Future<void> analyzeQuality() async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a crop image first')),
      );

      return;
    }

    setState(() {
      isAnalyzing = true;
      result = null;
    });

    final analysis = await CropQualityService.analyzeCrop(
      cropName: selectedCrop,
      imagePath: selectedImage!.path,
    );

    if (!mounted) return;

    setState(() {
      result = analysis;
      isAnalyzing = false;
    });
  }

  Color gradeColor(String grade) {
    switch (grade) {
      case 'A':
        return Colors.green;

      case 'B':
        return Colors.orange;

      case 'C':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Crop Quality'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 20),

              _buildCropSelector(),

              const SizedBox(height: 20),

              _buildImageSection(),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: isAnalyzing ? null : analyzeQuality,
                  icon: isAnalyzing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                    isAnalyzing ? 'Analysing Crop...' : 'Analyse Crop Quality',
                  ),
                ),
              ),

              if (isAnalyzing) ...[
                const SizedBox(height: 20),
                _buildAnalysisProgress(),
              ],

              if (result != null) ...[
                const SizedBox(height: 24),
                _buildResultCard(result!),
                const SizedBox(height: 16),
                _buildIssuesCard(result!),
                const SizedBox(height: 16),
                _buildRecommendationCard(result!),
                const SizedBox(height: 16),
                _buildDisclaimer(),
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
          colors: [Colors.green.shade700, Colors.green.shade400],
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.camera_enhance, color: Colors.white, size: 38),
          SizedBox(height: 12),
          Text(
            'Check Your Crop Quality',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Upload a crop image and get an AI-assisted quality assessment.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCropSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Crop',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        DropdownButtonFormField<String>(
          initialValue: selectedCrop,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.agriculture),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          items: crops.map((crop) {
            return DropdownMenuItem(value: crop, child: Text(crop));
          }).toList(),
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              selectedCrop = value;
              result = null;
            });
          },
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: selectedImage == null
          ? _buildImagePlaceholder()
          : ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(
                selectedImage!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_outlined, size: 65, color: Colors.grey.shade500),

        const SizedBox(height: 12),

        Text(
          'Add Crop Image',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Use camera or gallery',
          style: TextStyle(color: Colors.grey.shade600),
        ),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                pickImage(ImageSource.camera);
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Camera'),
            ),

            const SizedBox(width: 12),

            OutlinedButton.icon(
              onPressed: () {
                pickImage(ImageSource.gallery);
              },
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalysisProgress() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Text(
            'AI is analysing the crop...',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          LinearProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildResultCard(CropQuality quality) {
    final color = gradeColor(quality.grade);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Quality Assessment',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: Container(
                  height: 105,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        quality.grade,
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const Text('GRADE'),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Container(
                  height: 105,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${quality.score}',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('SCORE / 100'),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified, size: 20, color: Colors.green),
              const SizedBox(width: 6),
              Text(
                'AI Confidence: ${quality.confidence}%',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Text(
            quality.explanation,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildIssuesCard(CropQuality quality) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.search),
              SizedBox(width: 8),
              Text(
                'Detected Observations',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ...quality.detectedIssues.map((issue) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, size: 19, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(child: Text(issue)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(CropQuality quality) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Selling Recommendation',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            quality.recommendation,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade800),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Prototype vision analysis. The final SIH version will connect this screen to a trained crop-quality computer vision model through the FastAPI backend.',
              style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
            ),
          ),
        ],
      ),
    );
  }
}
