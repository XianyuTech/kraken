import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'module_manager.dart';

String _toString(ConnectivityResult connectivityResult) {
  String isConnected = jsonEncode(ConnectivityResult.none != connectivityResult);
  String type = _parseConnectivityResult(connectivityResult);

  return '{"isConnected": $isConnected, "type": "$type"}';
}

String _parseConnectivityResult(ConnectivityResult state) {
  switch (state) {
    case ConnectivityResult.wifi:
      return 'wifi';
    case ConnectivityResult.mobile:
      return 'cellular';
    case ConnectivityResult.none:
    default:
      return 'none';
  }
}

typedef OnConnectivityChangedCallback = void Function(String json);

class ConnectionModule extends BaseModule {
  @override
  String get name => 'Connection';

  static Connectivity _connectivity;

  static void _initConnectivity() {
    if (_connectivity == null) {
      _connectivity = Connectivity();
    }
  }

  static void getConnectivity(callback) {
    _initConnectivity();
    _connectivity.checkConnectivity().then((ConnectivityResult connectivityResult) {
      callback(_toString(connectivityResult));
    });
  }

  static void onConnectivityChanged(OnConnectivityChangedCallback callback) {
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen((ConnectivityResult connectivityResul) {
      String json = _toString(connectivityResul);
      callback(json);
    });
  }

  ConnectionModule(ModuleManager moduleManager) : super(moduleManager);

  @override
  void dispose() {}

  @override
  String invoke(String method, dynamic params, InvokeModuleCallback callback) {
    switch (method) {
      case 'getConnectivity': {
        getConnectivity((String json) {
          callback(data: json);
        });
        break;
      }
      case 'onConnectivityChanged': {
        onConnectivityChanged((String json) {
          moduleManager.emitModuleEvent('connection', data: '["onConnectivityChanged", $json]');
        });
        break;
      }
    }

    return '';
  }
}
