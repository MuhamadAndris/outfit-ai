import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:outfit_ai/models/product.dart';

class ProductService {
  ProductService({String? baseUrl, http.Client? client})
    : _baseUrl = baseUrl ?? _defaultBaseUrl(),
      _client = client ?? http.Client() {
    debugPrint('[ProductService] Base URL: $_baseUrl');
  }

  final String _baseUrl;
  final http.Client _client;

  static String _defaultBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8000';
    }

    const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

    if (apiBaseUrl.isNotEmpty) {
      return apiBaseUrl;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Default untuk Android Emulator.
      return 'http://10.0.2.2:8000';
    }

    return 'http://localhost:8000';
  }

  Future<List<Product>> fetchProduct() async {
    final url = Uri.parse('$_baseUrl/api/v1/items');
    final stopwatch = Stopwatch()..start();

    debugPrint('[ProductService] GET $url');

    try {
      final response = await _client.get(url);
      stopwatch.stop();

      debugPrint('[ProductService] Status: ${response.statusCode}');
      debugPrint(
        '[ProductService] Waktu respons: ${stopwatch.elapsedMilliseconds} ms',
      );
      debugPrint(
        '[ProductService] Content-Type: ${response.headers['content-type']}',
      );
      debugPrint('[ProductService] Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal mengambil produk (${response.statusCode}): '
          '${response.body}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw const FormatException(
          'Format data produk tidak valid: respons bukan List',
        );
      }

      final products = decoded
          .map(
            (item) => Product.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();

      debugPrint('[ProductService] Berhasil parsing ${products.length} produk');

      return products;
    } catch (error, stackTrace) {
      debugPrint('[ProductService] ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }
}
