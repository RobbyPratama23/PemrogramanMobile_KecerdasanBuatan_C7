import 'package:flutter/material.dart';
import '../models/detection_history.dart';
import 'dart:io';
import 'dart:convert';
// HAPUS import ini: import 'package:flutter/foundation.dart' show kIsWeb;

class HistoryScreen extends StatelessWidget {
  final List<DetectionHistory> detectionHistory;

  const HistoryScreen({super.key, required this.detectionHistory});

  @override
  Widget build(BuildContext context) {
    return detectionHistory.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_rounded, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Belum ada riwayat scan',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Lakukan scan pertama Anda di tab Scan',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: detectionHistory.length,
            itemBuilder: (context, index) {
              final history = detectionHistory[index];
              return _buildHistoryCard(history, context);
            },
          );
  }

  Widget _buildImageWidget(DetectionHistory history) {
    try {
      if (history.imageType == 'base64') {
        // Untuk Web: decode base64
        return Image.memory(
          base64Decode(history.imagePath),
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImagePlaceholder();
          },
        );
      } else {
        // Untuk Android: gunakan Image.file
        return Image.file(
          File(history.imagePath),
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImagePlaceholder();
          },
        );
      }
    } catch (e) {
      return _buildImagePlaceholder();
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 180,
      color: Colors.grey[200],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_rounded, size: 50, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            'Gambar tidak tersedia',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(DetectionHistory history, BuildContext context) {
    final color = history.status == 'Sehat'
        ? const Color(0xFF4CAF50)
        : const Color(0xFFFF9800);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // Gambar Header - Compatible Android & Web
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: _buildImageWidget(history),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    history.status == 'Sehat'
                        ? Icons.check_circle
                        : Icons.warning_amber,
                    size: 24,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Bibit ${history.status}',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Date & Confidence
                      Text(
                        _formatDate(history.detectionDate),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Keyakinan: ${(history.confidence * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Treatment Advice
                      if (history.treatmentAdvice != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            history.treatmentAdvice!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}