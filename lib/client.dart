library globalauth.client;

import 'package:task_queue/task_queue.dart';

import 'dart:convert';
import 'dart:async';
import 'dart:io';

part 'client/commands.dart';
part 'client/manager.dart';

/**
 * Client that handles Read-eval-print-loop. There must be only one instance
 * created at a time.
 */
class CliClient {

  static CliClient get CLIENT => _CLIENT;
  static CliClient _CLIENT;

  static final RegExp _reg = new RegExp("'.*?'|\".*?\"|\\S+");

  final TaskQueue _queue = new TaskQueue();
  final String termPrefix = "> ";

  StreamSubscription _sub;
  CommandManager _manager;
  bool _running = false;

  factory CliClient([manager]) {
    if (_CLIENT != null) throw new Exception("Client instance already created");
    if (manager == null) manager = new CommandManager();

    _CLIENT = new CliClient._internal(manager);
    return CLIENT;
  }

  CliClient._internal(this._manager);

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

    _manager.execute(args[0], args.getRange(1, args.length).toList(growable: false));

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
