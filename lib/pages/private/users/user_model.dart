class User {
  int? id;
  String username;
  String email;
  String password;
  String level;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.level,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'level': level,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      level: map['level'],
    );
  }
}
