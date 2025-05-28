import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prjectcm/connectivity_module.dart';
import 'package:prjectcm/http/http_client.dart';
import 'package:prjectcm/models/hospital.dart';

import 'ConnectivityModuleMeu.dart';
import 'data/HospitalRepository.dart';
import 'data/http_sns_datasource.dart';
import 'data/sqflite_sns_datasource.dart';
import 'main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sqfliteSnsDataSource = SqfliteSnsDataSource();
  await sqfliteSnsDataSource.init();

  final httpSnsDataSource = HttpSnsDataSource(HttpClient());

  final hospitalRepository = HospitalRepository(
    local: sqfliteSnsDataSource,
    remote: httpSnsDataSource,
    connectivityModule: ConnectivityModuleMeu(),
  );



  runApp(
    Provider<HospitalRepository>.value(
      value: hospitalRepository,
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    var colorScheme = ColorScheme.fromSeed(seedColor: Colors.blueAccent);

    return MaterialApp(
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        appBarTheme: ThemeData.from(colorScheme: colorScheme)
            .appBarTheme
            .copyWith(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.surface,
        ),
      ),
      title: 'Projecto CM',
      home: Mainpage(),
    );
  }

}
