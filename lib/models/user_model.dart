class UserModel {
  final String email;
  final String role;

  UserModel({required this.email, required this.role});

  factory UserModel.fromFirestore(Map<String, dynamic> data, String email) {
    return UserModel(
      email: email,
      role: data['role'] ?? 'staff',
    );
  }
}