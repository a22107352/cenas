import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prjectcm/data/HospitalRepository.dart';
import 'package:provider/provider.dart';
import 'package:prjectcm/models/hospital.dart';
import '../connectivity_module.dart';
import '../data/http_sns_datasource.dart';
import '../data/sqflite_sns_datasource.dart';
import '../models/evaluation_report.dart';


class HospitalDetailPage extends StatefulWidget {
  final int hospitalid;

  const HospitalDetailPage ({super.key, required this.hospitalid});

  @override
  State<HospitalDetailPage> createState() => _HospitalDetailPageState();
}

class _HospitalDetailPageState extends State<HospitalDetailPage> {
  late HospitalRepository _futureHospitais;

  void initState() {
    super.initState();
    _loadHospitais();
  }
  Future<void> _loadHospitais() async {
    final local = context.read<SqfliteSnsDataSource>();
    final remote = context.read<HttpSnsDataSource>();
    final connectivity = context.read<ConnectivityModule>();

    final hospitalRepository = HospitalRepository(
      local: local,
      remote: remote,
      connectivityModule: connectivity,
    );

    setState(() {
      _futureHospitais = hospitalRepository;
    });
  }

  Hospital? _hospital;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Detalhes do hospital", style: TextStyle(fontFamily: "NotoSans")),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: FutureBuilder<Hospital>(
          future: _futureHospitais.getHospitalDetailById(widget.hospitalid),
          builder: (context, hospitalSnapshot) {
            if (hospitalSnapshot.connectionState != ConnectionState.done) {
              return Center(child: CircularProgressIndicator());
            } else if (hospitalSnapshot.hasError) {
              return Center(child: Text('Erro ao carregar hospital: ${hospitalSnapshot.error}'));
            } else if (!hospitalSnapshot.hasData) {
              return Center(child: Text("Hospital não encontrado."));
            }

            _hospital = hospitalSnapshot.data!;

            return FutureBuilder<List<EvaluationReport>>(
              future: Future.value(_hospital!.getReports),
              builder: (context, evalSnapshot) {
                if (evalSnapshot.connectionState != ConnectionState.done) {
                  return Center(child: CircularProgressIndicator());
                } else if (evalSnapshot.hasError) {
                  return Center(child: Text('Erro ao carregar avaliações: ${evalSnapshot.error}'));
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _DetalheHospital(_hospital!),
                      SizedBox(height: 10),
                      DetalheAvalicoes(evalSnapshot.data ?? []),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }


  Widget buildHospitalDetail(avalicao) {
    if (_hospital == null) {
      return Center(child: Text("Hospital data is still loading..."));
    }

    return Column(
            children: [
              _DetalheHospital(_hospital!),
              SizedBox(height: 10,),
              DetalheAvalicoes(avalicao),
            ],
          );
  }

  Container DetalheAvalicoes(List<EvaluationReport>? avalicao) {
    List<Widget> avaliacoesWidgets = [];

    if (avalicao != null && avalicao.isNotEmpty) {
      for (var av in avalicao) {
        avaliacoesWidgets.addAll([
          Text("${DateFormat('dd/MM/yyyy HH:mm').format(av.dataeHora)}", style: TextStyle(fontFamily: "NotoSans")),
          Text("Score: ${av.score}", style: TextStyle(fontFamily: "NotoSans")),
          Text(av.notas.isNotEmpty?"${av.notas}":"No comments", style: TextStyle(fontFamily: "NotoSans")),
          Divider(), // Optional visual separator
        ]);
      }
    } else {
      avaliacoesWidgets.add(
        Text("Nenhuma avaliação disponível.", style: TextStyle(fontFamily: "NotoSans", color: Colors.grey)),
      );
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.blueAccent,
          width: 4.0,
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Avaliações", style: TextStyle(fontFamily: "NotoSans", fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          ...avaliacoesWidgets,
        ],
      ),
    );
  }

  Container _DetalheHospital(Hospital hospital) {
    return Container(
            padding: EdgeInsets.all(16), // Space inside the box
            decoration: BoxDecoration(
              color: Colors.white, // Optional: background color
              border: Border.all(
                color: Colors.blueAccent, // Border color
                width: 4.0, // Border width
              ),
              borderRadius: BorderRadius.circular(50), // Optional: rounded corners
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Prevents full height stretch
              crossAxisAlignment: CrossAxisAlignment.center, // Align text to left
              children: [
                Text(hospital.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,fontFamily: "NotoSans"),),
                SizedBox(height: 8),
                Text(hospital.address,style: TextStyle(fontFamily: "NotoSans"),),
                Text(hospital.district,style: TextStyle(fontFamily: "NotoSans"),),
                Text("${hospital.email}",style: TextStyle(fontFamily: "NotoSans"),),
                Text("Emergência: ${hospital.hasEmergency == true ? 'Sim' : 'Não'}",style: TextStyle(fontFamily: "NotoSans"),),
                Text("${hospital.phoneNumber}",style: TextStyle(fontFamily: "NotoSans"),),
                Text("Média de avaliações: Indisponivel",style: TextStyle(fontFamily: "NotoSans"),),
              ],
            ),
          );
  }
}


