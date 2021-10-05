class Config {
  static final Config _config = Config._internal();
  factory Config() {
    return _config;
  }
  Config._internal();

  static const WIKIMEDIA_REST = "https://meta.wikimedia.org/w/rest.php";
  static const WIKIMEDIA_API = "https://test.wikipedia.org/w/api.php";
  static const CLIENT_ID = "f99a469a26bd7ae8f1d32bef1fa38cb3";
  static const CREDENTIALS_FILE = "credentials.json";
}