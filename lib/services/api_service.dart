import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://task.itprojects.web.id/api";

  static Future<String?> login(String nim, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        "username": nim,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['token'];
    }
    return null;
  }

  static Future<List> getProducts(String token) async {
    final url = Uri.parse('$baseUrl/products');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) return data;
      if (data['data'] is List) return data['data'];
    }

    return [];
  }

  static Future<bool> createProduct(
    String token,
    String name,
    int price,
    String description,
  ) async {
    final url = Uri.parse('$baseUrl/products');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "name": name,
        "price": price,
        "description": description,
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<bool> deleteProduct(String token, int id) async {
    final url = Uri.parse('$baseUrl/products/$id');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }
}