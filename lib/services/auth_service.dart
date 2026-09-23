import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // !!!!!!!!! se for testar no celular trocar essa porra de IP pelo do pc !!!!!!!!!!!!!!!!!!!!!!!!!!!!
  final String baseUrl = 'http://localhost:8080/api/auth';
  final storage = const FlutterSecureStorage();

  Future<bool> login(String login, String senha) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'login': login,
          'senha': senha,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // salva o token
        await storage.write(key: 'jwt_token', value: data['token']);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Erro de conexão: $e');
      return false;
    }
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'jwt_token');
  }

  Future<void> logout() async {
    await storage.delete(key: 'jwt_token');
  }
}