import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class PlanetaryPosition {
  final String id;
  final String chartId;
  final String planetName;
  final double absoluteLongitude;
  final String sign;
  final double signDegree;
  final String nakshatra;
  final int pada;
  final String starLord;
  final String subLord;
  final int houseNumber;
  final bool retrograde;

  PlanetaryPosition({
    required this.id,
    required this.chartId,
    required this.planetName,
    required this.absoluteLongitude,
    required this.sign,
    required this.signDegree,
    required this.nakshatra,
    required this.pada,
    required this.starLord,
    required this.subLord,
    required this.houseNumber,
    required this.retrograde,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chart_id': chartId,
      'planet_name': planetName,
      'absolute_longitude': absoluteLongitude,
      'sign': sign,
      'sign_degree': signDegree,
      'nakshatra': nakshatra,
      'pada': pada,
      'star_lord': starLord,
      'sub_lord': subLord,
      'house_number': houseNumber,
      'retrograde': retrograde ? 1 : 0,
    };
  }

  factory PlanetaryPosition.fromMap(Map<String, dynamic> map) {
    return PlanetaryPosition(
      id: map['id'] ?? const Uuid().v4(),
      chartId: map['chart_id'] ?? '',
      planetName: map['planet_name'] ?? '',
      absoluteLongitude: map['absolute_longitude']?.toDouble() ?? 0.0,
      sign: map['sign'] ?? '',
      signDegree: map['sign_degree']?.toDouble() ?? 0.0,
      nakshatra: map['nakshatra'] ?? '',
      pada: map['pada'] ?? 0,
      starLord: map['star_lord'] ?? '',
      subLord: map['sub_lord'] ?? '',
      houseNumber: map['house_number'] ?? 0,
      retrograde: map['retrograde'] == 1,
    );
  }

  PlanetaryPosition copyWith({
    String? id,
    String? chartId,
    String? planetName,
    double? absoluteLongitude,
    String? sign,
    double? signDegree,
    String? nakshatra,
    int? pada,
    String? starLord,
    String? subLord,
    int? houseNumber,
    bool? retrograde,
  }) {
    return PlanetaryPosition(
      id: id ?? this.id,
      chartId: chartId ?? this.chartId,
      planetName: planetName ?? this.planetName,
      absoluteLongitude: absoluteLongitude ?? this.absoluteLongitude,
      sign: sign ?? this.sign,
      signDegree: signDegree ?? this.signDegree,
      nakshatra: nakshatra ?? this.nakshatra,
      pada: pada ?? this.pada,
      starLord: starLord ?? this.starLord,
      subLord: subLord ?? this.subLord,
      houseNumber: houseNumber ?? this.houseNumber,
      retrograde: retrograde ?? this.retrograde,
    );
  }

  String getFormattedDegree() {
    final degrees = signDegree.floor();
    final minutes = ((signDegree - degrees) * 60).floor();
    final seconds = (((signDegree - degrees) * 60 - minutes) * 60).round();
    return '${degrees}°${minutes}\'${seconds}"';
  }

  Color getPlanetColor() {
    switch (planetName.toLowerCase()) {
      case 'sun':
        return const Color(0xFFF0B85B);
      case 'moon':
        return const Color(0xFF83B7FF);
      case 'mars':
        return const Color(0xFFEF727C);
      case 'mercury':
        return const Color(0xFF48C78E);
      case 'jupiter':
        return const Color(0xFFE8BC69);
      case 'venus':
        return const Color(0xFFF5D99A);
      case 'saturn':
        return const Color(0xFF9FA6D2);
      case 'rahu':
        return const Color(0xFFB98CF5);
      case 'ketu':
        return const Color(0xFF7FD4C1);
      default:
        return const Color(0xFFC4B4D3);
    }
  }

  String getPlanetIcon() {
    switch (planetName.toLowerCase()) {
      case 'sun':
        return '☀️';
      case 'moon':
        return '🌙';
      case 'mars':
        return '🔴';
      case 'mercury':
        return '⚪';
      case 'jupiter':
        return '🟡';
      case 'venus':
        return '🟠';
      case 'saturn':
        return '⚫';
      case 'rahu':
        return '🌗';
      case 'ketu':
        return '🌘';
      default:
        return '🪐';
    }
  }
}