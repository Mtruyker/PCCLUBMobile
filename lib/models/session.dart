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
    final rawPc = json['pc'];
    final rawId = json['id'] ?? 0;
    final rawStartTime = json['startTime'] ?? json['startAt'];
    final rawEndTime = json['endTime'] ?? json['endAt'];
    final rawCost = json['cost'] ?? json['totalCost'] ?? json['amount'] ?? 0.0;
    final rawPcName = json['pcName'] ??
        json['computerName'] ??
        (rawPc is Map ? rawPc['name'] ?? rawPc['number'] : null) ??
        'Unknown PC';

    return Session(
      id: rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0,
      startTime: DateTime.parse(rawStartTime.toString()),
      endTime: DateTime.parse(rawEndTime.toString()),
      pcName: rawPcName.toString(),
      cost: (rawCost as num?)?.toDouble() ?? 0.0,
    );
  }
}
