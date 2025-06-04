import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prjectcm/data/HospitalRepository.dart';
import 'package:provider/provider.dart';
import '../connectivity_module.dart';
import '../data/http_sns_datasource.dart';
import '../data/sqflite_sns_datasource.dart';
import '../models/hospital.dart';
import 'Pages.dart';
import 'hospital_detail_page.dart';


class Lista extends StatefulWidget {
  Lista({super.key});

  @override
  State<Lista> createState() => _ListaState();
}

class _ListaState extends State<Lista> {
  Future<List<Hospital>>?
  _futureHospitais;

  @override
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
      _futureHospitais = hospitalRepository.getAllHospitals();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          pages[1].title,
          style: TextStyle(fontFamily: "NotoSans"),
        ),
      ),
      body: _futureHospitais == null
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Hospital>>(
        
        future: _futureHospitais,
        builder: (context, snapshot) {
          print("Snapshot data: ${snapshot.data}");
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhum hospital encontrado.'));
          }

          List<Hospital> hospitais = snapshot.data!;

          return Column(
            children: [
              SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  key: const Key("list-view"),
                  itemBuilder: (_, index) => Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blueAccent,
                        width: 5.0,
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: ListTile(
                      title: Text(
                        hospitais[index].name,
                        style: TextStyle(fontFamily: "NotoSans"),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HospitalDetailPage(
                            hospitalid: hospitais[index].id,
                          ),
                        ),
                      ),
                    ),
                  ),
                  separatorBuilder: (_, index) => SizedBox(height: 10),
                  itemCount: hospitais.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
