import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/detection_history.dart';

class HomeScreen extends StatelessWidget {
  final User user;
  final List<DetectionHistory> detectionHistory;

  const HomeScreen({
    super.key,
    required this.user,
    required this.detectionHistory,
  });

  @override
  Widget build(BuildContext context) {
    final recentDetections = detectionHistory.take(3).toList();
    final healthyCount =
        detectionHistory.where((history) => history.status == 'normal').length;
    final stressCount =
        detectionHistory.where((history) => history.status == 'stres').length;

    // Calculate progress for the bar
    final totalScans = detectionHistory.length;
    final healthyProgress = totalScans > 0 ? healthyCount / totalScans : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card with Animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.eco, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, ${user.username}! 🌱',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Monitor kesehatan bibit lettuce Anda',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Scan',
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            '${user.totalScans}', // Gunakan user.totalScans, bukan detectionHistory.length
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: totalScans > 0 ? healthyProgress : 0,
                          minHeight: 8,
                          backgroundColor: Colors.white24,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$healthyCount normal',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '$stressCount stres',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stats Cards with Animation - 3 CARDS
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  user.totalScans.toString(), // TOTAL SCAN dari user model
                  'Total Scan',
                  Icons.camera_alt_rounded,
                  const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  healthyCount.toString(),
                  'Bibit Sehat',
                  Icons.health_and_safety,
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  stressCount.toString(),
                  'Bibit Stress',
                  Icons.warning_amber_rounded,
                  const Color(0xFFFF9800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Quick Actions
          const Text(
            'Aksi Cepat',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            children: [
              _buildQuickAction(
                'Scan Bibit',
                Icons.camera_alt_rounded,
                const Color(0xFF4CAF50),
                () {
                  // Navigate to upload screen
                  DefaultTabController.of(context).animateTo(1);
                },
              ),
              _buildQuickAction(
                'Riwayat',
                Icons.history_rounded,
                const Color(0xFF2196F3),
                () {
                  // Navigate to history screen
                  DefaultTabController.of(context).animateTo(2);
                },
              ),
              _buildQuickAction(
                'Panduan',
                Icons.book_rounded,
                const Color(0xFF9C27B0),
                () {
                  // Navigate to guide screen
                  DefaultTabController.of(context).animateTo(3);
                },
              ),
              _buildQuickAction(
                'Statistik',
                Icons.bar_chart_rounded,
                const Color(0xFFFF9800),
                () {
                  // Show statistics
                  _showStatistics(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Recent Activity
          const Text(
            'Aktivitas Terakhir',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (recentDetections.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.history_rounded, size: 50, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Belum ada aktivitas scan',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            ...recentDetections.map((history) => _buildActivityItem(
                  history.status,
                  _formatTimeAgo(history.detectionDate),
                  history.status == 'Sehat'
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFF9800),
                  '${(history.confidence * 100).toStringAsFixed(0)}%',
                )),
        ],
      ),
    );
  }

  void _showStatistics(BuildContext context) {
    final healthyCount =
        detectionHistory.where((h) => h.status == 'normal').length;
    final stressCount =
        detectionHistory.where((h) => h.status == 'stres').length;
    final total = detectionHistory.length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Statistik Scan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatItem(
                'Total Scan', user.totalScans.toString(), Icons.camera_alt),
            _buildStatItem('Bibit Sehat', healthyCount.toString(),
                Icons.health_and_safety),
            _buildStatItem(
                'Bibit Stress', stressCount.toString(), Icons.warning),
            if (total > 0)
              _buildStatItem(
                  'Success Rate',
                  '${((healthyCount / total) * 100).toStringAsFixed(1)}%',
                  Icons.analytics),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing:
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  // ... (method _buildStatCard, _buildQuickAction, _buildActivityItem, _formatTimeAgo tetap sama)
  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String time,
    Color color,
    String confidence,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              title == 'Sehat' ? Icons.check_circle : Icons.warning_amber,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bibit $title',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              confidence,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Baru saja';
    if (difference.inMinutes < 60) return '${difference.inMinutes} menit lalu';
    if (difference.inHours < 24) return '${difference.inHours} jam lalu';
    if (difference.inDays < 7) return '${difference.inDays} hari lalu';
    return '${date.day}/${date.month}/${date.year}';
  }
}
