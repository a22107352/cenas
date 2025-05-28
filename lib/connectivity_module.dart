import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectivityModule {
  Future<bool> checkConnectivity();
}