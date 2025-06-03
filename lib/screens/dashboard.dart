import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/Nascimento.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<Dashboard> {
  String instituicaoSelecionada = 'Todos';
  String dataSelecionada = 'Todas';
  List<Nascimento> dados = [];
  bool dataValida = true;
  final _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    dados = gerarMock();
  }

  List<Nascimento> filtrarDados() {
    return dados.where((n) {
      final matchInst = instituicaoSelecionada == 'Todos' || n.instituicao == instituicaoSelecionada;
      final matchData = dataSelecionada == 'Todas' || n.data == dataSelecionada;
      return matchInst && matchData;
    }).toList();
  }

  List<String> getDatasUnicas() {
    final datas = dados.map((n) => n.data).toSet().toList();
    datas.sort();
    return ['Todas', ...datas];
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = filtrarDados();
    final masculino = filtrados.where((n) => n.sexo == 'M').length;
    final feminino = filtrados.where((n) => n.sexo == 'F').length;

    return Scaffold(
      appBar: AppBar(title: Text("Nascimentos")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              DropdownButton<String>(
                value: instituicaoSelecionada,
                items: ['Todos', 'Hospital X', 'Hospital Y']
                    .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                    .toList(),
                onChanged: (value) {
                  setState(() => instituicaoSelecionada = value!);
                },
              ),
              SizedBox(width: 20),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Data (dd/MM/yyyy)*',
                    labelStyle: TextStyle(fontSize: 16, fontFamily: "NotoSans"),
                    errorText: dataValida ? null : 'Data inválida',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (text) {
                    setState(() {
                      try {
                        final parsed = DateFormat("dd/MM/yyyy").parseStrict(text);
                        dataSelecionada = DateFormat("yyyy-MM-dd").format(parsed);
                        dataValida = true;
                      } catch (e) {
                        dataValida = false;
                        dataSelecionada = 'Todas';
                      }
                    });
                  },
                ),
              ),
              ElevatedButton(onPressed: (){showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text("Explicação"),
                  content: Text("Este dashboard será aplicado com a api api/birathnotice"),
                  actions: [
                    TextButton(
                      child: Text("OK"),
                      onPressed: () => Navigator.pop(context),

                    )
                  ],
                ),
              );}, child: Text("?"))
            ]),
            SizedBox(height: 20),
            Text("Total: ${filtrados.length} nascimentos",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Masculino: $masculino | Feminino: $feminino",
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Expanded(child: construirTabela(filtrados)),
          ],
        ),
      ),
    );
  }

  Widget construirTabela(List<Nascimento> dados) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(columns: [
        DataColumn(label: Text('Data')),
        DataColumn(label: Text('Sexo')),
        DataColumn(label: Text('Instituição')),
        DataColumn(label: Text('Parto')),
      ], rows: dados.map((n) {
        return DataRow(cells: [
          DataCell(Text(n.data)),
          DataCell(Text(n.sexo)),
          DataCell(Text(n.instituicao)),
          DataCell(Text(n.tipoParto)),
        ]);
      }).toList()),
    );
  }

  List<Nascimento> gerarMock() {
    return [
      Nascimento(data: "2025-04-22", sexo: "M", instituicao: "Hospital X", tipoParto: "Normal"),
      Nascimento(data: "2025-04-22", sexo: "F", instituicao: "Hospital Y", tipoParto: "Cesárea"),
      Nascimento(data: "2025-04-23", sexo: "M", instituicao: "Hospital X", tipoParto: "Normal"),
      Nascimento(data: "2025-04-23", sexo: "F", instituicao: "Hospital Y", tipoParto: "Cesárea"),
      Nascimento(data: "2025-04-23", sexo: "M", instituicao: "Hospital Y", tipoParto: "Normal"),
    ];
  }
}