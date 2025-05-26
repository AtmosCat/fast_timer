class TimerItem {
  final int? id;
  final String name;
  final int hour;
  final int minute;
  final int second;

  TimerItem({
    this.id,
    required this.name,
    required this.hour,
    required this.minute,
    required this.second,
  });

  TimerItem copyWith({String? name, int? hour, int? minute, int? second}) {
    return TimerItem(
      id: id,
      name: name ?? this.name,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      second: second ?? this.second,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'hour': hour,
      'minute': minute,
      'second': second,
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
    );
  }
}
