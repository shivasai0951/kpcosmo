import 'package:uuid/uuid.dart';

class DashaPeriod {
  final String id;
  final String chartId;
  final String? parentPeriodId;
  final String level;
  final String planet;
  final DateTime startTimestamp;
  final DateTime endTimestamp;

  DashaPeriod({
    required this.id,
    required this.chartId,
    this.parentPeriodId,
    required this.level,
    required this.planet,
    required this.startTimestamp,
    required this.endTimestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chart_id': chartId,
      'parent_period_id': parentPeriodId,
      'level': level,
      'planet': planet,
      'start_timestamp': startTimestamp.millisecondsSinceEpoch,
      'end_timestamp': endTimestamp.millisecondsSinceEpoch,
    };
  }

  factory DashaPeriod.fromMap(Map<String, dynamic> map) {
    return DashaPeriod(
      id: map['id'] ?? const Uuid().v4(),
      chartId: map['chart_id'] ?? '',
      parentPeriodId: map['parent_period_id'],
      level: map['level'] ?? '',
      planet: map['planet'] ?? '',
      startTimestamp: DateTime.fromMillisecondsSinceEpoch(map['start_timestamp']),
      endTimestamp: DateTime.fromMillisecondsSinceEpoch(map['end_timestamp']),
    );
  }

  DashaPeriod copyWith({
    String? id,
    String? chartId,
    String? parentPeriodId,
    String? level,
    String? planet,
    DateTime? startTimestamp,
    DateTime? endTimestamp,
  }) {
    return DashaPeriod(
      id: id ?? this.id,
      chartId: chartId ?? this.chartId,
      parentPeriodId: parentPeriodId ?? this.parentPeriodId,
      level: level ?? this.level,
      planet: planet ?? this.planet,
      startTimestamp: startTimestamp ?? this.startTimestamp,
      endTimestamp: endTimestamp ?? this.endTimestamp,
    );
  }

  String getFormattedStartDate() {
    return '${startTimestamp.day}/${startTimestamp.month}/${startTimestamp.year}';
  }

  String getFormattedEndDate() {
    return '${endTimestamp.day}/${endTimestamp.month}/${endTimestamp.year}';
  }

  Duration getDuration() {
    return endTimestamp.difference(startTimestamp);
  }

  bool get isCurrent {
    final now = DateTime.now();
    return now.isAfter(startTimestamp) && now.isBefore(endTimestamp);
  }

  bool get isPast {
    return DateTime.now().isAfter(endTimestamp);
  }

  bool get isUpcoming {
    return DateTime.now().isBefore(startTimestamp);
  }
}