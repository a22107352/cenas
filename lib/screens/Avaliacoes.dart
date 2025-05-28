import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prjectcm/data/HospitalRepository.dart';
import 'package:provider/provider.dart';
import 'package:testable_form_field/testable_form_field.dart';
import '../data/http_sns_datasource.dart';
import '../data/sqflite_sns_datasource.dart';
import '../models/evaluation_report.dart';
import '../models/hospital.dart';
import 'Pages.dart';

class Avaliacoes extends StatefulWidget {
  Avaliacoes({super.key});
  @override
  State<Avaliacoes> createState() => _AvaliacoesState();
}

class _AvaliacoesState extends State<Avaliacoes> {

  late Future<List<Hospital>> _futureHospitais;

  @override
  void initState() {
    super.initState();
    _futureHospitais = context.read<HospitalRepository>().getAllHospitals();
  }
  Hospital? _selectedHospital = null;
  int? score;
  final List<int> _scoreoptions = [1, 2, 3, 4, 5];
  EvaluationReport? EvaluationReportV = EvaluationReport('', 0, DateTime.now(), '', false);




  @override
  Widget build(BuildContext context) {
    debugPrint("passei aqui");

    return Scaffold(
      appBar: AppBar(
        title: Text(pages[3].title,style: TextStyle(fontFamily: "NotoSans"),),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Hospital>>(
        future: _futureHospitais,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Nenhum hospital disponível."));
          }

          final hospitais = snapshot.data!;

          return SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 20),

                  TestableFormField<Hospital>(
                    key: Key("evaluation-hospital-selection-field"),
                    getValue: () => _selectedHospital!,
                    internalSetValue: (state, value) {
                      setState(() {
                        _selectedHospital = value;
                        EvaluationReportV?.hospital = value.name;
                        state.didChange(value);
                      });
                    },
                    builder: (state) {
                      return Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueAccent, width: 5.0),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: DropdownButton<Hospital>(
                          isExpanded: true,
                          value: _selectedHospital,
                          hint: Center(
                            child: Text(
                              _selectedHospital == null
                                  ? "Escolha o hospital*"
                                  : "${_selectedHospital?.name}",
                              style: TextStyle(fontSize: 24, fontFamily: "NotoSans"),
                            ),
                          ),
                          onChanged: (Hospital? newValue) {
                            setState(() {
                              _selectedHospital = newValue!;
                              EvaluationReportV?.hospital = newValue.name;
                              state.didChange(newValue);
                            });
                          },
                          items: hospitais.map((Hospital hospital) {
                            return DropdownMenuItem<Hospital>(
                              value: hospital,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                                child: Text(hospital.name, style: TextStyle(fontSize: 18, fontFamily: "NotoSans")),
                              ),
                            );
                          }).toList(),


                        ),
                      );
                    },
                  ),

                  SizedBox(height: 30),
                  DropDownSelectScore(),
                  SizedBox(height: 30),
                  TextfieldSelectDataeHora(),
                  SizedBox(height: 30),
                  TextfieldDescricao(),
                  SizedBox(height: 26),
                  SubmitButton(context),
                  SizedBox(height: 17),
                ],
              ),
            ),
          );
        },
      ),


    );
  }
  TimeOfDay _roundedTimeOfDay() {
    final now = DateTime.now();
    final int roundedMinute = (now.minute / 5).round() * 5;
    final adjustedMinute = roundedMinute == 60 ? 55 : roundedMinute;
    return TimeOfDay(hour: now.hour, minute: adjustedMinute);
  }



  TestableFormField<String> TextfieldDescricao() {
    return TestableFormField<String>(
      key: Key("evaluation-comment-field"),
      getValue: () => EvaluationReportV?.notas ?? '',
      internalSetValue: (state, value) {
        setState(() {
          EvaluationReportV?.notas = value;
          state.didChange(value);
        });
      },
      builder: (state) {
        return TextField(
          decoration: InputDecoration(
            label: Text(
              'Descrição',
              style: TextStyle(fontSize: 20, fontFamily: "NotoSans"),
            ),
          ),
          onChanged: (text) {
            EvaluationReportV?.notas = text;
            state.didChange(text);
          },
        );
      },
    );
  }


  TestableFormField<DateTime> TextfieldSelectDataeHora() {
    return TestableFormField<DateTime>(
      key: Key("evaluation-datetime-field"),
      getValue: () => EvaluationReportV!.dataeHora,
      internalSetValue: (state, value) {
        setState(() {
          EvaluationReportV?.dataeHora = value;
          EvaluationReportV?.dataValida = true;
          state.didChange(value);
        });
      },
      builder: (state) {
        return InkWell(
          onTap: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );

            if (pickedDate != null) {
              final TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: _roundedTimeOfDay(),
              );

              if (pickedTime != null) {
                final DateTime finalDateTime = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );

                setState(() {
                  EvaluationReportV?.dataeHora = finalDateTime;
                  EvaluationReportV?.dataValida = true;
                  state.didChange(finalDateTime);
                });
              }
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Data e Hora*',
              labelStyle: TextStyle(fontSize: 20, fontFamily: "NotoSans"),
              border: OutlineInputBorder(),
            ),
            child: Text(
              EvaluationReportV?.dataeHora != null
                  ? DateFormat('dd/MM/yyyy HH:mm').format(EvaluationReportV!.dataeHora)
                  : 'Selecionar data e hora',
              style: TextStyle(fontSize: 18),

            ),
          ),
        );
      },
    );
  }



  TestableFormField<void> SubmitButton(BuildContext context) {
    return TestableFormField<void>(
      key: Key("evaluation-form-submit-button"),
      getValue: () => null,
      internalSetValue: (_, __) {},
      builder: (_) {
        return ElevatedButton(

          onPressed: () {
            _validateAndSave(context);
          },
          child: Text("Validar e guardar"),
        );
      },
    );
  }


  TestableFormField<int> DropDownSelectScore() {
    return TestableFormField<int>(
      key: Key("evaluation-rating-field"),
      getValue: () => score!,
      internalSetValue: (state, value) {
        setState(() {
          score = value;
          EvaluationReportV?.score = value;
          state.didChange(value);
        });
      },
      builder: (state) {
        return Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent, width: 5.0),
            borderRadius: BorderRadius.circular(100),
          ),
          child: DropdownButton<int>(
            isExpanded: true,
            value: score,
            hint: Center(
              child: Text(
                "Escolha o score (1-5)*",
                style: TextStyle(fontSize: 24, fontFamily: "NotoSans"),
              ),
            ),
            onChanged: (int? newValue) {
              setState(() {
                score = newValue!;
                EvaluationReportV?.score = newValue;
                state.didChange(newValue);
              });
            },
            items: _scoreoptions.map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text("$value", style: TextStyle(fontFamily: "NotoSans")),
              );
            }).toList(),
          ),
        );
      },
    );
  }


  void _validateAndSave(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    List<String> errors = [];

    if (_selectedHospital == null) {
      errors.add("Hospital não selecionado.");
    }

    if (score == null) {
      errors.add("Score não selecionado.");
    }

    if (!(EvaluationReportV!.dataValida)) {
      errors.add("Data e Hora inválida ou não preenchida.");
    }

    if (errors.isEmpty) {
      final snsRepo =  context.read<HospitalRepository>();

      try {
        await snsRepo.insertHospital(_selectedHospital!);
        // Garante que o hospital está corretamente atribuído
        EvaluationReportV!.hospital = _selectedHospital!.name;

        // Adiciona no repositório remoto em memória
        await snsRepo.attachEvaluation(_selectedHospital!.id, EvaluationReportV!);

        // Também salva localmente no banco de dados
        await snsRepo.insertReport(EvaluationReportV!);

        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("Formulário salvo com sucesso!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("Erro ao salvar avaliação: $e"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text("Preencha a avaliação: " + errors.join('\n')),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }



}