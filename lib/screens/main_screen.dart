import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/detection_history.dart';
import '../widgets/app_drawer.dart';
import 'home_screen.dart';
import 'upload_screen.dart';
import 'history_screen.dart';
import 'guide_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  final User user;
  final VoidCallback onLogout;
  final Function(User) onUpdateProfile;

  const MainScreen({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onUpdateProfile,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late List<DetectionHistory> _detectionHistory;
  late User _currentUser; // Tambahkan ini

  @override
  void initState() {
    super.initState();
    _detectionHistory = [];
    _currentUser = widget.user; // Initialize current user
  }

  void _addDetectionResult(DetectionHistory history) {
    setState(() {
      _detectionHistory.insert(0, history);
      // Update total scans user
      _currentUser = _currentUser.copyWith(
        totalScans: _currentUser.totalScans + 1,
      );
      widget.onUpdateProfile(_currentUser); // Update di service
    });
  }

  void _updateUserProfile(User updatedUser) {
    setState(() {
      _currentUser = updatedUser;
    });
    widget.onUpdateProfile(updatedUser);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      HomeScreen(
        user: _currentUser, // Gunakan _currentUser, bukan widget.user
        detectionHistory: _detectionHistory,
      ),
      UploadScreen(onDetectionComplete: _addDetectionResult),
      HistoryScreen(detectionHistory: _detectionHistory),
      const GuideScreen(),
      ProfileScreen(
        user: _currentUser, // Gunakan _currentUser, bukan widget.user
        onUpdateProfile: _updateUserProfile,
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Lettuce Health',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(
        user: _currentUser, // Gunakan _currentUser
        onLogout: widget.onLogout,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF4CAF50),
            unselectedItemColor: Colors.grey,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            backgroundColor: Colors.white,
            elevation: 10,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                activeIcon: Icon(Icons.home_filled),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt_rounded),
                activeIcon: Icon(Icons.camera_alt),
                label: 'Scan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded),
                activeIcon: Icon(Icons.history),
                label: 'Riwayat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book_rounded),
                activeIcon: Icon(Icons.book),
                label: 'Panduan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                activeIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
