part of globalauth.client;

/**
 * Manages a list of commands for a CLI manager.
 */
class CommandManager {

  final Map<String, Command> commands = {};

  /**
   * [useDefault] determines whether to use default commands or not.
   */
  factory CommandManager({bool useDefault: true}) {
    var manager = new CommandManager._internal();
    if (useDefault) {
      manager += new ExitCommand();
      manager += new ConnectCommand();
      manager += new DisconnectCommand();
    }
    return manager;
  }

  CommandManager._internal();

  void add(Command command) {
    if (commands.containsKey(command.name))
      throw new Exception("Command already registered: ${command.name}");
    commands[command.name] = command;
  }

  Future execute(CliClient client, String command, List<String> args) async {
    Command c = commands[command];
    if (command == "help") {
      printHelp();
      return;
    } else if (c == null) {
      print("Command does not exist: $command");
      return;
    }
    await c.execute(client, args);
  }

  void printHelp() {
    int minSpaces = 0;
    for (var name in commands.keys) {
      int len = name.length;
      if (len > minSpaces)
        minSpaces = len;
    }

    for (var comm in commands.values) {
      var name = comm.name;
      while (name.length < minSpaces)
        name += " ";
      _printCommand(name, comm);
    }
  }

  void _printCommand(String name, Command command) {
    print("$name - ${command.getDescription()}");
  }

  operator +(Command c) {
    add(c);
    return this;
  }
}
