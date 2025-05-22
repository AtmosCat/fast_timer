
class TimerRecord {
  final int? id;
  final int timerId;
  final int targetSeconds;
  final double speed;
  final int recordedSeconds;
  final int actualSeconds;
  final DateTime startedAt;
  final DateTime endedAt;

  TimerRecord({
    this.id,
    required this.timerId,
    required this.targetSeconds,
    required this.speed,
    required this.recordedSeconds,
    required this.actualSeconds,
    required this.startedAt,
    required this.endedAt,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'timerId': timerId,
      'targetSeconds': targetSeconds,
      'speed': speed,
      'recordedSeconds': recordedSeconds,
      'actualSeconds': actualSeconds,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt.toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory TimerRecord.fromMap(Map<String, dynamic> map) {
    return TimerRecord(
      id: map['id'] as int?,
      timerId: map['timerId'] as int,
      targetSeconds: map['targetSeconds'] as int,
      speed: (map['speed'] as num).toDouble(),
      recordedSeconds: map['recordedSeconds'] as int,
      actualSeconds: map['actualSeconds'] as int,
      startedAt: DateTime.parse(map['startedAt'] as String),
      endedAt: DateTime.parse(map['endedAt'] as String),
    );
  }
}
