class CropQuality {
  final String cropName;
  final String grade;
  final int score;
  final int confidence;
  final List<String> detectedIssues;
  final String recommendation;
  final String explanation;

  CropQuality({
    required this.cropName,
    required this.grade,
    required this.score,
    required this.confidence,
    required this.detectedIssues,
    required this.recommendation,
    required this.explanation,
  });
}
