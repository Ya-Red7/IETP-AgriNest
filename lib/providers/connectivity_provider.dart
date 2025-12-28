import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectionStatus {
  online,
  offline,
  checking,
}

final connectivityProvider = StreamProvider<ConnectionStatus>((ref) async* {
  final connectivity = Connectivity();
  
  // Initial check
  yield ConnectionStatus.checking;
  final initialResult = await connectivity.checkConnectivity();
  yield _getConnectionStatus([initialResult]);
  
  // Listen to connectivity changes
  await for (final result in connectivity.onConnectivityChanged) {
    // onConnectivityChanged emits single ConnectivityResult
    yield _getConnectionStatus([result]);
  }
});

ConnectionStatus _getConnectionStatus(List<ConnectivityResult> results) {
  // Check if any connection type is available (not none)
  if (results.isEmpty || results.contains(ConnectivityResult.none)) {
    return ConnectionStatus.offline;
  }
  
  // If we have any active connection type, we're online
  return ConnectionStatus.online;
}

