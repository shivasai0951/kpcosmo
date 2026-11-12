import 'package:uuid/uuid.dart';

class EventAnalysis {
  final String id;
  final String chartId;
  final String eventType;
  final String ruleSetVersion;
  final String resultStatus;
  final Map<String, dynamic> supportingHouses;
  final Map<String, dynamic> opposingHouses;
  final Map<String, dynamic> explanation;
  final Map<String, dynamic> candidatePeriods;
  final DateTime calculatedAt;

  EventAnalysis({
    required this.id,
    required this.chartId,
    required this.eventType,
    required this.ruleSetVersion,
    required this.resultStatus,
    required this.supportingHouses,
    required this.opposingHouses,
    required this.explanation,
    required this.candidatePeriods,
    required this.calculatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chart_id': chartId,
      'event_type': eventType,
      'rule_set_version': ruleSetVersion,
      'result_status': resultStatus,
      'supporting_houses_json': supportingHouses.toString(),
      'opposing_houses_json': opposingHouses.toString(),
      'explanation_json': explanation.toString(),
      'candidate_periods_json': candidatePeriods.toString(),
      'calculated_at': calculatedAt.toIso8601String(),
    };
  }

  factory EventAnalysis.fromMap(Map<String, dynamic> map) {
    return EventAnalysis(
      id: map['id'] ?? const Uuid().v4(),
      chartId: map['chart_id'] ?? '',
      eventType: map['event_type'] ?? '',
      ruleSetVersion: map['rule_set_version'] ?? '',
      resultStatus: map['result_status'] ?? '',
      supportingHouses: {'raw': map['supporting_houses_json'] ?? '{}'},
      opposingHouses: {'raw': map['opposing_houses_json'] ?? '{}'},
      explanation: {'raw': map['explanation_json'] ?? '{}'},
      candidatePeriods: {'raw': map['candidate_periods_json'] ?? '{}'},
      calculatedAt: DateTime.parse(map['calculated_at']),
    );
  }

  EventAnalysis copyWith({
    String? id,
    String? chartId,
    String? eventType,
    String? ruleSetVersion,
    String? resultStatus,
    Map<String, dynamic>? supportingHouses,
    Map<String, dynamic>? opposingHouses,
    Map<String, dynamic>? explanation,
    Map<String, dynamic>? candidatePeriods,
    DateTime? calculatedAt,
  }) {
    return EventAnalysis(
      id: id ?? this.id,
      chartId: chartId ?? this.chartId,
      eventType: eventType ?? this.eventType,
      ruleSetVersion: ruleSetVersion ?? this.ruleSetVersion,
      resultStatus: resultStatus ?? this.resultStatus,
      supportingHouses: supportingHouses ?? this.supportingHouses,
      opposingHouses: opposingHouses ?? this.opposingHouses,
      explanation: explanation ?? this.explanation,
      candidatePeriods: candidatePeriods ?? this.candidatePeriods,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }
}