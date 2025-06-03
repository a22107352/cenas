import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:prjectcm/data/sns_datasource.dart';
import 'package:prjectcm/data/sqflite_sns_datasource.dart';
import 'package:prjectcm/models/evaluation_report.dart';
import '../connectivity_module.dart';
import '../models/hospital.dart';
import '../models/waiting_time.dart';
import 'http_sns_datasource.dart';

class HospitalRepository implements SnsDataSource {
  final HttpSnsDataSource remote;
  final SqfliteSnsDataSource local;
  final ConnectivityModule connectivityModule;

  HospitalRepository({
    required this.remote,
    required this.local,
    required this.connectivityModule,
  });

  Future<bool> _isOnline() async {
    final connectivityResult = await connectivityModule.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  Future<void> insertHospital(Hospital hospital) async {
    await local.insertHospital(hospital);
  }
  Future<void> insertReport(Hospital hospital, EvaluationReport report) async {
    // Assegura que a avaliação está ligada ao hospital
    report.hospital = hospital.name;

    // Salva no banco
    await local.insertReport(report);

    // (Opcional) Atualiza a lista de avaliações desse hospital, se usar cache
    await attachEvaluation(hospital.id, report);
  }
  Future<List<EvaluationReport>> getAvaliacoes(String hospitalName) async {
    return await local.getAvaliacoes(hospitalName);
  }

  @override
  Future<List<Hospital>> getAllHospitals() async {
    try {
      if (await _isOnline()) {
        final hospitals = await remote.getAllHospitals();
        await local.saveHospitalsToDB(hospitals);
        print("Reading hospitals from remote and saving locally.");
        return hospitals;
      }
    } catch (e) {
      print("Erro remoto: $e");
    }

    print("Reading hospitals from local DB");
    return await local.getAllHospitals();
  }


  @override
  Future<List<Hospital>> getHospitalsByName(String name) async {
    try {
      if (await _isOnline()) {
        final hospitals = await remote.getHospitalsByName(name);
        await local.saveHospitalsToDB(hospitals);
        return hospitals;
      }
    } catch (e) {
      print("Erro ao buscar hospitais remotamente: $e");
    }

    // Fallback para local mesmo se houve erro
    return await local.getHospitalsByName(name);
  }


  @override
  Future<Hospital> getHospitalDetailById(int hospitalId) async {
    if (await _isOnline()) {
      final hospital = await remote.getHospitalDetailById(hospitalId);
      await local.insertHospital(hospital);
      return hospital;
    } else {
      return await local.getHospitalDetailById(hospitalId);
    }
  }

  @override
  Future<void> attachEvaluation(int hospitalId, EvaluationReport report) async {
    await local.attachEvaluation(hospitalId, report);
  }

  @override
  Future<List<WaitingTime>> getHospitalWaitingTimes(int hospitalId) {
    // TODO: implement getHospitalWaitingTimes
    throw UnimplementedError();
  }
  
  //Future<List<WaitingTime>> getHospitalWaitingTimes(int hospitalId) async {
    //if (await _isOnline()) {
      //final times = await remote.getHospitalWaitingTimes(hospitalId);
      //await local.getHospitalWaitingTimes(hospitalId, times);
      //return times;
    //} else {
      //return await local.getHospitalWaitingTimes(hospitalId);
    //}
  //}


}
