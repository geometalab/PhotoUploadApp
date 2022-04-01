import 'dart:io';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

// Checks if an internet connection can be established.
// Pings commons.wikimedia.org to check internet.
class ConnectionStatusListener {
  // Make Singleton
  static final ConnectionStatusListener _singleton =
      new ConnectionStatusListener._internal();
  ConnectionStatusListener._internal();
  static ConnectionStatusListener getInstance() => _singleton;

  bool hasConnection = false;

  StreamController connectionChangeController =
      new StreamController.broadcast();

  final Connectivity _connectivity = Connectivity();

  void initialize() {
    _connectivity.onConnectivityChanged.listen(_connectionChange);
    checkConnection();
  }

  Stream get connectionChange => connectionChangeController.stream;

  void dispose() {
    connectionChangeController.close();
  }

  void _connectionChange(ConnectivityResult result) {
    checkConnection();
  }

  Future<bool> checkConnection() async {
    bool previousConnection = hasConnection;

    try {
      sleep(Duration(
          milliseconds:
              500)); // If there is no wait here, the lookup still gets a result and therefore doesn't set 'hasConnection' correctly.
      final result = await InternetAddress.lookup('commons.wikimedia.org');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        hasConnection = true;
      } else {
        hasConnection = false;
      }
    } on SocketException catch (_) {
      hasConnection = false;
    }

    if (previousConnection != hasConnection) {
      connectionChangeController.add(hasConnection);
    }
    return hasConnection;
  }
}
