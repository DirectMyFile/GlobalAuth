part of globalauth.client;

/**
 * A command that the client can execute
 */
abstract class Command {
  
  final String name;

  Command({this.name}) {
    if (name == null) throw new ArgumentError.notNull("name");
  }

  Future execute(CliClient client, List<String> args);
}

/**
 * Connects the REPL client to the server.
 * The following args are used:
 * 1) Server address (string, optional, default 'localhost')
 * 2) port (int, optional, default 3100 (insecure) and 3110 (secure))
 * 3) secure (bool, optional, default false)
 * 4) badCert (bool, optional, default false)
 */
class ConnectCommand extends Command {

  ConnectCommand() : super(name: 'connect');

  Future execute(CliClient client, List<String> args) async {
    print("Connecting to server...");

    String address = 'localhost';
    int port = 3100;
    bool secure = false;
    bool badCert = false;

    if (args.length > 2)
      secure = args[2] == "true";
    if (secure)
      port = 3110;

    if (args.length > 0)
      address = args[0];
    if (args.length > 1)
      port = int.parse(args[1]);
    if (args.length > 3)
      badCert = args[3] == "true";

    var c = new GAClient(address: address,
                          port: port,
                          secure: secure,
                          badCert: badCert);
    client.client = c;
    try {
      await c.connect();
      c.listen();
    } on SocketException catch (e) {
      print("Error connecting to server (${e.osError.message})");
      return;
    }
    print("Connected to server");
  }
}

class DisconnectCommand extends Command {

  DisconnectCommand() : super(name: 'disconnect');

  Future execute(CliClient client, List<String> args) {
    client.client = null;
    print("Disconnected from server");
  }
}

/**
 * Exits the REPL client.
 */
class ExitCommand extends Command {

  ExitCommand() : super(name: 'exit');

  Future execute(CliClient client, List<String> args) {
    print("Exiting...");
    client.client = null;
    client.stop();
  }
}
