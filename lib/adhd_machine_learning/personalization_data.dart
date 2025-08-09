import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:sqflite_sqlcipher/sqflite.dart';

class PersonalizationDbHelper {
  static const _databaseName = "personalization.db";
  static const _databaseVersion = 1;

  static const table = 'MlAdjustments';
  static const columnId = 'id';
  static const columnFeatureText = 'feature_text';
  static const columnAdjustmentValue = 'adjustment_value';
  static const columnUpdateCount = 'update_count';

  PersonalizationDbHelper._privateConstructor();
  static final PersonalizationDbHelper instance = PersonalizationDbHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String dbPath = await getDatabasesPath();
    String dbFilePath = path.join(dbPath, _databaseName);
    return await openDatabase(dbFilePath,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnFeatureText TEXT NOT NULL UNIQUE,
            $columnAdjustmentValue REAL NOT NULL,
            $columnUpdateCount INTEGER NOT NULL
          )
          ''');
  }

  //===================================================================
  // CRUD Methods
  //===================================================================

  /// CREATE: Inserts a new row into the database.
  /// Returns the id of the new row.
  Future<int> insert(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert(table, row);
  }

  /// READ (Single Row): Queries for a single feature by its text.
  /// Returns the row as a map, or null if not found.
  Future<Map<String, dynamic>?> queryFeature(String featureText) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
        table,
        where: '$columnFeatureText = ?',
        whereArgs: [featureText]
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  /// READ (Multiple Rows): The primary method for getting adjustments for prediction.
  /// Takes a set of features and returns a map of {feature: adjustmentValue}.
  Future<Map<String, double>> getAdjustmentsForFeatures(Set<String> features) async {
    final db = await instance.database;
    final Map<String, double> adjustments = {};
    if (features.isEmpty) return adjustments;

    final placeholders = List.filled(features.length, '?').join(',');
    final List<Map<String, dynamic>> maps = await db.query(
      table,
      where: '$columnFeatureText IN ($placeholders)',
      whereArgs: features.toList(),
    );

    for (final map in maps) {
      adjustments[map[columnFeatureText]] = map[columnAdjustmentValue];
    }
    return adjustments;
  }

  /// READ (All Rows): Queries all rows in the table.
  /// Useful for debugging or displaying all adjustments.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    final db = await instance.database;
    return await db.query(table);
  }

  /// UPDATE: Updates an existing row.
  /// The row map must contain the primary key.
  /// Returns the number of rows affected.
  Future<int> update(Map<String, dynamic> row) async {
    final db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  /// DELETE (Single Row): Deletes the specified row by its feature text.
  /// Returns the number of rows affected.
  Future<int> delete(String featureText) async {
    final db = await instance.database;
    return await db.delete(table, where: '$columnFeatureText = ?', whereArgs: [featureText]);
  }

  /// DELETE (All Rows): Deletes all rows in the table.
  /// Perfect for a "Reset Personalization" feature.
  /// Returns the number of rows deleted.
  Future<int> deleteAll() async {
    final db = await instance.database;
    return await db.delete(table);
  }

  //===================================================================
  // Convenience Methods (Primary API for your services)
  //===================================================================

  /// "Upsert" Method: The most important method for the learning process.
  /// It either updates an existing feature's adjustment or inserts a new one.
  Future<void> updateAdjustment({required String feature, required double adjustment}) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      final List<Map> maps = await txn.query(table,
          where: '$columnFeatureText = ?',
          whereArgs: [feature]);

      if (maps.isNotEmpty) {
        // Feature exists, UPDATE it
        double currentValue = maps.first[columnAdjustmentValue];
        int currentCount = maps.first[columnUpdateCount];
        await txn.update(table,
            {
              columnAdjustmentValue: currentValue + adjustment,
              columnUpdateCount: currentCount + 1,
            },
            where: '$columnFeatureText = ?',
            whereArgs: [feature]);
      } else {
        // Feature is new, INSERT it
        await txn.insert(table, {
          columnFeatureText: feature,
          columnAdjustmentValue: adjustment,
          columnUpdateCount: 1,
        });
      }
    });
  }
}
