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
    if (c == null) {
      print("Command does not exist: $command");
      return;
    }
    await c.execute(client, args);
  }

  operator +(Command c) {
    add(c);
    return this;
  }
}
