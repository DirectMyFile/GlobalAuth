part of globalauth.client;

/**
 * A command that the client can execute
 */
abstract class Command {
  
  final String name;

  Command({this.name}) {
    if (name == null) throw new ArgumentError.notNull("name");
  }

  void execute(List<String> args);
}

class ExitCommand extends Command {

  ExitCommand() : super(name: 'exit');

  void execute(List<String> args) {
    print("Exiting...");
    CliClient.CLIENT.stop();
  }
}
