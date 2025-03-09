class Creator {
  final int id;
  final String name;
  final String email;
  final String avatar;

  Creator({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
  });

  factory Creator.fromJson(Map<String, dynamic> json) {
    return Creator(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'] ?? '',
    );
  }
}
