import 'dart:io';

import 'package:globalauth/server.dart';
import 'package:args/args.dart';

void main(List<String> args) {
  var parser = new ArgParser();

  parser.addFlag("genconf",
                  defaultsTo: false,
                  negatable: false,
                  help: "Generates a configuration file with default settings");
  parser.addFlag("help",
                  defaultsTo: false,
                  negatable: false,
                  help: "Displays this help menu");

  parser.addOption("path",
                    defaultsTo: "server.json",
                    help: "The path to the current configuration file");

  var results = parser.parse(args);
  if (results['help']) {
    print(parser.getUsage());
    return;
  }

  File path = new File(results['path']);

  if (results['genconf']) {
    var def = new Config();
    var writer = new ConfigWriter(path);
    writer.write(def);
    return;
  }

  var conf = new ConfigReader(path).read();
  var server = new Server(conf, new Storage.create(conf));
  server.initialize();
}
