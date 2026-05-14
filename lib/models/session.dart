class Session {
  final int id;
  final DateTime startTime;
  final DateTime endTime;
  final String pcName;
  final double cost;

  Session({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.pcName,
    required this.cost,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] ?? 0,
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      pcName: json['pcName'] ?? 'Unknown PC',
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
