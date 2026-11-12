import '../models/dasha_period.dart';
import '../models/planetary_position.dart';
import 'kp_calculator.dart';

/// Result of a KP event analysis.
class EventAnalysisResult {
  final String status; // favorable / mixed / unfavorable / inconclusive
  final String summary;
  final List<String> reasons;
  final int eventHouse;
  final String cuspPosition;
  final String cuspSignLord;
  final String cuspStarLord;
  final String cuspSubLord;
  final List<String> significators; // "Planet (Hn)"
  final List<String> supportingHouses;
  final List<String> opposingHouses;
  final List<DashaPeriod> candidatePeriods;

  const EventAnalysisResult({
    required this.status,
    required this.summary,
    required this.reasons,
    required this.eventHouse,
    required this.cuspPosition,
    required this.cuspSignLord,
    required this.cuspStarLord,
    required this.cuspSubLord,
    required this.significators,
    required this.supportingHouses,
    required this.opposingHouses,
    required this.candidatePeriods,
  });
}

/// KP-style event analysis driven by the calculated chart.
///
/// Method (simplified but explainable KP):
/// - The event's primary house cusp gives the key significators:
///   its sub lord, star lord and sign lord, plus planets occupying it.
/// - Each significator's own house placement is scored: favorable houses
///   support the event, dusthana/opposing houses weaken it.
/// - Candidate timing = Vimshottari dasha periods ruled by significators.
class KpEventAnalyzer {
  KpEventAnalyzer._();

  /// Primary event houses per event type.
  static const _eventHouses = {
    'marriage': [7],
    'job': [10],
    'business': [7, 10],
    'vehicle': [4],
    'children': [5],
    'property': [4],
  };

  /// Houses considered favorable for each event.
  static const _goodHouses = {
    'marriage': {1, 2, 5, 7, 9, 11},
    'job': {2, 6, 10, 11},
    'business': {2, 7, 10, 11},
    'vehicle': {4, 5, 9, 11},
    'children': {5, 9},
    'property': {4, 5, 9, 11},
  };

  /// Houses considered unfavorable (dusthana/opposing) per event.
  static const _badHouses = {
    'marriage': {6, 8, 12},
    'job': {3, 8, 12},
    'business': {6, 8, 12},
    'vehicle': {6, 8, 12},
    'children': {6, 8, 12},
    'property': {6, 8, 12},
  };

  static const _eventNames = {
    'marriage': 'Marriage',
    'job': 'Job / Service',
    'business': 'Business',
    'vehicle': 'Vehicle Purchase',
    'children': 'Children',
    'property': 'Property Purchase',
  };

  static List<String> subOptionsFor(String eventType) {
    switch (eventType) {
      case 'marriage':
        return ['Timing', 'Divorce / Separation'];
      case 'job':
        return ['Job Change', 'Government Service', 'Private Job'];
      case 'business':
        return ['Starting Business', 'Business Expansion', 'Business Partnership'];
      case 'vehicle':
        return ['Two Wheeler', 'Four Wheeler', 'Car'];
      case 'children':
        return ['First Child', 'Child Timing'];
      case 'property':
        return ['House / Plot', 'Shop / Commercial'];
      default:
        return ['General'];
    }
  }

  static EventAnalysisResult analyze(
    CalculatedChart chart,
    String eventType, {
    String subOption = 'General',
  }) {
    final houses = _eventHouses[eventType] ?? [7];
    final good = _goodHouses[eventType] ?? {};
    final bad = _badHouses[eventType] ?? {};
    final eventName = _eventNames[eventType] ?? eventType;

    // Primary cusp = first event house
    final primaryHouse = houses.first;
    final cusp = chart.cusps[primaryHouse - 1];

    // Significator planets: cusp lords + occupants of all event houses
    final houseByPlanet = {for (final p in chart.planets) p.planetName: p.houseNumber};
    final significatorNames = <String>{
      cusp.signLord,
      cusp.starLord,
      cusp.subLord,
      for (final h in houses)
        ...chart.planets.where((p) => p.houseNumber == h).map((p) => p.planetName),
    }.toList();

    final significators = [
      for (final name in significatorNames)
        '$name (H${houseByPlanet[name] ?? '?'})',
    ];

    // Score each significator's placement
    var favorable = 0, unfavorable = 0;
    final reasons = <String>[];
    final supporting = <String>{};
    final opposing = <String>{};

    for (final name in significatorNames) {
      final h = houseByPlanet[name];
      if (h == null) continue;
      if (good.contains(h)) {
        favorable++;
        supporting.add('H$h');
        reasons.add('$name in House $h supports $eventName');
      } else if (bad.contains(h)) {
        unfavorable++;
        opposing.add('H$h');
        reasons.add('$name in House $h (dusthana) weakens $eventName');
      } else {
        reasons.add('$name in House $h is neutral for $eventName');
      }
    }

    // Cusp lord placements always count as reasons too
    reasons.insert(0,
        'Event cusp: House $primaryHouse ${KpCalculator.formatPosition(cusp.longitude)} — Sub Lord ${cusp.subLord}, Star Lord ${cusp.starLord}, Sign Lord ${cusp.signLord}');

    final String status;
    if (significatorNames.isEmpty) {
      status = 'inconclusive';
    } else if (favorable > unfavorable && favorable >= 2) {
      status = 'favorable';
    } else if (unfavorable > favorable && unfavorable >= 2) {
      status = 'unfavorable';
    } else if (favorable > 0 || unfavorable > 0) {
      status = 'mixed';
    } else {
      status = 'inconclusive';
    }

    final String summary;
    switch (status) {
      case 'favorable':
        summary = '$eventName indications are favorable under the selected KP rules.';
        break;
      case 'unfavorable':
        summary = '$eventName indications are currently unfavorable; wait for better periods.';
        break;
      case 'mixed':
        summary = '$eventName indications are mixed — favorable only in specific periods.';
        break;
      default:
        summary = 'Insufficient indications for $eventName at this time.';
    }

    // Candidate periods: dashas ruled by significator planets
    final sigSet = significatorNames.toSet();
    final periods = chart.dashas
        .where((d) => sigSet.contains(d.planet))
        .toList()
      ..sort((a, b) => a.startTimestamp.compareTo(b.startTimestamp));

    return EventAnalysisResult(
      status: status,
      summary: summary,
      reasons: reasons,
      eventHouse: primaryHouse,
      cuspPosition: KpCalculator.formatPosition(cusp.longitude),
      cuspSignLord: cusp.signLord,
      cuspStarLord: cusp.starLord,
      cuspSubLord: cusp.subLord,
      significators: significators,
      supportingHouses: supporting.toList()..sort(),
      opposingHouses: opposing.toList()..sort(),
      candidatePeriods: periods.take(20).toList(),
    );
  }
}
