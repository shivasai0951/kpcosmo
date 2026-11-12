import 'package:uuid/uuid.dart';

class HouseCusp {
  final String id;
  final String chartId;
  final int houseNumber;
  final double longitude;
  final String signLord;
  final String starLord;
  final String subLord;

  HouseCusp({
    required this.id,
    required this.chartId,
    required this.houseNumber,
    required this.longitude,
    required this.signLord,
    required this.starLord,
    required this.subLord,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chart_id': chartId,
      'house_number': houseNumber,
      'longitude': longitude,
      'sign_lord': signLord,
      'star_lord': starLord,
      'sub_lord': subLord,
    };
  }

  factory HouseCusp.fromMap(Map<String, dynamic> map) {
    return HouseCusp(
      id: map['id'] ?? const Uuid().v4(),
      chartId: map['chart_id'] ?? '',
      houseNumber: map['house_number'] ?? 0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      signLord: map['sign_lord'] ?? '',
      starLord: map['star_lord'] ?? '',
      subLord: map['sub_lord'] ?? '',
    );
  }

  HouseCusp copyWith({
    String? id,
    String? chartId,
    int? houseNumber,
    double? longitude,
    String? signLord,
    String? starLord,
    String? subLord,
  }) {
    return HouseCusp(
      id: id ?? this.id,
      chartId: chartId ?? this.chartId,
      houseNumber: houseNumber ?? this.houseNumber,
      longitude: longitude ?? this.longitude,
      signLord: signLord ?? this.signLord,
      starLord: starLord ?? this.starLord,
      subLord: subLord ?? this.subLord,
    );
  }

  String getSignFromLongitude(double longitude) {
    final signs = ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'];
    final signIndex = ((longitude / 30).floor() % 12);
    return signs[signIndex];
  }
}