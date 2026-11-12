import '../models/birth_profile.dart';

/// Holds the birth profile most recently submitted from the
/// birth-details form so downstream screens (KP chart, cusps,
/// dasha timeline, event analysis) can display the user's real data.
class ProfileStore {
  ProfileStore._();

  static final ProfileStore instance = ProfileStore._();

  BirthProfile? currentProfile;
}
