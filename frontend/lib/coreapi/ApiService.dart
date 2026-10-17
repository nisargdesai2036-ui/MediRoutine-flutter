import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Automatically choose base URL based on platform
  // Android Emulator uses 10.0.2.2 to access host PC's localhost
  // Web, iOS Simulator, and Desktop use localhost
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:8080";
    }
    try {
      if (Platform.isAndroid) {
        return "http://10.0.2.2:8080";
      }
    } catch (_) {
      // Fallback for platforms where dart:io Platform is not available
    }
    return "http://localhost:8080";
  }

  static const Duration _timeout = Duration(seconds: 10);

  static Future<dynamic> get(String endpoint) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final response = await http
        .get(Uri.parse("$baseUrl$cleanEndpoint"))
        .timeout(_timeout);

    return handleResponse(response);
  }

  static Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    //check starting parameter url should be with endpoint.
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';

    final response = await http
        .patch(
          Uri.parse("$baseUrl$cleanEndpoint"),
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(data),
        )
        .timeout(_timeout);

    return handleResponse(response);
  }


  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final response = await http
        .post(
          Uri.parse("$baseUrl$cleanEndpoint"),
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(data),
        )
        .timeout(_timeout);

    return handleResponse(response);
  }

  static Future<dynamic> delete(String endpoint, int id) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final response = await http
        .delete(Uri.parse("$baseUrl$cleanEndpoint/$id"))
        .timeout(_timeout);

    return handleResponse(response);
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final response = await http
        .put(
          Uri.parse("$baseUrl$cleanEndpoint"),
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(data),
        )
        .timeout(_timeout);

    return handleResponse(response);
  }



  static dynamic handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return response.body;
      }
    }

    String errorMessage = "Request failed: ${response.statusCode}";
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded.containsKey('message')) {
        errorMessage = decoded['message'].toString();
      } else if (response.body.isNotEmpty) {
        errorMessage = response.body;
      }
    } catch (_) {
      if (response.body.isNotEmpty) {
        errorMessage = response.body;
      }
    }

    throw Exception(errorMessage);
  }
}
