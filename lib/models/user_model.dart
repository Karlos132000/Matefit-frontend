class UserModel {
  String email;
  String username;
  String role;
  String phoneNumber;
  String reminderTime;
  List<String> reminderDays;
  int weight;
  bool enabled;

  UserModel({
    required this.email,
    required this.username,
    required this.role,
    required this.phoneNumber,
    required this.reminderTime,
    required this.reminderDays,
    required this.weight,
    required this.enabled,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'],
      username: json['username'],
      role: json['role'],
      phoneNumber: json['phoneNumber'],
      reminderTime: json['reminderTime'],
      reminderDays: List<String>.from(json['reminderDays']),
      weight: json['weight'],
      enabled: json['enabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "username": username,
      "role": role,
      "phoneNumber": phoneNumber,
      "reminderTime": reminderTime,
      "reminderDays": reminderDays,
      "weight": weight,
      "enabled": enabled,
    };
  }
}
