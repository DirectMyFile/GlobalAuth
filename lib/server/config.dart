part of globalauth.server;

/**
 * Manages the server configuration.
 */
class Config {

  /**
   * If port is -1, secure communications are disabled
   */
  final int sslPort;

  /**
   * If port is -1, non-secure communications are disabled
   */
  final int port;

  Config({this.sslPort: 3110, this.port: 3100});

}

class ConfigReader {

  static const String SSL_PORT = "ssl_port";
  static const String PORT = "port";

  final File _path;

  ConfigReader(this._path);

  Config read() {
    var json = JSON.decode(_path.readAsStringSync());
    int sslPort = _fieldCheck(json, SSL_PORT);
    int port = _fieldCheck(json, PORT);
    return new Config(sslPort: sslPort, port: port);
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
    var json = {};
    if (_path.existsSync()) {
      json = JSON.decode(_path.readAsStringSync());
      _path.deleteSync();
    }

    if (json[ConfigReader.SSL_PORT] == null)
      json[ConfigReader.SSL_PORT] = config.sslPort;

    if (json[ConfigReader.PORT] == null)
      json[ConfigReader.PORT] = config.port;

    _path.writeAsStringSync(enc.convert(json));
  }
}
