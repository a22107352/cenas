import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prjectcm/connectivity_module.dart';
import 'ConnectivityModuleMeu.dart';
import 'data/http_sns_datasource.dart';
import 'data/sqflite_sns_datasource.dart';
import 'main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final sqfliteSnsDataSource = SqfliteSnsDataSource();
  final httpSnsDataSource = HttpSnsDataSource();
  final connectivityModule = ConnectivityModuleMeu();

  runApp(
    MultiProvider(
      providers: [
        Provider<HttpSnsDataSource>.value(value: httpSnsDataSource),
        Provider<SqfliteSnsDataSource>.value(value: sqfliteSnsDataSource),
        Provider<ConnectivityModule>.value(value: connectivityModule),
      ],
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
  late final SqfliteSnsDataSource sqfliteSnsDataSource;

  @override
  void initState() {
    super.initState();
    sqfliteSnsDataSource = context.read<SqfliteSnsDataSource>();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: sqfliteSnsDataSource.init(),
      builder: (_, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        var colorScheme = ColorScheme.fromSeed(seedColor: Colors.blueAccent);

        return MaterialApp(
          title: 'Projecto CM',
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
          home: Mainpage(),
        );
      },
    );
  }
}



