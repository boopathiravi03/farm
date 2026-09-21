import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class MarketApi {
  static const String baseUrl =
      "https://farm-trading-backend.onrender.com/api";

  static Future<String?> get token => AuthService.getToken();

  static Map<String, String> headers(String jwt) {
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $jwt",
    };
  }

  static Future<List<dynamic>> searchCrops(
    String query,
    String jwt,
  ) async {
    if (query.trim().length < 2) {
      return [];
    }

    final response = await http.get(
      Uri.parse(
        "$baseUrl/market-prices/search?q=${Uri.encodeComponent(query)}",
      ),
      headers: headers(jwt),
    );

    if (response.statusCode != 200) {
      throw Exception("Unable to search crops");
    }

    final data = jsonDecode(response.body);

    return data["prices"] ?? [];
  }

  static Future<Map<String, dynamic>> getCropPrice(
    String cropName,
    String jwt,
  ) async {
    final response = await http.get(
      Uri.parse(
        "$baseUrl/market-prices/${Uri.encodeComponent(cropName)}",
      ),
      headers: headers(jwt),
    );

    if (response.statusCode != 200) {
      throw Exception("Market price not found");
    }

    final data = jsonDecode(response.body);

    return data["price"];
  }
}

