import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';

/// Hasil rekomendasi: daftar item + penjelasan singkat.
class OutfitRecommendation {
  const OutfitRecommendation({
    required this.items,
    required this.explanation,
    required this.generatedImageURL,
  });

  final List<Product> items;
  final String explanation;
  final String generatedImageURL;

  int get total => items.fold(0, (sum, p) => sum + p.price);
}

/// Service untuk meminta rekomendasi dari backend.
class RecommendationService {
  RecommendationService({String? baseUrl, http.Client? client})
    : _baseUrl = baseUrl ?? _defaultBaseUrl(),
      _client = client ?? http.Client();

  final String _baseUrl;
  final http.Client _client;

  static String _defaultBaseUrl() {
    if (kIsWeb) return 'http://localhost:8000';

    const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (apiBaseUrl.isNotEmpty) return apiBaseUrl;

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }

    return 'http://localhost:8000';
  }

  Future<OutfitRecommendation?> recommend({
    required int budget,
    required String prompt,
    String mode = 'mannequin',
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/api/v1/recommendations'),
    );

    request.headers['Accept'] = 'application/json';
    request.fields['prompt'] = prompt;
    request.fields['budget'] = budget.toString();
    request.fields['mode'] = mode;

    // DEBUG: tampilkan request yang akan dikirim
    debugPrint('========== REQUEST BACKEND ==========');
    debugPrint('URL: ${request.url}');
    debugPrint('Method: ${request.method}');
    debugPrint('Headers: ${request.headers}');
    debugPrint('Fields:');

    request.fields.forEach((key, value) {
      debugPrint('  $key: $value');
    });

    debugPrint('=====================================');

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Gagal mendapatkan rekomendasi '
        '(${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    // Sementara tampilkan respons API untuk diperiksa.
    debugPrint('Response rekomendasi: $decoded');

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Format data rekomendasi tidak valid');
    }

    final rawItems = decoded['items'] ?? decoded['recommendations'];
    if (rawItems is! List || rawItems.isEmpty) {
      return null;
    }

    final products = <Product>[];
    final reasons = <String>[];
    final String generatedImageURL = decoded['generated_image_url'] ?? '';

    for (final item in rawItems) {
      if (item is! Map) continue;

      final itemPayload = item['item'] ?? item;
      if (itemPayload is Map) {
        products.add(Product.fromJson(Map<String, dynamic>.from(itemPayload)));
      }

      final reason = item['reason'];
      if (reason is String && reason.trim().isNotEmpty) {
        reasons.add(reason.trim());
      }
    }

    if (products.isEmpty) {
      return null;
    }

    final explanation = reasons.isNotEmpty
        ? reasons.join(' ')
        : 'Rekomendasi otomatis untuk ${prompt.toString()} berdasarkan budget Anda.';

    return OutfitRecommendation(
      items: products,
      explanation: explanation,
      generatedImageURL: generatedImageURL,
    );
  }
}
