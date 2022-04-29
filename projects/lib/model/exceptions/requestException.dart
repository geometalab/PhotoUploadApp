import 'package:http/http.dart';

class RequestException implements Exception {
  String purpose;
  Response response;
  RequestException(this.purpose, this.response);

  @override
  String toString() {
    return "$purpose Status Code: ${response.statusCode} Reason: ${response.reasonPhrase}";
  }
}
