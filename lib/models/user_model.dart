class User {
  final String username;
  final String email;
  final String password;

  User(
      {required this.username,
      required this.email,
      required this.password,
      required String name,
      required String dateOfBirth,
      required String address});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      email: json['email'],
      password: json['password'],
      name: json['name'],
      dateOfBirth: json['dateOfBirth'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
    };
  }
}
