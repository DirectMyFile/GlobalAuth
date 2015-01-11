part of globalauth.server;

/**
 * Manages the server configuration.
 */
class Config {

  /**
   * Whether to enable listening to secure communications.
   */
  final bool useSecure;

  /**
   * The bind address for the secure server to bind to.
   */
  final String sslBindAddress;

  /**
   * Port used for secure communications.
   */
  final int sslPort;

  /**
   * Path to the NSS key database.
   */
  final String certDatabasePath;

  /**
   * The common name of the certificate to use.
   */
  final String certCommonName;

  /**
   * Password of the database.
   */
  final String certPassword;

  /**
   * Whether to enable listening to insecure communications.
   */
  final bool useInsecure;

  /**
   * The bind address for the insecure server to bind to.
   */
  final String bindAddress;

  /**
   * Port used for insecure communications.
   */
  final int port;

  /**
   * URI of the database to connect to.
   */
  final String dbUri;

  Config({this.useSecure: false,
          this.sslBindAddress: "0.0.0.0",
          this.sslPort: 3110,
          this.certDatabasePath: "cert",
          this.certCommonName: "example",
          this.certPassword: "12345",
          this.useInsecure: true,
          this.bindAddress: "0.0.0.0",
          this.port: 3100,
          this.dbUri: "mongodb://admin:12345@localhost/global_auth"});
}

class ConfigReader {

  static const String SECURE = "secure";
  static const String INSECURE = "insecure";
  static const String ENABLED = "enabled";
  static const String BIND_ADDR = "bind";
  static const String PORT = "port";

  static const String CERT_INFO = "certificate";
  static const String CERT_PATH = "path";
  static const String CERT_NAME = "common_name";
  static const String CERT_PASS = "password";

  static const String DB = "db";
  static const String DB_URI = "uri";

  final File _path;

  ConfigReader(this._path);

  Config read() {
    var json = JSON.decode(_path.readAsStringSync());

    var secure = _fieldCheck(json, SECURE);
    bool useSecure = _fieldCheck(secure, ENABLED);
    int sslPort = _fieldCheck(secure, PORT);
    String sslBind = _fieldCheck(secure, BIND_ADDR);

    var cert = _fieldCheck(secure, CERT_INFO);
    String path = _fieldCheck(cert, CERT_PATH);
    String name = _fieldCheck(cert, CERT_NAME);
    String pass = _fieldCheck(cert, CERT_PASS);

    var insecure = _fieldCheck(json, INSECURE);
    bool useInsecure = _fieldCheck(insecure, ENABLED);
    int port = _fieldCheck(insecure, PORT);
    String bind = _fieldCheck(insecure, BIND_ADDR);

    var db = _fieldCheck(json, DB);
    String uri = _fieldCheck(db, DB_URI);

    return new Config(useSecure: useSecure,
                      sslPort: sslPort,
                      certDatabasePath: path,
                      certCommonName: name,
                      certPassword: pass,
                      useInsecure: useInsecure,
                      port: port,
                      dbUri: uri);
  }

  _fieldCheck(Map m, String field) {
    var f = m[field];
    if (f == null)
      throw new Exception("Missing field '$field' in '$m' (run --genconf to fix this)");
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

    _communications(json, ConfigReader.SECURE,
                            config.sslBindAddress,
                            config.useSecure,
                            config.sslPort);
    var secure = json[ConfigReader.SECURE];
    if (secure[ConfigReader.CERT_INFO] == null)
      secure[ConfigReader.CERT_INFO] = {};

    secure = secure[ConfigReader.CERT_INFO];
    if (secure[ConfigReader.CERT_PATH] == null)
      secure[ConfigReader.CERT_PATH] = config.certDatabasePath;
    if (secure[ConfigReader.CERT_NAME] == null)
      secure[ConfigReader.CERT_NAME] = config.certCommonName;
    if (secure[ConfigReader.CERT_PASS] == null)
      secure[ConfigReader.CERT_PASS] = config.certPassword;

    _communications(json, ConfigReader.INSECURE,
                            config.bindAddress,
                            config.useInsecure,
                            config.port);

    var db = json[ConfigReader.DB];
    if (db == null)
      json[ConfigReader.DB] = {};
    db = json[ConfigReader.DB];

    if (db[ConfigReader.DB_URI] == null)
      db[ConfigReader.DB_URI] = config.dbUri;

    if (exists)
      _path.deleteSync();
    _path.writeAsStringSync(enc.convert(json));
  }

  void _communications(Map json, String field,
                                  String bindAddr, bool enabled, int port) {
    if (json[field] == null)
      json[field] = {};

    var struct = json[field];
    if (struct[ConfigReader.ENABLED] == null)
      struct[ConfigReader.ENABLED] = enabled;
    if (struct[ConfigReader.BIND_ADDR] == null)
      struct[ConfigReader.BIND_ADDR] = bindAddr;
    if (struct[ConfigReader.PORT] == null)
      struct[ConfigReader.PORT] = port;
  }
}
