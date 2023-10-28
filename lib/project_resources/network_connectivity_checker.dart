import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkConnectivity {
  NetworkConnectivity._();
  static final _instance = NetworkConnectivity._();
  static NetworkConnectivity get instance => _instance;
  final _networkConnectivity = Connectivity();
  final StreamController<bool> _controller = StreamController.broadcast(sync: true);
  StreamSink<bool> get streamSink => _controller.sink;
  Stream<bool> get myStream => _controller.stream;
  // 1.
  void initialise() async {
    ConnectivityResult result = await _networkConnectivity.checkConnectivity();
    checkStatus(result);
    _networkConnectivity.onConnectivityChanged.listen((result) {
      print(result);
      checkStatus(result);
    });
  }

// 2.
  void checkStatus(ConnectivityResult result) async {
    bool isOnline = false;
    String name = result.name;
    try {
      final result = await InternetAddress.lookup('google.com');
      isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      isOnline = false;
    }
    if (name.contains("wifi") || name.contains("mobile")) {
      if (isOnline == true) {
        _controller.sink.add(isOnline);
      }
    }
  }

  void disposeStream() => _controller.close();
}
