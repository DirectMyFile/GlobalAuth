part of globalauth.server;

abstract class Storage {

  /**
   * Configuration that configures the storage connection.
   */
  final Config config;

  /**
   * Create storage connectors based on the configuration.
   */
  factory Storage.create(Config config) {
    String scheme = Uri.parse(config.dbUri).scheme;
    switch (scheme) {
      case "mongodb":
        return new _MongoDbStorage(config);
      default:
        throw new Exception("Database driver not implemented ($scheme)");
    }
  }

  Storage(this.config);

  /**
   * Instantiates the connection to the database server
   */
  Future connect();
}

class _MongoDbStorage extends Storage {

  mongodb.Db _db;

  _MongoDbStorage(Config conf) : super(conf);

  Future connect() {
    _db = new mongodb.Db(config.dbUri);
    return _db.open();
  }
}
