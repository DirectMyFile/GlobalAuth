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

    if (json[ConfigReader.SECURE] == null)
      json[ConfigReader.SECURE] = {};

    var secure = json[ConfigReader.SECURE];
    if (secure[ConfigReader.ENABLED] == null)
      secure[ConfigReader.ENABLED] = config.useSecure;
    if (secure[ConfigReader.PORT] == null)
      secure[ConfigReader.PORT] = config.sslPort;

    if (json[ConfigReader.INSECURE] == null)
      json[ConfigReader.INSECURE] = {};

    var insecure = json[ConfigReader.INSECURE];
    if (insecure[ConfigReader.ENABLED] == null)
      insecure[ConfigReader.ENABLED] = config.useInsecure;
    if (insecure[ConfigReader.PORT] == null)
      insecure[ConfigReader.PORT] = config.port;

    if (exists)
      _path.deleteSync();
    _path.writeAsStringSync(enc.convert(json));
  }
}
