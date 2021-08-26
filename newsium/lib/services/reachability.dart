import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';

class Reachability extends Object {
  final Connectivity _connectivity = Connectivity();

  // network change subscription
  // ignore: cancel_subscriptions
  StreamSubscription<ConnectivityResult>? connectivitySubscription;

  // current network status
  String _connectStatus = 'Unknown';
  String get connectStatus => _connectStatus;

  //Constant for check network status
  static String _connectivityMobile = "ConnectivityResult.mobile";
  static String _connectivityWifi = "ConnectivityResult.wifi";

  factory Reachability() {
    return _singleton;
  }

  static final Reachability _singleton = Reachability._internal();
  Reachability._internal() {
    connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _connectStatus = result.toString();
      Logger().v("ConnectionStatus :: = $_connectStatus");
    });
  }

  dispose() async {
    await this.connectivitySubscription?.cancel();
  }

  //cancel subscription for network change
  unregisterReachbilityChange() async {
    await this.dispose();
  }

  // set up initial
  Future<Null> setUpConnectivity() async {
    String connectionStatus;

    try {
      connectionStatus = (await _connectivity.checkConnectivity()).toString();
      Logger().v("ConnectionStatus :: => $connectionStatus");
    } on Exception catch (e) {
      print(e.toString());
      connectionStatus = 'Failed to get connectivity.';
    }

    _connectStatus = connectionStatus;
    Logger().v("ConnectionStatus :: => $_connectStatus");
  }

  // check for network available
  bool isInterNetAvaialble() {
    Logger().v("ConnectionStatus :: => $_connectStatus");
    return (_connectStatus == Reachability._connectivityMobile) ||
        (_connectStatus == Reachability._connectivityWifi);
  }
}
