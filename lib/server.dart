library globalauth.server;

import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'common.dart';

part 'server/config.dart';

class Server {

  final Config config;

  SecureServerSocket _secureSocket;
  ServerSocket _socket;

  Server(this.config);

  /**
   * Starts listening for secure and insecure communications depending on the
   * configuration settings.
   */
  Future listen() async {
    if (config.useInsecure) {
      _socket = await ServerSocket.bind(config.bindAddress, config.port);
      _socket.listen(_handler).onError((err) {
        print("An error occured accepting an insecure connection => $err");
      });
    }

    if (config.useSecure) {
      SecureSocket.initialize(database: config.certDatabasePath,
                              password: config.certPassword);
      _secureSocket = await SecureServerSocket.bind(config.sslBindAddress,
                                                    config.sslPort,
                                                    "CN=${config.certCommonName}");
      _secureSocket.listen(_handler).onError((err) {
        print("An error occured accepting a secure connection => $err");
      });
    }

    return null;
  }

  void _handler(Socket s) {
    print("Client connected");
    s.transform(UTF8.decoder).transform(new CRLFLineSplitter())
                                          .listen((String data) {
      var json = JSON.decode(data);
    }, onDone: _clientDisconnected,
        onError: (_) => _clientDisconnected());
  }

  void _clientDisconnected() {
    print("Client disconnected");
  }

  void stop() {
    if (config.useInsecure) {
      _socket.close();
    }

    if (config.useSecure) {
      _secureSocket.close();
    }
  }
}
