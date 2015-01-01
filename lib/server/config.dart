part of globalauth.server;

/**
 * Manages the server configuration.
 */
class Config {

  /**
   * Whether to enable listening to secure communications
   */
  final bool useSecure;

  /**
   * Port used for secure communications
   */
  final int sslPort;

  /**
   * Whether to enable listening to insecure communications
   */
  final bool useInsecure;

  /**
   * Port used for insecure communications
   */
  final int port;

  Config({this.useSecure: false,
          this.sslPort: 3110,
          this.useInsecure: true,
          this.port: 3100});

}

class ConfigReader {

  static const String SECURE = "secure";
  static const String INSECURE = "insecure";

  static const String ENABLED = "enabled";
  static const String PORT = "port";

  final File _path;

  ConfigReader(this._path);

  Config read() {
    var json = JSON.decode(_path.readAsStringSync());

    var secure = _fieldCheck(json, SECURE);
    bool useSecure = _fieldCheck(secure, ENABLED);
    int sslPort = _fieldCheck(secure, PORT);

    var insecure = _fieldCheck(json, INSECURE);
    bool useInsecure = _fieldCheck(insecure, ENABLED);
    int port = _fieldCheck(json, PORT);

    return new Config(useSecure: useSecure,
                      sslPort: sslPort,
                      useInsecure: useInsecure,
                      port: port);
  }

  _fieldCheck(Map m, String field) {
    var f = m[field];
    if (f == null)
      throw new Exception("Missing field '$field' in '$m'");
    return f;
  }
}

class ConfigWriter {

  final JsonEncoder enc = new JsonEncoder.withIndent("  ");
  final File _path;

  ConfigWriter(this._path);

  void write(final Config config) {
    final bool exists = _path.existsSync();
    var json = {};
    if (exists)
      json = JSON.decode(_path.readAsStringSync());

    _communications(json, ConfigReader.SECURE, config.useSecure, config.sslPort);
    _communications(json, ConfigReader.INSECURE, config.useInsecure, config.port);

    if (exists)
      _path.deleteSync();
    _path.writeAsStringSync(enc.convert(json));
  }

  void _communications(Map json, String field, bool enabled, int port) {
    if (json[field] == null)
      json[field] = {};

    var struct = json[field];
    if (struct[ConfigReader.ENABLED] == null)
      struct[ConfigReader.ENABLED] = enabled;
    if (struct[ConfigReader.PORT] == null)
      struct[ConfigReader.PORT] = port;
  }
}
