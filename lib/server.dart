library globalauth.server;

import 'dart:convert';
import 'dart:async';
import 'dart:io';

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
    }

    if (config.useSecure) {
      SecureSocket.initialize(database: config.certDatabasePath,
                              password: config.certPassword);
      _secureSocket = await SecureServerSocket.bind(config.sslBindAddress,
                                                    config.sslPort,
                                                    "CN=${config.certCommonName}}");
    }
    return null;
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
