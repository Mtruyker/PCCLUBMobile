class Booking {
  final int id;
  final String pcName;
  final DateTime startTime;
  final int durationHours;
  final double totalPrice;
  final String status; // 'pending', 'confirmed', 'cancelled'

  Booking({
    required this.id,
    required this.pcName,
    required this.startTime,
    required this.durationHours,
    required this.totalPrice,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? 0,
      pcName: json['pcName'] ?? 'Неизвестный ПК',
      startTime: DateTime.parse(json['startTime']),
      durationHours: json['duration'] ?? 1,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
    );
  }
}
