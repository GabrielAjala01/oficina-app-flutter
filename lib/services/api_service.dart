import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl = 'http://localhost:8080/api';
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    String? token = await _storage.read(key: 'jwt_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  //GET
  Future<http.Response> getRequest(String endpoint) async {
    final headers = await _getHeaders();
    return await http.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
  }

  //POST
  Future<http.Response> postRequest(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  //PUT
  Future<http.Response> putRequest(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    return await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  //DELETE
  Future<http.Response> deleteRequest(String endpoint) async {
    final headers = await _getHeaders();
    return await http.delete(Uri.parse('$baseUrl$endpoint'), headers: headers);
  }

  //PUT
  Future<http.Response> putListRequest(String endpoint, List<dynamic> body) async {
    final headers = await _getHeaders();
    return await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }
}