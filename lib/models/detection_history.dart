// models/detection_history.dart
class DetectionHistory {
  final String id;
  final String imagePath; // Untuk mobile: file path, untuk web: base64
  final String imageType; // 'file' atau 'base64'
  final String status;
  final double confidence;
  final DateTime detectionDate;
  final String? treatmentAdvice;

  DetectionHistory({
    required this.id,
    required this.imagePath,
    required this.imageType,
    required this.status,
    required this.confidence,
    required this.detectionDate,
    this.treatmentAdvice,
  });
}
