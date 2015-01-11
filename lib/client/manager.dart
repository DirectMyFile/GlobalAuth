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
      manager.add(new ExitCommand());
    }
    return manager;
  }

  CommandManager._internal();

  void add(Command command) {
    if (commands.containsKey(command.name))
      throw new Exception("Command already registered: ${command.name}");
    commands[command.name] = command;
  }

  void execute(String command, List<String> args) {
    Command c = commands[command];
    if (c == null) {
      print("Command does not exist: $command");
      return;
    }
    c.execute(args);
  }
}
