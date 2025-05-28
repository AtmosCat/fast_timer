class TimerItem {
  final int? id;
  final String name;
  final int targetSeconds;       // 전체 시간(초)
  final double speed;

  // 상태 관련 파라미터
  final int remainingSeconds;    // 일시정지 시점의 남은 시간(초)
  final bool isRunning;          // 실행 중이면 true, 일시정지면 false
  final double progress;         // 0.0 ~ 1.0
  final DateTime? lastStartTime; // 실행 중일 때, 마지막으로 재생한 시각

  TimerItem({
    this.id,
    required this.name,
    required this.targetSeconds,
    required this.speed,
    required this.remainingSeconds,
    required this.isRunning,
    required this.progress,
    this.lastStartTime,
  });

  TimerItem copyWith({
    String? name,
    int? targetSeconds,
    double? speed,
    int? remainingSeconds,
    bool? isRunning,
    double? progress,
    DateTime? lastStartTime,
  }) {
    return TimerItem(
      id: id,
      name: name ?? this.name,
      targetSeconds: targetSeconds ?? this.targetSeconds,
      speed: speed ?? this.speed,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      progress: progress ?? this.progress,
      lastStartTime: lastStartTime ?? this.lastStartTime,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'targetSeconds': targetSeconds,
      'speed': speed,
      'remainingSeconds': remainingSeconds,
      'isRunning': isRunning ? 1 : 0,
      'progress': progress,
      'lastStartTime': lastStartTime?.toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory TimerItem.fromMap(Map<String, dynamic> map) {
    return TimerItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      targetSeconds: map['targetSeconds'] as int,
      speed: map['speed'] as double,
      remainingSeconds: map['remainingSeconds'] as int,
      isRunning: (map['isRunning'] as int) == 1,
      progress: (map['progress'] as num).toDouble(),
      lastStartTime: map['lastStartTime'] != null
          ? DateTime.tryParse(map['lastStartTime'])
          : null,
    );
  }
}
