import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'https://10.0.2.2:3001/api';

  static final http.Client _client = http.Client();

  static http.Client get client => _client;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  static Future<http.Response> get(String path) async {
    return _client.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
  }

  static Future<http.Response> post(String path, {Map<String, dynamic>? body}) async {
    return _client.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  static Future<http.Response> put(String path, {Map<String, dynamic>? body}) async {
    return _client.put(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  static Future<http.Response> patch(String path, {Map<String, dynamic>? body}) async {
    return _client.patch(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  static Future<http.Response> delete(String path) async {
    return _client.delete(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
  }
}

class HttpOverridesIgnoreCert extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (_, __, ___) => true;
  }
}
