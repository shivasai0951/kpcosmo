import 'package:uuid/uuid.dart';

class BirthProfile {
  final String id;
  final String name;
  final DateTime dateOfBirth;
  final DateTime timeOfBirth;
  final String birthplaceName;
  final double latitude;
  final double longitude;
  final String timezoneId;
  final DateTime utcBirthTimestamp;
  final String? birthTimePrecision;
  final DateTime createdAt;
  final DateTime updatedAt;

  BirthProfile({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.timeOfBirth,
    required this.birthplaceName,
    required this.latitude,
    required this.longitude,
    required this.timezoneId,
    required this.utcBirthTimestamp,
    this.birthTimePrecision,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'time_of_birth': timeOfBirth.toIso8601String(),
      'birthplace_name': birthplaceName,
      'latitude': latitude,
      'longitude': longitude,
      'timezone_id': timezoneId,
      'utc_birth_timestamp': utcBirthTimestamp.millisecondsSinceEpoch,
      'birth_time_precision': birthTimePrecision,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory BirthProfile.fromMap(Map<String, dynamic> map) {
    return BirthProfile(
      id: map['id'] ?? const Uuid().v4(),
      name: map['name'] ?? '',
      dateOfBirth: DateTime.parse(map['date_of_birth']),
      timeOfBirth: DateTime.parse(map['time_of_birth']),
      birthplaceName: map['birthplace_name'] ?? '',
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      timezoneId: map['timezone_id'] ?? '',
      utcBirthTimestamp: DateTime.fromMillisecondsSinceEpoch(map['utc_birth_timestamp']),
      birthTimePrecision: map['birth_time_precision'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  BirthProfile copyWith({
    String? id,
    String? name,
    DateTime? dateOfBirth,
    DateTime? timeOfBirth,
    String? birthplaceName,
    double? latitude,
    double? longitude,
    String? timezoneId,
    DateTime? utcBirthTimestamp,
    String? birthTimePrecision,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BirthProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      timeOfBirth: timeOfBirth ?? this.timeOfBirth,
      birthplaceName: birthplaceName ?? this.birthplaceName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timezoneId: timezoneId ?? this.timezoneId,
      utcBirthTimestamp: utcBirthTimestamp ?? this.utcBirthTimestamp,
      birthTimePrecision: birthTimePrecision ?? this.birthTimePrecision,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String getFormattedDateOfBirth() {
    return '${dateOfBirth.day}/${dateOfBirth.month}/${dateOfBirth.year}';
  }

  String getFormattedTimeOfBirth() {
    return '${timeOfBirth.hour}:${timeOfBirth.minute < 10 ? '0' : ''}${timeOfBirth.minute}';
  }

  String getZodiacSign() {
    final degree = timeOfBirth.hour * 60 + timeOfBirth.minute;
    final zodiacSigns = ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'];
    final signIndex = (degree / 480).floor() % 12;
    return zodiacSigns[signIndex];
  }
}
