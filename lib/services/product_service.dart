import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:outfit_ai/models/product.dart';

class ProductService {
  ProductService({String? baseUrl, http.Client? client})
    : _baseUrl = baseUrl ?? _defaultBaseUrl(),
      _client = client ?? http.Client();

  final String _baseUrl;
  final http.Client _client;

  static String _defaultBaseUrl() {
    if (kIsWeb) return 'http://localhost:8000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://localhost:8000';
  }

  Future<List<Product>> fetchProduct() async {
    final response = await _client.get(Uri.parse('$_baseUrl/api/v1/items'));

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil produk (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const FormatException('Format data produk tidak valid');
    }

    return decoded
        .map((item) => Product.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}
