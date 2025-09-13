class User {
  final String username;
  final String role;
  final String email;
  final String mobile;
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? address;

  User({
    required this.username,
    required this.role,
    required this.email,
    required this.mobile,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.address,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      username: map['username'] ?? '',
      role: map['role'] ?? '',
      email: map['email'] ?? '',
      mobile: map['mobile'] ?? '',
      firstName: map['firstName'],
      lastName: map['lastName'],
      dateOfBirth: map['dateOfBirth'] != null 
          ? DateTime.parse(map['dateOfBirth']) 
          : null,
      address: map['address'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'role': role,
      'email': email,
      'mobile': mobile,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'address': address,
    };
  }
}
