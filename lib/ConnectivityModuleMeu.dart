import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:prjectcm/connectivity_module.dart';

class ConnectivityModuleMeu extends ConnectivityModule{
  @override
  Future<bool> checkConnectivity() async{

      final coonnectivity = await Connectivity().checkConnectivity();
      return coonnectivity== ConnectivityResult.mobile || coonnectivity == ConnectivityResult.wifi;

  }}