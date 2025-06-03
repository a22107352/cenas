import 'dart:convert';
import 'package:prjectcm/data/sns_datasource.dart';
import 'package:prjectcm/models/waiting_time.dart';
import 'package:prjectcm/http/http_client.dart';
import '../models/evaluation_report.dart';
import '../models/hospital.dart';

class HttpSnsDataSource extends SnsDataSource {
  final HttpClient _client = HttpClient();
  List<Hospital> _hospitais =[];
  List<EvaluationReport> _avaliacoes=[];

  @override
  Future<List<Hospital>> getAllHospitals() async {
    final response = await _client.get(
      url: "https://servicos.min-saude.pt/pds/api/tems/institution",
      headers: {
        "Authorization": "Bearer VUhlT2tISVdGNmdiNEgwa3I4ZXZGZWloWHNQUXo4SktHYmVRYVR6OHpocz0="
      },
    );

    if (response.statusCode == 200) {
      final responseJSON = jsonDecode(response.body);
      _hospitais = (responseJSON["Result"] as List)
          .map((hospitalJSON) => Hospital.fromMap(hospitalJSON))
          .toList();
    } else {
      throw Exception("status code not 200");
    }

    return _hospitais;
  }

  Future<Hospital> getHospitalDetailById(int hospitalId) async{
    List<Hospital> hospitais = await getAllHospitals();

    for (var i = 0; i < hospitais.length; i++) {
      if(hospitais[i].id== hospitalId){
        return hospitais[i];
      }
    }
    throw Exception('Hospital with ID $hospitalId not found');
  }
  Future<List<EvaluationReport>> getAvaliacoes(String hospitalNome)async {
    return await _avaliacoes.where((a) => a.hospital == hospitalNome).toList();
  }
  void insertAvaliacoes(EvaluationReport EvaluationReport) {
    _avaliacoes.add(EvaluationReport);
  }
  Future<List<EvaluationReport>> getEvaluationReport(String hospital)async{
    List<EvaluationReport> EvaluationReportV = await getAvaliacoes(hospital);

    for (var i = 0; i < EvaluationReportV.length; i++) {
      if(EvaluationReportV[i].hospital== hospital){
        return EvaluationReportV;
      }
    }
    throw Exception('Hospital with ID $EvaluationReportV not found');

  }

  @override
  Future<void> attachEvaluation(int hospitalId, EvaluationReport report) async {
    // Ensure we have the latest list of hospitals
    if (_hospitais.isEmpty) {
      await getAllHospitals();
    }

    try {
      // Find the hospital by ID
      final hospital = _hospitais.firstWhere((h) => h.id == hospitalId);

      // Attach the evaluation to the hospital's report list
      hospital.reports.add(report);

      // Also keep a copy in the central _avaliacoes list (optional)
      _avaliacoes.add(report);
    } catch (e) {
      throw Exception('Hospital with ID $hospitalId not found');
    }
  }


  @override
  Future<List<WaitingTime>> getHospitalWaitingTimes(int hospitalId) {
    // TODO: implement getHospitalWaitingTimes
    throw UnimplementedError();
  }

  @override
  Future<List<Hospital>> getHospitalsByName(String name) async{
    final hospitals = await getAllHospitals();
    return hospitals.where((hospital) =>
        hospital.name.toLowerCase().contains(name.toLowerCase())
    ).toList();
  }

  @override
  Future<void> insertHospital(Hospital hospital) async {
    _hospitais.add(hospital);
  }

}
