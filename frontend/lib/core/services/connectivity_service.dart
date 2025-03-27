import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';


class ConnectivityService 
{
  List<ConnectivityResult> _currentConnectivity = [ConnectivityResult.none];
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  static final ConnectivityService _instance = ConnectivityService._internal();
  ConnectivityService._internal();

  factory ConnectivityService() => _instance;


  void init()
  {
    _connectivitySubscription?.cancel();

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      _currentConnectivity = result;
    });

    Connectivity().checkConnectivity().then((result) {
      _currentConnectivity = result;
    });
  }


  void dispose() 
  {
    _connectivitySubscription?.cancel();
  }


  Future<bool> get isOnline async => (
    _currentConnectivity.contains(ConnectivityResult.wifi) || 
    _currentConnectivity.contains(ConnectivityResult.mobile)
  );

  Future<bool> get isOffline async => !(await isOnline);


  Future<List<ConnectivityResult>> get currentConnectivity async => _currentConnectivity;
}
