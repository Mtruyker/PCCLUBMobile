class Booking {
  final int id;
  final String pcName;
  final DateTime startTime;
  final int durationHours;
  final double totalPrice;
  final String status;

  Booking({
    required this.id,
    required this.pcName,
    required this.startTime,
    required this.durationHours,
    required this.totalPrice,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? 0;
    final rawStartTime = json['startTime'] ?? json['startAt'] ?? json['date'];
    final rawDuration = json['duration'] ?? json['durationHours'] ?? json['hours'] ?? 1;
    final rawPrice = json['totalPrice'] ?? json['price'] ?? json['amount'] ?? 0.0;
    final rawPc = json['pc'];
    final rawPcName = json['pcName'] ??
        json['computerName'] ??
        (rawPc is Map ? rawPc['name'] ?? rawPc['number'] : null) ??
        'Неизвестный ПК';

    return Booking(
      id: rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0,
      pcName: rawPcName.toString(),
      startTime: DateTime.parse(rawStartTime.toString()),
      durationHours: rawDuration is int ? rawDuration : int.tryParse(rawDuration.toString()) ?? 1,
      totalPrice: (rawPrice as num?)?.toDouble() ?? 0.0,
      status: (json['status'] ?? 'active').toString(),
    );
  }
}
