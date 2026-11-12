import 'package:sweph/sweph.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/birth_profile.dart';
import '../models/chart.dart';
import '../models/planetary_position.dart';
import '../models/house_cusp.dart';
import '../models/dasha_period.dart';

/// Result of a KP chart calculation.
class CalculatedChart {
  final List<PlanetaryPosition> planets;
  final List<HouseCusp> cusps;
  final List<DashaPeriod> dashas;
  final double ascendantLongitude;
  final double ayanamsa;

  const CalculatedChart({
    required this.planets,
    required this.cusps,
    required this.dashas,
    required this.ascendantLongitude,
    required this.ayanamsa,
  });
}

/// Computes KP astrology chart data offline using Swiss Ephemeris.
///
/// - Sidereal mode: SE_SIDM_KRISHNAMURTI (KP ayanamsa)
/// - House system: Placidus
/// - Nodes: mean Rahu/Ketu (standard for KP)
/// - Sub-lords: KP method (Vimshottari-proportioned division of each
///   nakshatra into 9 parts)
class KpCalculator {
  KpCalculator._();

  static bool _ready = false;
  static CalculatedChart? lastChart;

  static const _signs = [
    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
    'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces',
  ];

  static const _nakshatras = [
    'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira', 'Ardra',
    'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni',
    'Uttara Phalguni', 'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha',
    'Jyeshtha', 'Mula', 'Purva Ashadha', 'Uttara Ashadha', 'Shravana',
    'Dhanishta', 'Shatabhisha', 'Purva Bhadrapada', 'Uttara Bhadrapada',
    'Revati',
  ];

  // Vimshottari dasha sequence and periods (total 120 years)
  static const _vimPlanets = [
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury',
  ];
  static const _vimYears = [7, 20, 6, 10, 7, 18, 16, 19, 17];

  static const _signLords = {
    'Aries': 'Mars', 'Taurus': 'Venus', 'Gemini': 'Mercury',
    'Cancer': 'Moon', 'Leo': 'Sun', 'Virgo': 'Mercury',
    'Libra': 'Venus', 'Scorpio': 'Mars', 'Sagittarius': 'Jupiter',
    'Capricorn': 'Saturn', 'Aquarius': 'Saturn', 'Pisces': 'Jupiter',
  };

  static const double _nakSpan = 40 / 3; // 13°20'
  static final _flag = SwephFlag.SEFLG_SIDEREAL | SwephFlag.SEFLG_SWIEPH;

  static Future<void> init() async {
    if (_ready) return;
    await Sweph.init();
    Sweph.swe_set_sid_mode(SiderealMode.SE_SIDM_KRISHNAMURTI);
    _ready = true;
  }

  /// Calculate the full KP chart for a birth profile.
  static Future<CalculatedChart> calculate(BirthProfile profile) async {
    await init();

    final jd = _julianDay(profile);
    final (cusps, ascendant) = _calculateHouses(jd, profile);
    final planets = assignHouses(_calculatePlanets(jd, profile.id), cusps);
    final dashas = _calculateDashas(profile, planets);
    final ayanamsa = Sweph.swe_get_ayanamsa_ex_ut(jd, SwephFlag.SEFLG_SIDEREAL);

    final chart = CalculatedChart(
      planets: planets,
      cusps: cusps,
      dashas: dashas,
      ascendantLongitude: ascendant,
      ayanamsa: ayanamsa,
    );
    lastChart = chart;
    return chart;
  }

  // ---------------------------------------------------------------------------
  // Time conversion
  // ---------------------------------------------------------------------------

  /// Julian day in UT. The profile stores local birth time plus a UTC offset
  /// encoded in timezoneId (e.g. "UTC", "UTC+5:30", "UTC-8").
  static double _julianDay(BirthProfile profile) {
    final offsetHours = _utcOffsetHours(profile.timezoneId);
    final local = profile.timeOfBirth;
    final ut = local.subtract(Duration(minutes: (offsetHours * 60).round()));
    final hours = ut.hour + ut.minute / 60 + ut.second / 60;
    return Sweph.swe_julday(ut.year, ut.month, ut.day, hours, CalendarType.SE_GREG_CAL);
  }

  static double _utcOffsetHours(String tzId) {
    final m = RegExp(r'([+-])\s*(\d{1,2})(?::(\d{2}))?').firstMatch(tzId);
    if (m == null) return 0;
    final sign = m.group(1) == '-' ? -1 : 1;
    final h = int.parse(m.group(2)!);
    final min = int.parse(m.group(3) ?? '0');
    return sign * (h + min / 60);
  }

  // ---------------------------------------------------------------------------
  // Planetary positions
  // ---------------------------------------------------------------------------

  static List<PlanetaryPosition> _calculatePlanets(double jd, String chartId) {
    const bodies = [
      (HeavenlyBody.SE_SUN, 'Sun'),
      (HeavenlyBody.SE_MOON, 'Moon'),
      (HeavenlyBody.SE_MARS, 'Mars'),
      (HeavenlyBody.SE_MERCURY, 'Mercury'),
      (HeavenlyBody.SE_JUPITER, 'Jupiter'),
      (HeavenlyBody.SE_VENUS, 'Venus'),
      (HeavenlyBody.SE_SATURN, 'Saturn'),
      (HeavenlyBody.SE_MEAN_NODE, 'Rahu'),
    ];

    final positions = <PlanetaryPosition>[];
    double? rahuLon;

    for (final (body, name) in bodies) {
      final coords = Sweph.swe_calc_ut(jd, body, _flag);
      final lon = _normalize(coords.longitude);
      if (name == 'Rahu') rahuLon = lon;

      positions.add(_buildPosition(
        chartId: chartId,
        name: name,
        longitude: lon,
        retrograde: coords.speedInLongitude < 0,
      ));
    }

    // Ketu is always 180° from Rahu and always retrograde
    if (rahuLon != null) {
      positions.add(_buildPosition(
        chartId: chartId,
        name: 'Ketu',
        longitude: _normalize(rahuLon + 180),
        retrograde: true,
      ));
    }

    return positions;
  }

  static PlanetaryPosition _buildPosition({
    required String chartId,
    required String name,
    required double longitude,
    required bool retrograde,
  }) {
    final nakIndex = nakshatraIndex(longitude);
    final remainder = longitude - nakIndex * _nakSpan;
    final pada = (remainder / (_nakSpan / 4)).floor() + 1;

    return PlanetaryPosition(
      id: '$chartId-$name',
      chartId: chartId,
      planetName: name,
      absoluteLongitude: longitude,
      sign: signName(longitude),
      signDegree: longitude % 30,
      nakshatra: _nakshatras[nakIndex],
      pada: pada,
      starLord: _vimPlanets[nakIndex % 9],
      subLord: subLordFor(longitude),
      houseNumber: 0, // filled in by caller after cusps are known
      retrograde: retrograde,
    );
  }

  // ---------------------------------------------------------------------------
  // House cusps (Placidus)
  // ---------------------------------------------------------------------------

  static (List<HouseCusp>, double) _calculateHouses(double jd, BirthProfile profile) {
    final data = Sweph.swe_houses(jd, profile.latitude, profile.longitude, Hsys.P);
    final ascendant = _normalize(data.ascmc[AscmcIndex.SE_ASC.index]);

    final cusps = <HouseCusp>[];
    for (var i = 0; i < 12; i++) {
      final lon = _normalize(data.cusps[i]);
      cusps.add(HouseCusp(
        id: '${profile.id}-h${i + 1}',
        chartId: profile.id,
        houseNumber: i + 1,
        longitude: lon,
        signLord: _signLords[signName(lon)]!,
        starLord: _vimPlanets[nakshatraIndex(lon) % 9],
        subLord: subLordFor(lon),
      ));
    }
    return (cusps, ascendant);
  }

  /// Assign each planet to a house based on the computed cusps.
  static List<PlanetaryPosition> assignHouses(
    List<PlanetaryPosition> planets,
    List<HouseCusp> cusps,
  ) {
    final cuspLons = [for (final c in cusps) c.longitude];
    return [
      for (final p in planets)
        p.copyWith(houseNumber: _houseForLongitude(p.absoluteLongitude, cuspLons)),
    ];
  }

  static int _houseForLongitude(double lon, List<double> cusps) {
    for (var i = 0; i < 12; i++) {
      final start = cusps[i];
      final end = cusps[(i + 1) % 12];
      var rel = (lon - start) % 360;
      if (rel < 0) rel += 360;
      var span = (end - start) % 360;
      if (span <= 0) span += 360;
      if (rel < span) return i + 1;
    }
    return 1;
  }

  // ---------------------------------------------------------------------------
  // Vimshottari dasha (Mahadasha + Antardasha)
  // ---------------------------------------------------------------------------

  static const double _msPerYear = 365.25 * 24 * 60 * 60 * 1000;

  /// Computes Vimshottari dashas from the Moon's nakshatra position.
  /// Generates the balance Mahadasha plus the next 9 (one full cycle),
  /// and Antardashas for the first 3 Mahadashas.
  static List<DashaPeriod> _calculateDashas(
    BirthProfile profile,
    List<PlanetaryPosition> planets,
  ) {
    final moon = planets.firstWhere(
      (p) => p.planetName == 'Moon',
      orElse: () => planets.first,
    );

    final nakIndex = nakshatraIndex(moon.absoluteLongitude);
    final lordIndex = nakIndex % 9;
    final nakYears = _vimYears[lordIndex].toDouble();
    final remainder = moon.absoluteLongitude - nakIndex * _nakSpan;
    // Balance = remaining fraction of the nakshatra × lord's dasha years
    final balanceYears = nakYears * (1 - remainder / _nakSpan);

    // Mahadasha list: balance MD, then the Vimshottari cycle continues
    final mdSequence = <(String, double)>[
      (_vimPlanets[lordIndex], balanceYears),
      for (var i = 1; i <= 9; i++)
        (_vimPlanets[(lordIndex + i) % 9], _vimYears[(lordIndex + i) % 9].toDouble()),
    ];

    final dashas = <DashaPeriod>[];
    var cursor = profile.timeOfBirth;

    for (var i = 0; i < mdSequence.length; i++) {
      final (planet, years) = mdSequence[i];
      final start = cursor;
      final end = cursor.add(Duration(milliseconds: (years * _msPerYear).round()));
      final mdId = '${profile.id}-md-$i';

      dashas.add(DashaPeriod(
        id: mdId,
        chartId: profile.id,
        level: 'MD',
        planet: planet,
        startTimestamp: start,
        endTimestamp: end,
      ));

      // Antardashas for the first 3 Mahadashas
      if (i < 3) {
        final mdYears = (end.millisecondsSinceEpoch - start.millisecondsSinceEpoch) / _msPerYear;
        final adStartIndex = _vimPlanets.indexOf(planet);
        var adCursor = start;
        for (var j = 0; j < 9; j++) {
          final adPlanet = _vimPlanets[(adStartIndex + j) % 9];
          final adYears = mdYears * _vimYears[(adStartIndex + j) % 9] / 120;
          final adEnd = adCursor.add(Duration(milliseconds: (adYears * _msPerYear).round()));
          dashas.add(DashaPeriod(
            id: '$mdId-ad-$j',
            chartId: profile.id,
            parentPeriodId: mdId,
            level: 'AD',
            planet: adPlanet,
            startTimestamp: adCursor,
            endTimestamp: adEnd,
          ));
          adCursor = adEnd;
        }
      }

      cursor = end;
    }

    return dashas;
  }

  // ---------------------------------------------------------------------------
  // Persistence (offline SQLite)
  // ---------------------------------------------------------------------------

  /// Saves the calculated chart (positions, cusps, dashas) to the local DB.
  /// One chart per profile — previous chart data is replaced.
  static Future<void> saveChart(BirthProfile profile, CalculatedChart chart) async {
    final db = DatabaseHelper();
    await db.deleteChartCascade(profile.id);

    await db.insertChart(Chart(
      id: profile.id,
      profileId: profile.id,
      ayanamsaSetting: 'KP',
      houseSystem: 'Placidus',
      nodeType: 'Mean',
      calculationVersion: '1.0',
      ephemerisVersion: 'Swiss Ephemeris',
      chartJson: {
        'ascendant': chart.ascendantLongitude,
        'ayanamsa': chart.ayanamsa,
      },
      calculatedAt: DateTime.now(),
    ));

    for (final p in chart.planets) {
      await db.insertPlanetaryPosition(p);
    }
    for (final c in chart.cusps) {
      await db.insertHouseCusp(c);
    }
    for (final d in chart.dashas) {
      await db.insertDashaPeriod(d);
    }
  }

  /// Loads the most recently saved chart for a profile, or null if none.
  static Future<CalculatedChart?> loadSaved(BirthProfile profile) async {
    final db = DatabaseHelper();
    final charts = await db.getChartsForProfile(profile.id);
    if (charts.isEmpty) return null;

    final chartId = charts.last.id;
    final planets = await db.getPlanetaryPositionsForChart(chartId);
    final cusps = await db.getHouseCuspsForChart(chartId);
    final dashas = await db.getDashaPeriodsForChart(chartId);

    final asc = chartJsonAscendant(charts.last);
    return CalculatedChart(
      planets: planets,
      cusps: cusps,
      dashas: dashas,
      ascendantLongitude: asc ?? cusps.first.longitude,
      ayanamsa: charts.last.chartJson['ayanamsa'] as double? ?? 0,
    );
  }

  static double? chartJsonAscendant(Chart chart) {
    final v = chart.chartJson['ascendant'];
    return v is num ? v.toDouble() : null;
  }

  // ---------------------------------------------------------------------------
  // KP helpers (also used by UI)
  // ---------------------------------------------------------------------------

  static double _normalize(double lon) => (lon % 360 + 360) % 360;

  static int nakshatraIndex(double longitude) =>
      (_normalize(longitude) / _nakSpan).floor() % 27;

  static String signName(double longitude) =>
      _signs[(_normalize(longitude) / 30).floor() % 12];

  /// Star (nakshatra) lord for a longitude.
  static String starLordFor(double longitude) =>
      _vimPlanets[nakshatraIndex(longitude) % 9];

  /// KP sub-lord: each nakshatra is divided into 9 parts proportional to
  /// Vimshottari dasha periods, starting from the nakshatra's star lord.
  static String subLordFor(double longitude) {
    final lon = _normalize(longitude);
    final nakIndex = nakshatraIndex(lon);
    final remainder = lon - nakIndex * _nakSpan;
    final start = nakIndex % 9;

    var acc = 0.0;
    for (var i = 0; i < 9; i++) {
      final idx = (start + i) % 9;
      final partSpan = _nakSpan * _vimYears[idx] / 120;
      if (remainder < acc + partSpan) return _vimPlanets[idx];
      acc += partSpan;
    }
    return _vimPlanets[(start + 8) % 9];
  }

  /// e.g. "14° 23' Aries"
  static String formatPosition(double longitude) {
    final lon = _normalize(longitude);
    final degrees = (lon % 30).floor();
    final minutes = (((lon % 30) - degrees) * 60).floor();
    return "$degrees° ${minutes}' ${signName(lon)}";
  }
}
