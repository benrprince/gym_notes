import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../model/exercise.dart';
import '../model/entry.dart';
import '../model/set.dart' as setModel;

class GymNotesDatabase {
  static final GymNotesDatabase instance = GymNotesDatabase._init();

  static Database? _database;

  GymNotesDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gym_notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final textTypeNullable = 'TEXT';
    final boolType = 'BOOLEAN NOT NULL';
    final integerType = 'INTEGER NOT NULL';
    final integerTypeNullable = 'INTEGER';

    await db.execute('''
      CREATE TABLE $tableExercise (
        ${ExerciseFields.exerciseId} $idType,
        ${ExerciseFields.name} $textType,
        ${ExerciseFields.pr} $integerType,
        ${ExerciseFields.category} $textType,
        ${ExerciseFields.prMetric} $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableEntry (
        ${EntryFields.entryId} $idType,
        ${EntryFields.exerciseId} $integerType,
        ${EntryFields.date} $textType,
        ${EntryFields.sets} $integerType,
        ${EntryFields.maxWeight} $integerType,
        ${EntryFields.totalVolume} $integerType
      )
    ''');

    await db.execute('''
      CREATE TABLE ${setModel.tableSet} (
        ${setModel.SetFields.setId} $idType,
        ${setModel.SetFields.entryId} $integerType,
        ${setModel.SetFields.weight} $integerType,
        ${setModel.SetFields.reps} $integerType,
        ${setModel.SetFields.time} $integerType
      )
    ''');
  }

  // Create Functions ****************************************
  Future<Exercise> createExercise(Exercise exercise) async {
    final db = await instance.database;

    final id = await db.insert(tableExercise, exercise.toJson());
    return exercise.copy(exerciseId: id);
  }

  Future<Entry> createEntry(Entry entry) async {
    final db = await instance.database;

    final id = await db.insert(tableEntry, entry.toJson());
    return entry.copy(entryId: id);
  }

  Future<setModel.Set> createSet(setModel.Set set) async {
    final db = await instance.database;

    final id = await db.insert(setModel.tableSet, set.toJson());
    return set.copy(setId: id);
  }

  // Read Functions ****************************************
  Future<Exercise> readExercise(int id) async {
    final db = await instance.database;

    final maps = await db.query(tableExercise,
        columns: ExerciseFields.values,
        where: '${ExerciseFields.exerciseId} = ?',
        whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Exercise.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Exercise>> readExercises(String category) async {
    if (category == "All") {
      return readAllExercises();
    }

    final db = await instance.database;

    final maps = await db.query(tableExercise,
        columns: ExerciseFields.values,
        where: '${ExerciseFields.category} = ?',
        whereArgs: [category]);

    return maps.map((json) => Exercise.fromJson(json)).toList();
  }

  Future<Entry> readEntry(int id) async {
    final db = await instance.database;

    final maps = await db.query(tableEntry,
        columns: EntryFields.values,
        where: '${EntryFields.entryId} = ?',
        whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Entry.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Entry>> readExerciseEntries(int? id) async {
    final db = await instance.database;

    final maps = await db.query(tableEntry,
        columns: EntryFields.values,
        where: '${EntryFields.exerciseId} = ?',
        whereArgs: [id]);

    if (maps.isNotEmpty) {
      return maps.map((json) => Entry.fromJson(json)).toList();
    } else {
      return List.empty();
    }
  }

  Future<setModel.Set> readSet(int id) async {
    final db = await instance.database;

    final maps = await db.query(setModel.tableSet,
        columns: setModel.SetFields.values,
        where: '${setModel.SetFields.setId} = ?',
        whereArgs: [id]);

    if (maps.isNotEmpty) {
      return setModel.Set.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<setModel.Set>> readEntrySets(int? id) async {
    final db = await instance.database;

    final maps = await db.query(setModel.tableSet,
        columns: setModel.SetFields.values,
        where: '${setModel.SetFields.entryId} = ?',
        whereArgs: [id]);

    if (maps.isNotEmpty) {
      return maps.map((json) => setModel.Set.fromJson(json)).toList();
    } else {
      return List.empty();
    }
  }

  // ReadAll Functions ****************************************
  Future<List<Exercise>> readAllExercises() async {
    final db = await instance.database;
    final result = await db.query(tableExercise);

    return result.map((json) => Exercise.fromJson(json)).toList();
  }

  Future<List<Entry>> readAllEntries() async {
    final db = await instance.database;
    final result = await db.query(tableEntry);

    return result.map((json) => Entry.fromJson(json)).toList();
  }

  Future<List<setModel.Set>> readAllSets() async {
    final db = await instance.database;
    final result = await db.query(setModel.tableSet);

    return result.map((json) => setModel.Set.fromJson(json)).toList();
  }

  // Update Functions ****************************************
  Future<int> updateExercise(Exercise exercise) async {
    final db = await instance.database;

    return db.update(tableExercise, exercise.toJson(),
        where: '${ExerciseFields.exerciseId} = ?',
        whereArgs: [exercise.exerciseId]);
  }

  Future<int> updateExercisePR(Exercise exercise, int newPr) async {
    final db = await instance.database;
    Exercise updatedExercise = Exercise(
        exerciseId: exercise.exerciseId,
        name: exercise.name,
        pr: newPr,
        category: exercise.category,
        prMetric: exercise.prMetric);

    return db.update(tableExercise, updatedExercise.toJson(),
        where: '${ExerciseFields.exerciseId} = ?',
        whereArgs: [exercise.exerciseId]);
  }

  Future<int> updateEntry(Entry entry) async {
    final db = await instance.database;

    return db.update(tableEntry, entry.toJson(),
        where: '${EntryFields.entryId} = ?', whereArgs: [entry.entryId]);
  }

  Future<int> updateSet(setModel.Set set) async {
    final db = await instance.database;

    return db.update(setModel.tableSet, set.toJson(),
        where: '${setModel.SetFields.setId} = ?', whereArgs: [set.setId]);
  }

  // Delete Functions ****************************************
  Future<int> deleteExercise(int? id) async {
    final db = await instance.database;

    return await db.delete(
      tableExercise,
      where: '${ExerciseFields.exerciseId} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteEntry(int? id) async {
    final db = await instance.database;

    return await db.delete(
      tableEntry,
      where: '${EntryFields.entryId} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteSet(int? id) async {
    final db = await instance.database;

    return await db.delete(
      setModel.tableSet,
      where: '${setModel.SetFields.setId} = ?',
      whereArgs: [id],
    );
  }

  // Close DB ************************************
  Future close() async {
    final db = await instance.database;

    db.close();
  }

  // Be careful with this because it will smoke the whole DB
  Future deleteDb() async {
    deleteDatabase('gym_notes.db');
  }
}
