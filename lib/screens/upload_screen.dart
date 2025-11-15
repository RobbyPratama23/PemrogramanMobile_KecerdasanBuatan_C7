import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/detection_history.dart';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class UploadScreen extends StatefulWidget {
  final Function(DetectionHistory) onDetectionComplete;

  const UploadScreen({super.key, required this.onDetectionComplete});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool _isProcessing = false;
  double _progressValue = 0.0;
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;
  Uint8List? _webImageBytes;

  // TFLite variables
  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  // Define labels directly in code
  final List<String> _labels = ['normal', 'stres'];
  final Map<String, String> _treatmentAdvice = {
    'normal':
        'Bibit dalam kondisi optimal. Pertahankan penyiraman rutin dan pastikan pencahayaan yang cukup.',
    'stres':
        'Bibit menunjukkan tanda stress. Periksa kelembaban tanah, beri nutrisi organik, dan atur ulang pencahayaan.'
  };

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  Future<void> _loadModel() async {
    try {
      setState(() {
        _progressValue = 0.1;
      });

      // Load model
      final options = InterpreterOptions();

      // Use GPU Delegate jika tersedia (untuk performa lebih baik)
      // try {
      //   options.addDelegate(GpuDelegateV2());
      // } catch (e) {
      //   print('GPU delegate not supported: $e');
      // }

      _interpreter = await Interpreter.fromAsset('assets/lettuce_model.tflite',
          options: options);

      setState(() {
        _progressValue = 1.0;
      });

      print(
          'Model loaded successfully. Input shape: ${_interpreter!.getInputTensors()}');
      print('Output shape: ${_interpreter!.getOutputTensors()}');

      // Reset progress setelah loading selesai
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _isModelLoaded = true;
          _progressValue = 0.0;
        });
      }
    } catch (e) {
      print('Failed to load model: $e');
      _showErrorDialog('Gagal memuat model AI: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });

        // Untuk web, simpan bytes-nya
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
          });
        }

        _startDetection(image);
      }
    } catch (e) {
      _showErrorDialog('Gagal mengambil gambar: $e');
    }
  }

  Future<Map<String, dynamic>> _runInference(Uint8List imageBytes) async {
    // Decode dan resize image
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception("Gagal decode image");

    final resized = img.copyResize(image, width: 224, height: 224);

    // Preprocess menjadi float [0,1]
    final input = _preprocessImage(resized);

    // Output untuk 1 neuron (sigmoid)
    var output = List.generate(1, (_) => List.filled(1, 0.0));

    _interpreter!.run(input, output);

    return _postprocessResults(output[0]);
  }

  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    // Membuat 4D array [1,224,224,3]
    final input = List.generate(
      1,
      (_) => List.generate(
        224,
        (_) => List.generate(
          224,
          (_) => List.filled(3, 0.0),
        ),
      ),
    );

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = image.getPixel(x, y);
        input[0][y][x][0] = (pixel.r / 127.5) - 1.0;
        input[0][y][x][1] = (pixel.g / 127.5) - 1.0;
        input[0][y][x][2] = (pixel.b / 127.5) - 1.0;
      }
    }

    return input;
  }

  Map<String, dynamic> _postprocessResults(List<double> predictions) {
    final value = predictions[0]; // 0..1 karena sigmoid
    String label = value <= 0.5 ? "normal" : "stres";
    double confidence = value <= 0.5 ? 1 - value : value;

    return {
      "label": label,
      "confidence": confidence,
      "allPredictions": {
        "normal": 1 - value,
        "stres": value,
      }
    };
  }

  Future<void> _startDetection(XFile imageFile) async {
    if (!mounted || !_isModelLoaded) return;

    setState(() {
      _isProcessing = true;
      _progressValue = 0.0;
    });

    try {
      // Step 1: Load image
      setState(() {
        _progressValue = 0.2;
      });

      Uint8List imageBytes;
      if (kIsWeb) {
        imageBytes = await imageFile.readAsBytes();
      } else {
        final file = File(imageFile.path);
        imageBytes = await file.readAsBytes();
      }

      // Step 2: Run AI inference
      setState(() {
        _progressValue = 0.5;
      });

      final results = await _runInference(imageBytes);

      setState(() {
        _progressValue = 0.8;
      });

      // Step 3: Prepare history data
      String imageData;
      String imageType;

      if (kIsWeb) {
        imageData = base64Encode(imageBytes);
        imageType = 'base64';
      } else {
        imageData = imageFile.path;
        imageType = 'file';
      }

      // Generate treatment advice berdasarkan hasil AI
      String status = results['label'];
      double confidence = results['confidence'];

      String treatmentAdvice = _treatmentAdvice[status] ??
          'Perhatikan kondisi bibit secara berkala. Pastikan kebutuhan air dan nutrisi tercukupi.';

      final history = DetectionHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: imageData,
        imageType: imageType,
        status: status,
        confidence: confidence,
        detectionDate: DateTime.now(),
        treatmentAdvice: treatmentAdvice,
      );

      widget.onDetectionComplete(history);

      setState(() {
        _progressValue = 1.0;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _progressValue = 0.0;
      });

      _showDetectionResult(history, results['allPredictions']);
    } catch (e) {
      print('Detection error: $e');
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _progressValue = 0.0;
        });
        _showErrorDialog('Gagal memproses gambar: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_isProcessing) return const SizedBox();

    if (_selectedImage == null) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_rounded, size: 60, color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Tap untuk scan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    if (kIsWeb && _webImageBytes != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: MemoryImage(_webImageBytes!),
                fit: BoxFit.cover,
              ),
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Gambar dipilih\nTap untuk ganti',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else if (!kIsWeb) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: FileImage(File(_selectedImage!.path)),
                fit: BoxFit.cover,
              ),
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Gambar dipilih\nTap untuk ganti',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return const SizedBox();
  }

  void _showDetectionResult(
      DetectionHistory history, Map<String, double> allPredictions) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: history.status == 'normal'
                ? const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                  )
                : history.status == 'stres'
                    ? const LinearGradient(
                        colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                      )
                    : const LinearGradient(
                        colors: [Color(0xFFF44336), Color(0xFFEF5350)],
                      ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gambar hasil scan
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: history.imageType == 'base64'
                      ? DecorationImage(
                          image: MemoryImage(base64Decode(history.imagePath)),
                          fit: BoxFit.cover,
                        )
                      : DecorationImage(
                          image: FileImage(File(history.imagePath)),
                          fit: BoxFit.cover,
                        ),
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
              const SizedBox(height: 16),
              Icon(
                history.status == 'normal'
                    ? Icons.check_circle
                    : history.status == ''
                        ? Icons.warning_amber
                        : Icons.error_outline,
                size: 60,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                'Bibit ${history.status}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tingkat Keyakinan: ${(history.confidence * 100).toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),

              // Tampilkan semua prediksi
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: allPredictions.entries
                      .where((entry) =>
                          entry.value > 0.05) // Hanya tampilkan yang > 5%
                      .map((entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                                Text(
                                  '${(entry.value * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  history.treatmentAdvice!,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: history.status == 'normal'
                        ? const Color(0xFF4CAF50)
                        : history.status == 'stres'
                            ? const Color(0xFFFF9800)
                            : const Color(0xFFF44336),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Simpan ke Riwayat'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    if (!_isModelLoaded) {
      _showErrorDialog('Model AI sedang dimuat. Tunggu sebentar...');
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih Sumber Gambar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt_rounded,
                  title: 'Kamera',
                  color: const Color(0xFF4CAF50),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildSourceOption(
                  icon: Icons.photo_library_rounded,
                  title: 'Galeri',
                  color: const Color(0xFF2196F3),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(icon, size: 40, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Scanner Box
              GestureDetector(
                onTap: _isModelLoaded ? _showImageSourceDialog : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    gradient: _isProcessing
                        ? const LinearGradient(
                            colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                          )
                        : _isModelLoaded
                            ? const LinearGradient(
                                colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                              )
                            : const LinearGradient(
                                colors: [Colors.grey, Colors.grey],
                              ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: _isProcessing
                          ? const Color(0xFFFF9800)
                          : _isModelLoaded
                              ? const Color(0xFF4CAF50)
                              : Colors.grey,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_isProcessing
                                ? const Color(0xFFFF9800)
                                : _isModelLoaded
                                    ? const Color(0xFF4CAF50)
                                    : Colors.grey)
                            .withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: !_isModelLoaded && _progressValue > 0
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: _progressValue,
                              strokeWidth: 8,
                              backgroundColor: Colors.white30,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Memuat Model AI...',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        )
                      : _isProcessing
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      value: _progressValue,
                                      strokeWidth: 8,
                                      backgroundColor: Colors.white30,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                    ),
                                    Text(
                                      '${(_progressValue * 100).toInt()}%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Menganalisis Gambar...',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ],
                            )
                          : _buildImagePreview(),
                ),
              ),
              const SizedBox(height: 40),

              // Title Section
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: !_isModelLoaded
                    ? const Column(
                        children: [
                          Text(
                            'Mempersiapkan AI...',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Sedang memuat model deteksi',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      )
                    : _isProcessing
                        ? const Column(
                            children: [
                              Text(
                                'Sedang Menganalisis...',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'AI sedang memproses gambar bibit',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          )
                        : const Column(
                            children: [
                              Text(
                                'Scan Bibit Lettuce',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Deteksi kesehatan bibit dengan AI',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
              ),
              const SizedBox(height: 40),

              // Action Button
              if (_isModelLoaded && !_isProcessing)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _showImageSourceDialog,
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text(
                      'Mulai Scan',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Tips Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2196F3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tips Scan Terbaik:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pencahayaan cukup • Fokus pada daun • Latar polos • Jarak 20-30 cm',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[800],
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
        ),
      ),
    );
  }
}
