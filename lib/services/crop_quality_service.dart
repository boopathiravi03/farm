import '../models/crop_quality.dart';

class CropQualityService {
  static Future<CropQuality> analyzeCrop({
    required String cropName,
    required String imagePath,
  }) async {
    // Prototype AI processing delay.
    await Future.delayed(const Duration(seconds: 2));

    /*
      Prototype result.

      IMPORTANT:
      This is not a trained computer-vision model yet.
      The service is designed so that a real FastAPI +
      PyTorch/Hugging Face model can replace this logic later.
    */

    switch (cropName.toLowerCase()) {
      case 'tomato':
        return CropQuality(
          cropName: 'Tomato',
          grade: 'A',
          score: 88,
          confidence: 91,
          detectedIssues: ['Minor surface marks', 'Good colour consistency'],
          recommendation: 'Suitable for direct premium buyers.',
          explanation:
              'The prototype assessment indicates good visual quality with minor surface-level imperfections.',
        );

      case 'onion':
        return CropQuality(
          cropName: 'Onion',
          grade: 'A',
          score: 90,
          confidence: 93,
          detectedIssues: ['Good skin condition', 'Uniform appearance'],
          recommendation: 'Suitable for wholesale and premium buyers.',
          explanation:
              'The prototype assessment indicates healthy visual appearance and good market quality.',
        );

      case 'potato':
        return CropQuality(
          cropName: 'Potato',
          grade: 'B',
          score: 76,
          confidence: 86,
          detectedIssues: ['Minor surface marks', 'Slight size variation'],
          recommendation: 'Suitable for regular market buyers.',
          explanation:
              'The prototype assessment indicates acceptable quality with some visible imperfections.',
        );

      case 'brinjal':
        return CropQuality(
          cropName: 'Brinjal',
          grade: 'B',
          score: 74,
          confidence: 84,
          detectedIssues: ['Uneven colour', 'Minor surface marks'],
          recommendation: 'Suitable for regular buyers after quality sorting.',
          explanation:
              'The prototype assessment indicates moderate visual quality and recommends basic sorting.',
        );

      default:
        return CropQuality(
          cropName: cropName,
          grade: 'B',
          score: 75,
          confidence: 80,
          detectedIssues: ['Quality assessment requires trained model'],
          recommendation: 'Perform manual quality inspection before selling.',
          explanation:
              'The current prototype provides a demonstration result. A trained vision model will provide the final assessment.',
        );
    }
  }
}
