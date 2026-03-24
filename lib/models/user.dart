enum UserRole {
  admin,
  cashier,
}

class User {
  final String username;
  final UserRole role;
  final String displayName;

  User({
    required this.username,
    required this.role,
    required this.displayName,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'role': role.name,
      'displayName': displayName,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.cashier,
      ),
      displayName: json['displayName'] as String,
    );
  }
}
