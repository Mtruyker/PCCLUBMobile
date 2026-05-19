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
    final rawId = json['id'] ?? json['clientId'] ?? json['userId'] ?? 0;
    final parsedId = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;
    final rawBalance = json['balance'] ?? json['walletBalance'] ?? 0;

    return ClientProfile(
      id: parsedId,
      name: (json['name'] ?? json['fullName'] ?? '').toString(),
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      balance: (rawBalance as num?)?.toDouble() ?? 0,
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
