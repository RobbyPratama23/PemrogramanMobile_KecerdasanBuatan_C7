class User {
  String username;
  String email;
  DateTime joinDate;
  int totalScans;

  User({
    required this.username,
    required this.email,
    required this.joinDate,
    this.totalScans = 0,
  });

  User copyWith({
    String? username,
    String? email,
    DateTime? joinDate,
    int? totalScans,
  }) {
    return User(
      username: username ?? this.username,
      email: email ?? this.email,
      joinDate: joinDate ?? this.joinDate,
      totalScans: totalScans ?? this.totalScans,
    );
  }
}
