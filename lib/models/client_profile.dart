class ClientProfile {
  final int id;
  final String name;
  final String phone;
  final String email;
  final double balance;

  ClientProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.balance,
  });

  factory ClientProfile.fromJson(Map<String, dynamic> json) {
    return ClientProfile(
      id: json['id'],
      name: json['name'],
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      balance: (json['balance'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'balance': balance,
    };
  }
}
