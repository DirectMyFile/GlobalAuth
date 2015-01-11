library globalauth.client;

import 'package:task_queue/task_queue.dart';
import 'common.dart';

import 'dart:convert';
import 'dart:async';
import 'dart:io';

part 'client/cli/commands.dart';
part 'client/cli/manager.dart';

/**
 * Client that handles a connection to the Global Auth server. Used for
 * interacting with a server, such as retrieving data or changing settings.
 */
class GAClient {

  /**
   * Address of the server to connect to.
   */
  final String address;

  /**
   * Port to connect to the server on.
   */
  final int port;

  /**
   * Whether to use a secure connection or not.
   */
  final bool secure;

  /**
   * Whether to accept bad certificates or not.
   */
  final bool badCert;

  bool _connected = false;
  Socket _sock;

  GAClient({this.address: "localhost",
            this.port: 3100,
            this.secure: false,
            this.badCert: false});

  Future connect() async {
    if (_connected) throw new Exception("Already connected");
    if (secure) {
      _sock = await SecureSocket.connect(address,
                                          port,
                                          onBadCertificate: (_) => badCert);
    } else {
      _sock = await Socket.connect(address, port);
    }
    _connected = true;
  }

  void listen() {
    _sock.transform(UTF8.decoder)
          .transform(new CRLFLineSplitter())
          .listen(_handler);
  }

  void disconnect() {
    if (_connected && _sock != null) {
      _sock.destroy();
    }
    _connected = false;
  }

  void _handler(String data) {

  }
}

/**
 * Client that handles Read-eval-print-loop. There must be only one instance
 * created at a time.
 */
class CliClient {

  static final RegExp _reg = new RegExp("'.*?'|\".*?\"|\\S+");

  final TaskQueue _queue = new TaskQueue();
  final String termPrefix = "> ";

  GAClient get client => _client;
  set client(GAClient client) {
    if (_client != null) {
      _client.disconnect();
    }
    _client = client;
  }
  GAClient _client;

  StreamSubscription _sub;
  CommandManager _manager;
  bool _running = false;

  CliClient([this._manager]) {
    if (_manager == null) _manager = new CommandManager();
  }

  void listen() {
    _running = true;
    _end();
    _sub = stdin.transform(UTF8.decoder)
                .transform(new LineSplitter())
                .listen(_handler);
  }

  void stop() {
    if (_sub != null) _sub.cancel();
    _running = false;
  }

  void _handler(String data) {
    _queue.schedule(_runner, positionalArguments: [data]);
  }

  Future<Null> _runner(String data) async {
    if (!_running || data == null)
      return null;

    data = data.trim();
    if (data.isEmpty) {
      return _end();
    }

    var args = _parseCommand(data);
    if (args == null) {
      print("Failed to parse command, a quotation is missing.");
      return _end();
    }

    var command = args[0];
    args = args.getRange(1, args.length).toList(growable: false);
    await _manager.execute(this, command, args);

    // Execution of command finished, reset command line
    return _end();
  }

  /**
   * Parses the data into a list of arguments. Null if there is a parsing error.
   */
  List<String> _parseCommand(String data) {
    List<String> args = [];
    for (Match m in _reg.allMatches(data)) {
      String match = m.group(0);
      if (match == "'" || match == '"') {
        return null;
      }

      if (match.startsWith('"') || match.startsWith("'"))
        match = match.substring(1);
      if (match.endsWith('"') || match.endsWith("'"))
        match = match.substring(0, match.length - 1);

      args.add(match.trim());
    }
    return args;
  }

  Null _end() {
    if (_running) {
      stdout.write(termPrefix);
      stdout.flush();
    }
    return null;
  }
}
