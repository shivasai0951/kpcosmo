import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/birth_profile.dart';
import '../models/chart.dart';
import '../models/planetary_position.dart';
import '../models/house_cusp.dart';
import '../models/dasha_period.dart';
import '../models/event_analysis.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'kpcosmo.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create birth_profiles table
    await db.execute('''
      CREATE TABLE birth_profiles (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        date_of_birth TEXT NOT NULL,
        time_of_birth TEXT NOT NULL,
        birthplace_name TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        timezone_id TEXT NOT NULL,
        utc_birth_timestamp INTEGER NOT NULL,
        birth_time_precision TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create charts table
    await db.execute('''
      CREATE TABLE charts (
        id TEXT PRIMARY KEY,
        profile_id TEXT NOT NULL,
        ayanamsa_setting TEXT NOT NULL,
        house_system TEXT NOT NULL,
        node_type TEXT NOT NULL,
        calculation_version TEXT NOT NULL,
        ephemeris_version TEXT NOT NULL,
        chart_json TEXT NOT NULL,
        calculated_at TEXT NOT NULL,
        FOREIGN KEY (profile_id) REFERENCES birth_profiles (id)
      )
    ''');

    // Create planetary_positions table
    await db.execute('''
      CREATE TABLE planetary_positions (
        id TEXT PRIMARY KEY,
        chart_id TEXT NOT NULL,
        planet_name TEXT NOT NULL,
        absolute_longitude REAL NOT NULL,
        sign TEXT NOT NULL,
        sign_degree REAL NOT NULL,
        nakshatra TEXT NOT NULL,
        pada INTEGER NOT NULL,
        star_lord TEXT NOT NULL,
        sub_lord TEXT NOT NULL,
        house_number INTEGER NOT NULL,
        retrograde INTEGER NOT NULL,
        FOREIGN KEY (chart_id) REFERENCES charts (id)
      )
    ''');

    // Create house_cusps table
    await db.execute('''
      CREATE TABLE house_cusps (
        id TEXT PRIMARY KEY,
        chart_id TEXT NOT NULL,
        house_number INTEGER NOT NULL,
        longitude REAL NOT NULL,
        sign_lord TEXT NOT NULL,
        star_lord TEXT NOT NULL,
        sub_lord TEXT NOT NULL,
        FOREIGN KEY (chart_id) REFERENCES charts (id)
      )
    ''');

    // Create dasha_periods table
    await db.execute('''
      CREATE TABLE dasha_periods (
        id TEXT PRIMARY KEY,
        chart_id TEXT NOT NULL,
        parent_period_id TEXT,
        level TEXT NOT NULL,
        planet TEXT NOT NULL,
        start_timestamp INTEGER NOT NULL,
        end_timestamp INTEGER NOT NULL,
        FOREIGN KEY (chart_id) REFERENCES charts (id)
      )
    ''');

    // Create event_analyses table
    await db.execute('''
      CREATE TABLE event_analyses (
        id TEXT PRIMARY KEY,
        chart_id TEXT NOT NULL,
        event_type TEXT NOT NULL,
        rule_set_version TEXT NOT NULL,
        result_status TEXT NOT NULL,
        supporting_houses_json TEXT NOT NULL,
        opposing_houses_json TEXT NOT NULL,
        explanation_json TEXT NOT NULL,
        candidate_periods_json TEXT NOT NULL,
        calculated_at TEXT NOT NULL,
        FOREIGN KEY (chart_id) REFERENCES charts (id)
      )
    ''');

    // Create index for faster searches
    await db.execute('''
      CREATE INDEX idx_charts_profile_id ON charts (profile_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_planetary_positions_chart_id ON planetary_positions (chart_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_house_cusps_chart_id ON house_cusps (chart_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_dasha_periods_chart_id ON dasha_periods (chart_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_event_analyses_chart_id ON event_analyses (chart_id)
    ''');
  }

  // Birth profiles operations
  Future<int> insertBirthProfile(BirthProfile profile) async {
    final db = await database;
    return await db.insert('birth_profiles', profile.toMap());
  }

  Future<BirthProfile?> getBirthProfile(String id) async {
    final db = await database;
    final result = await db.query(
      'birth_profiles',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return BirthProfile.fromMap(result.first);
  }

  Future<List<BirthProfile>> getAllBirthProfiles() async {
    final db = await database;
    final result = await db.query('birth_profiles');
    return result.map((map) => BirthProfile.fromMap(map)).toList();
  }

  Future<int> updateBirthProfile(BirthProfile profile) async {
    final db = await database;
    return await db.update(
      'birth_profiles',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  Future<int> deleteBirthProfile(String id) async {
    final db = await database;
    return await db.delete(
      'birth_profiles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Charts operations
  Future<int> insertChart(Chart chart) async {
    final db = await database;
    return await db.insert('charts', chart.toMap());
  }

  Future<Chart?> getChart(String id) async {
    final db = await database;
    final result = await db.query(
      'charts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Chart.fromMap(result.first);
  }

  Future<List<Chart>> getChartsForProfile(String profileId) async {
    final db = await database;
    final result = await db.query(
      'charts',
      where: 'profile_id = ?',
      whereArgs: [profileId],
    );
    return result.map((map) => Chart.fromMap(map)).toList();
  }

  // Planetary positions operations
  Future<int> insertPlanetaryPosition(PlanetaryPosition position) async {
    final db = await database;
    return await db.insert('planetary_positions', position.toMap());
  }

  Future<List<PlanetaryPosition>> getPlanetaryPositionsForChart(String chartId) async {
    final db = await database;
    final result = await db.query(
      'planetary_positions',
      where: 'chart_id = ?',
      whereArgs: [chartId],
      orderBy: 'planet_name',
    );
    return result.map((map) => PlanetaryPosition.fromMap(map)).toList();
  }

  // House cusps operations
  Future<int> insertHouseCusp(HouseCusp cusp) async {
    final db = await database;
    return await db.insert('house_cusps', cusp.toMap());
  }

  Future<List<HouseCusp>> getHouseCuspsForChart(String chartId) async {
    final db = await database;
    final result = await db.query(
      'house_cusps',
      where: 'chart_id = ?',
      whereArgs: [chartId],
      orderBy: 'house_number',
    );
    return result.map((map) => HouseCusp.fromMap(map)).toList();
  }

  // Dasha periods operations
  Future<int> insertDashaPeriod(DashaPeriod period) async {
    final db = await database;
    return await db.insert('dasha_periods', period.toMap());
  }

  Future<List<DashaPeriod>> getDashaPeriodsForChart(String chartId) async {
    final db = await database;
    final result = await db.query(
      'dasha_periods',
      where: 'chart_id = ?',
      whereArgs: [chartId],
      orderBy: 'start_timestamp',
    );
    return result.map((map) => DashaPeriod.fromMap(map)).toList();
  }

  // Event analyses operations
  Future<EventAnalysis?> getEventAnalysis(String chartId, String eventType) async {
    final db = await database;
    final result = await db.query(
      'event_analyses',
      where: 'chart_id = ? AND event_type = ?',
      whereArgs: [chartId, eventType],
    );
    if (result.isEmpty) return null;
    return EventAnalysis.fromMap(result.first);
  }

  // Backup and restore operations
  // Tables are ordered parent-first so inserts respect foreign keys;
  // deletion iterates in reverse (children before parents).
  static const List<String> _tables = [
    'birth_profiles',
    'charts',
    'planetary_positions',
    'house_cusps',
    'dasha_periods',
    'event_analyses',
  ];

  Future<String> exportDatabase() async {
    final db = await database;
    final Map<String, dynamic> data = {};

    for (final table in _tables) {
      data[table] = await db.query(table);
    }

    return json.encode(data);
  }

  Future<void> importDatabase(String jsonData) async {
    final Map<String, dynamic> data = json.decode(jsonData);
    final db = await database;

    await db.transaction((txn) async {
      // Clear existing data, children before parents
      for (final table in _tables.reversed) {
        await txn.delete(table);
      }

      // Import all rows, parents before children
      for (final table in _tables) {
        final rows = data[table] as List? ?? const [];
        for (final row in rows) {
          await txn.insert(table, Map<String, dynamic>.from(row as Map));
        }
      }
    });
  }

  /// Deletes a chart and all its dependent rows (positions, cusps,
  /// dashas, analyses). chartId is the charts.id value.
  Future<void> deleteChartCascade(String chartId) async {
    final db = await database;
    await db.delete('event_analyses', where: 'chart_id = ?', whereArgs: [chartId]);
    await db.delete('dasha_periods', where: 'chart_id = ?', whereArgs: [chartId]);
    await db.delete('house_cusps', where: 'chart_id = ?', whereArgs: [chartId]);
    await db.delete('planetary_positions', where: 'chart_id = ?', whereArgs: [chartId]);
    await db.delete('charts', where: 'id = ?', whereArgs: [chartId]);
  }

  // Clear all data
  Future<void> clearAllData() async {
    final db = await database;
    for (final table in _tables.reversed) {
      await db.delete(table);
    }
  }

  // Initialize offline city database
  Future<void> initializeCityDatabase() async {
    // This would load the bundled offline city database with coordinates and timezone info
    // For now, just a placeholder
  }
}
