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
      body: body != null ? _encode(body) : null,
    );
  }

  static Future<http.Response> put(String path, {Map<String, dynamic>? body}) async {
    return _client.put(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: body != null ? _encode(body) : null,
    );
  }

  static Future<http.Response> patch(String path, {Map<String, dynamic>? body}) async {
    return _client.patch(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: body != null ? _encode(body) : null,
    );
  }

  static Future<http.Response> delete(String path) async {
    return _client.delete(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
  }

  static String _encode(Map<String, dynamic> body) {
    return _jsonEncode(body);
  }

  static String _jsonEncode(Map<dynamic, dynamic> body) {
    return body.keys.map((k) {
      final v = body[k];
      if (v == null) return '"$k":null';
      if (v is String) return '"$k":"${_escape(v)}"';
      if (v is num || v is bool) return '"$k":$v';
      if (v is List) {
        final items = v.map((e) {
          if (e is String) return '"${_escape(e)}"';
          if (e is num || e is bool) return '$e';
          if (e is Map) return _jsonEncode(e);
          return 'null';
        }).join(',');
        return '"$k":[$items]';
      }
      if (v is Map) return '"$k":${_jsonEncode(v)}';
      return '"$k":null';
    }).join(',');
  }

  static String _escape(String s) {
    return s
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }
}

class HttpOverridesIgnoreCert extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (_, __, ___) => true;
  }
}
