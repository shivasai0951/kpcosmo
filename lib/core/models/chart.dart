import 'dart:convert';

import 'package:uuid/uuid.dart';

class Chart {
  final String id;
  final String profileId;
  final String ayanamsaSetting;
  final String houseSystem;
  final String nodeType;
  final String calculationVersion;
  final String ephemerisVersion;
  final Map<String, dynamic> chartJson;
  final DateTime calculatedAt;

  Chart({
    required this.id,
    required this.profileId,
    required this.ayanamsaSetting,
    required this.houseSystem,
    required this.nodeType,
    required this.calculationVersion,
    required this.ephemerisVersion,
    required this.chartJson,
    required this.calculatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'ayanamsa_setting': ayanamsaSetting,
      'house_system': houseSystem,
      'node_type': nodeType,
      'calculation_version': calculationVersion,
      'ephemeris_version': ephemerisVersion,
      'chart_json': json.encode(chartJson),
      'calculated_at': calculatedAt.toIso8601String(),
    };
  }

  factory Chart.fromMap(Map<String, dynamic> map) {
    return Chart(
      id: map['id'] ?? const Uuid().v4(),
      profileId: map['profile_id'] ?? '',
      ayanamsaSetting: map['ayanamsa_setting'] ?? '',
      houseSystem: map['house_system'] ?? '',
      nodeType: map['node_type'] ?? '',
      calculationVersion: map['calculation_version'] ?? '',
      ephemerisVersion: map['ephemeris_version'] ?? '',
      chartJson: _decodeChartJson(map['chart_json']),
      calculatedAt: DateTime.parse(map['calculated_at']),
    );
  }

  static Map<String, dynamic> _decodeChartJson(dynamic raw) {
    try {
      final decoded = json.decode(raw as String? ?? '{}');
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return {'raw': raw?.toString() ?? '{}'};
  }

  Chart copyWith({
    String? id,
    String? profileId,
    String? ayanamsaSetting,
    String? houseSystem,
    String? nodeType,
    String? calculationVersion,
    String? ephemerisVersion,
    Map<String, dynamic>? chartJson,
    DateTime? calculatedAt,
  }) {
    return Chart(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      ayanamsaSetting: ayanamsaSetting ?? this.ayanamsaSetting,
      houseSystem: houseSystem ?? this.houseSystem,
      nodeType: nodeType ?? this.nodeType,
      calculationVersion: calculationVersion ?? this.calculationVersion,
      ephemerisVersion: ephemerisVersion ?? this.ephemerisVersion,
      chartJson: chartJson ?? this.chartJson,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }
}