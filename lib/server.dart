library globalauth.server;

import 'package:mongo_dart/mongo_dart.dart' as mongodb;

import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'common.dart';

part 'server/storage.dart';
part 'server/config.dart';

class Server {

  final Storage _storage;
  final Config config;

  SecureServerSocket _secureSocket;
  ServerSocket _socket;

  Server(this.config, this._storage);

  /**
   * Starts listening for secure and insecure communications based on the
   * configuration settings.
   */
  Future initialize() async {
    // Initialize insecure server
    if (config.useInsecure) {
      _socket = await ServerSocket.bind(config.bindAddress, config.port);
      _socket.listen(_handler).onError((err) {
        print("An error occured accepting an insecure connection => $err");
      });
    }

    // Initialize secure server
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

    // Initialize database connection
    await _storage.connect();

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
