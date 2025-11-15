import 'package:flutter/material.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  final List<GuideItem> _guideItems = [
    GuideItem(
      title: 'Bibit Sehat 🌱',
      description: 'Ciri-ciri bibit lettuce yang sehat dan optimal',
      icon: Icons.health_and_safety,
      color: const Color(0xFF4CAF50),
      gradient:
          const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF81C784)]),
      isExpanded: false,
      details: '''
• Daun berwarna hijau cerah dan segar
• Pertumbuhan merata dan simetris
• Batang kuat dan tegak
• Tidak ada bercak atau perubahan warna abnormal
• Akar putih dan berkembang baik
• Tinggi bibit sesuai usia (5-7 cm untuk 2 minggu)
• Daun tidak layu atau menguning
''',
    ),
    GuideItem(
      title: 'Bibit Stress ⚠️',
      description: 'Tanda-tanda bibit lettuce mengalami masalah',
      icon: Icons.warning_amber_rounded,
      color: const Color(0xFFFF9800),
      gradient: null,
      isExpanded: false,
      details: '''
• DAUN MENGUNING: Kurang nitrogen, overwatering, atau pH tanah tidak optimal
• PERTUMBUHAN LAMBAT: Kekurangan cahaya, suhu terlalu dingin, atau nutrisi kurang
• BATANG LEMAH: Cahaya tidak cukup (etiolasi) atau kepadatan tanam berlebihan
• BERCAK COKLAT: Penyakit jamur, bakteri, atau sunburn
• DAUN LAYU: Kekurangan air atau akar rusak
• WARNA PUCAT: Kekurangan magnesium atau cahaya berlebihan
''',
    ),
    GuideItem(
      title: 'Perawatan Optimal 💧',
      description: 'Panduan perawatan harian bibit lettuce',
      icon: Icons.water_drop_rounded,
      color: const Color(0xFF2196F3),
      gradient: null,
      isExpanded: false,
      details: '''
PENYIRAMAN:
• Siram pagi hari antara jam 6-9 pagi
• Gunakan sprayer untuk menghindari kerusakan bibit
• Jaga kelembaban tanah tapi tidak becek
• Hindari penyiraman di siang hari terik

PENCahAYAAN:
• 6-8 jam cahaya matahari langsung/hari
• atau 12-14 jam lampu grow light
• Jarak lampu 15-20 cm dari bibit
• Rotasi pot setiap 2 hari untuk pertumbuhan merata

SUHU & KELEMBABAN:
• Suhu ideal: 18-24°C
• Kelembaban: 60-70%
• Hindari suhu di bawah 10°C atau di atas 30°C
''',
    ),
    GuideItem(
      title: 'Nutrisi & Pemupukan 🌿',
      description: 'Kebutuhan nutrisi untuk bibit lettuce',
      icon: Icons.eco_rounded,
      color: const Color(0xFF9C27B0),
      gradient: null,
      isExpanded: false,
      details: '''
NUTRISI ESENSIAL:
• Nitrogen (N): Untuk pertumbuhan daun hijau
• Fosfor (P): Untuk perkembangan akar
• Kalium (K): Untuk ketahanan penyakit

JADWAL PEMUPUKAN:
• Minggu 1-2: Tidak perlu pupuk (gunakan media tanam berkualitas)
• Minggu 3-4: Pupuk cair NPK 10-10-10 dengan dosis 1/4
• Minggu 5-6: Pupuk cair NPK 20-20-20 dengan dosis 1/2

TIPS:
• Gunakan pupuk organik seperti kompos cair
• Hindari pemupukan berlebihan
• Siram tanah sebelum pemupukan
''',
    ),
    GuideItem(
      title: 'Hama & Penyakit 🐛',
      description: 'Identifikasi dan penanganan masalah umum',
      icon: Icons.bug_report_rounded,
      color: const Color(0xFFF44336),
      gradient: null,
      isExpanded: false,
      details: '''
HAMAA UMUM:
• KUTU DAUN: Daun keriting dan pertumbuhan terhambat
• ULAT: Daun berlubang dan terdapat kotoran hijau
• TUNGAU: Bercak kuning dan jaring halus di daun

PENYAKIT:
• DAMPING OFF: Batang lemah dan rebah
• JAMUR: Bercak putih atau abu-abu pada daun
• BAKTERI: Daun berlendir dan berbau

PENCEGAHAN:
• Jaga kebersihan area tanam
• Beri sirkulasi udara yang baik
• Gunakan pestisida organik jika diperlukan
• Isolasi bibit yang terinfeksi
''',
    ),
    GuideItem(
      title: 'Panen & Pasca Panen 🥬',
      description: 'Teknik panen dan penanganan pasca panen',
      icon: Icons.agriculture_rounded,
      color: const Color(0xFF795548),
      gradient: null,
      isExpanded: false,
      details: '''
WAKTU PANEN IDEAL:
• Lettuce daun: 30-45 hari setelah semai
• Lettuce kepala: 55-70 hari setelah semai
• Panen pagi hari saat suhu masih sejuk

TEKNIK PANEN:
• Gunakan pisau tajam dan bersih
• Potong 2-3 cm di atas tanah
• Untuk daun, panen dari luar ke dalam
• Sisakan beberapa daun untuk regenerasi

PENANGANAN PASCA PANEN:
• Cuci dengan air bersih
• Keringkan dengan tisu atau spinner
• Simpan di kulkas (4°C)
• Konsumsi dalam 5-7 hari
''',
    ),
  ];

  void _toggleExpansion(int index) {
    setState(() {
      _guideItems[index].isExpanded = !_guideItems[index].isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 20),
          const Text(
            'Panduan Lengkap Budidaya Lettuce',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Pelajari cara merawat bibit lettuce dengan benar',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ..._guideItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildGuideCard(item, index);
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGuideCard(GuideItem item, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: item.gradient,
        color: item.gradient == null ? Colors.white : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _toggleExpansion(index),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: item.gradient != null
                            ? Colors.white24
                            : item.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.icon,
                        color:
                            item.gradient != null ? Colors.white : item.color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: item.gradient != null
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: item.gradient != null
                                  ? Colors.white70
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 300),
                      turns: item.isExpanded ? 0.5 : 0,
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color:
                            item.gradient != null ? Colors.white : item.color,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                if (item.isExpanded) ...[
                  const SizedBox(height: 16),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: item.gradient != null
                            ? Colors.white.withOpacity(0.1)
                            : item.color.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.details,
                        style: TextStyle(
                          fontSize: 14,
                          color: item.gradient != null
                              ? Colors.white
                              : Colors.grey[700],
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (item.gradient == null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_rounded,
                          color: item.color,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tips: Tap untuk menutup',
                          style: TextStyle(
                            color: item.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ] else if (item.gradient == null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_rounded,
                        color: item.color,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tap untuk info detail →',
                        style: TextStyle(
                          color: item.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GuideItem {
  final String title;
  final String description;
  final String details;
  final IconData icon;
  final Color color;
  final Gradient? gradient;
  bool isExpanded;

  GuideItem({
    required this.title,
    required this.description,
    required this.details,
    required this.icon,
    required this.color,
    required this.gradient,
    required this.isExpanded,
  });
}
