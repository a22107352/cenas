import 'package:path/path.dart';
import 'package:prjectcm/data/sns_datasource.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:prjectcm/models/waiting_time.dart';
import 'package:sqflite/sqflite.dart';
import '../models/evaluation_report.dart';

class SqfliteSnsDataSource extends SnsDataSource {
  Database? _database;



  Future<void> init() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'database.db'),
      onCreate: (db, version) async {
        await db.execute(
            '''CREATE TABLE hospital (
    id INTEGER,
    name TEXT PRIMARY KEY,
    address TEXT,
    phoneNumber INTEGER,
    email TEXT,
    longitude REAL,
    latitude REAL,
    district TEXT,
    hasEmergency INTEGER
  )'''
        );
        await db.execute(
          'CREATE TABLE report('
              'nome TEXT PRIMARY KEY,'
              'score INTEGER,'
              'dataeHora TEXT,'
              'dataValida INTEGER,' // use 0/1 como boolean
              'notas TEXT,'
              'hospital TEXT' // para associar ao hospital
              ')',
        );
      },
      version: 1,
    );
  }
  @override
  Future<List<Hospital>> getAllHospitals()async{
    if(_database == null){
      throw Exception("Fogot to initialize the database?");
    }
    List result = await _database!.rawQuery("SELECT * FROM hospital");
    return result.map((entry) => Hospital.fromDB(entry)).toList();
  }



  Future<void> saveHospitalsToDB(List<Hospital> onlineHospitais) async {
    if (_database == null) {
      throw Exception("Forgot to initialize the database?");
    }

    final batch = _database!.batch();

    for (var hospital in onlineHospitais) {
      batch.insert(
        'hospital',
        {
          'id': hospital.id,
          'name': hospital.name,
          'address': hospital.address,
          'phoneNumber': hospital.phoneNumber,
          'email': hospital.email,
          'longitude': hospital.longitude,
          'latitude': hospital.latitude,
          'district': hospital.district,
          'hasEmergency': hospital.hasEmergency ? 1 : 0, // <-- FIXED
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

    }

    await batch.commit(noResult: true);
  }
  @override
  Future<void> insertReport(EvaluationReport report) async {
    if (_database == null) {
      throw Exception("Database not initialized.");
    }

    await _database!.insert(
      'report',
      {
        'nome': report.hospital,
        'score': report.score,
        'dataeHora': report.dataeHora.toIso8601String(),
        'dataValida': report.dataValida ? 1 : 0,
        'notas': report.notas,
        'hospital': report.hospital,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  Future<List<EvaluationReport>> getAvaliacoes(String hospitalName) async {
    if (_database == null) {
      throw Exception("Database not initialized.");
    }

    final List<Map<String, dynamic>> maps = await _database!.query(
      'report',
      where: 'hospital = ?',
      whereArgs: [hospitalName],
    );

    return maps.map((map) {
      return EvaluationReport(
        map['hospital'],
        map['score'],
        DateTime.parse(map['dataeHora']),
        map['notas'],
        map['dataValida'] == 1,
      );
    }).toList();
  }

  Future<void> insertHospitals(List<Hospital> hospitals) async {
    if (_database == null) {
      throw Exception("Forgot to initialize the database?");
    }

    final batch = _database!.batch();

    for (var hospital in hospitals) {
      batch.insert(
        'hospital',
        {
          'id': hospital.id.toString(),
          'name': hospital.name.toString(),
          'address': hospital.address.toString(),
          'phoneNumber': hospital.phoneNumber.toString(),
          'email': hospital.email.toString(),
          'longitude': hospital.longitude.toString(),
          'latitude': hospital.latitude.toString(),
          'district': hospital.district.toString(),
          'hasEmergency': hospital.hasEmergency.toString(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }
  @override
  Future<void> attachEvaluation(int hospitalId, EvaluationReport report) async {
    if (_database == null) {
      throw Exception("Database not initialized.");
    }

    await _database!.insert(
      'report',
      {
        'nome': report.hospital,
        'score': report.score,
        'dataeHora': report.dataeHora.toIso8601String(),
        'dataValida': report.dataValida ? 1 : 0,
        'notas': report.notas,
        'hospital': report.hospital,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<Hospital> getHospitalDetailById(int hospitalId) async {
    if (_database == null) {
      throw Exception("Database not initialized.");
    }

    final List<Map<String, dynamic>> maps = await _database!.query(
      'hospital',
      where: 'id = ?',
      whereArgs: [hospitalId],
    );

    if (maps.isNotEmpty) {
      return Hospital.fromDB(maps.first);
    } else {
      throw Exception("Hospital not found with ID $hospitalId");
    }
  }

  @override
  Future<List<Hospital>> getHospitalsByName(String name) async {
    if (_database == null) {
      throw Exception("Database not initialized.");
    }

    final List<Map<String, dynamic>> maps = await _database!.query(
      'hospital',
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
    );

    return maps.map((map) => Hospital.fromDB(map)).toList();
  }

  @override
  Future<void> insertHospital(Hospital hospital) async {
    if (_database == null) {
      throw Exception("Database not initialized.");
    }

    await _database!.insert(
      'hospital',
      {
        'id': hospital.id,
        'name': hospital.name,
        'address': hospital.address,
        'phoneNumber': hospital.phoneNumber,
        'email': hospital.email,
        'longitude': hospital.longitude,
        'latitude': hospital.latitude,
        'district': hospital.district,
        'hasEmergency': hospital.hasEmergency,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

// This method is optional unless you're planning to use waiting times
  @override
  Future<List<WaitingTime>> getHospitalWaitingTimes(int hospitalId) async {
    // Currently, there's no table to store waiting times, so return an empty list or throw
    return []; // or throw UnimplementedError();
  }

  
}