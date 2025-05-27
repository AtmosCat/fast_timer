class TimerItem {
  final int? id;
  final String name;
  final int hour;
  final int minute;
  final int second;
  final double speed;

  // 상태 관련 파라미터
  final int remainingSeconds;
  final bool isRunning; // 실행 중이면 true, 일시정지면 false
  final double progress; // 0.0 ~ 1.0

  TimerItem({
    this.id,
    required this.name,
    required this.hour,
    required this.minute,
    required this.second,
    required this.speed,
    required this.remainingSeconds,
    required this.isRunning,
    required this.progress,
  });

  TimerItem copyWith({
    String? name,
    int? hour,
    int? minute,
    int? second,
    double? speed,
    int? remainingSeconds,
    bool? isRunning,
    double? progress,
  }) {
    return TimerItem(
      id: id,
      name: name ?? this.name,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      second: second ?? this.second,
      speed: speed ?? this.speed,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      progress: progress ?? this.progress,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'hour': hour,
      'minute': minute,
      'second': second,
      'speed': speed,
      'remainingSeconds': remainingSeconds,
      'isRunning': isRunning ? 1 : 0, // DB 저장 시 int로 변환
      'progress': progress,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory TimerItem.fromMap(Map<String, dynamic> map) {
    return TimerItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      hour: map['hour'] as int,
      minute: map['minute'] as int,
      second: map['second'] as int,
      speed: map['speed'] as double,
      remainingSeconds: map['remainingSeconds'] as int,
      isRunning: (map['isRunning'] as int) == 1,
      progress: (map['progress'] as num).toDouble(),
    );
  }
}
