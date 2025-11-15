import '../models/user.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final List<User> _users = [];
  User? _currentUser;

  // Register new user
  bool register(User newUser, String password) {
    // Check if email already exists
    if (_users.any((user) => user.email == newUser.email)) {
      return false; // Email already registered
    }

    // Check if username already exists
    if (_users.any((user) => user.username == newUser.username)) {
      return false; // Username already taken
    }

    _users.add(newUser);
    // In real app, you'd hash the password and store it securely
    _storePassword(newUser.email, password);
    return true;
  }

  // Login user
  User? login(String email, String password) {
    final user = _users.firstWhere(
      (user) => user.email == email,
      orElse: () => User(username: '', email: '', joinDate: DateTime.now()),
    );

    if (user.email.isNotEmpty && _verifyPassword(email, password)) {
      _currentUser = user;
      return user;
    }
    return null;
  }

  // Update user profile
  bool updateUser(User updatedUser) {
    final index = _users.indexWhere((user) => user.email == updatedUser.email);
    if (index != -1) {
      _users[index] = updatedUser;
      if (_currentUser?.email == updatedUser.email) {
        _currentUser = updatedUser;
      }
      return true;
    }
    return false;
  }

  // Get current user
  User? get currentUser => _currentUser;

  // Logout
  void logout() {
    _currentUser = null;
  }

  // Simple password storage (in real app, use secure storage with hashing)
  final Map<String, String> _passwordStorage = {};

  void _storePassword(String email, String password) {
    _passwordStorage[email] = password; // In real app, hash this password!
  }

  bool _verifyPassword(String email, String password) {
    return _passwordStorage[email] == password;
  }

  // Check if email exists
  bool isEmailExists(String email) {
    return _users.any((user) => user.email == email);
  }

  // Check if username exists
  bool isUsernameExists(String username) {
    return _users.any((user) => user.username == username);
  }
}
