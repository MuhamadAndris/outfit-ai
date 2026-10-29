import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';

class TryOn {
  TryOn({required this.generatedImageURL});

  final String generatedImageURL;
}

class TryOnService {
  TryOnService({String? baseUrl, http.Client? client})
    : _baseUrl = baseUrl ?? _defaultBaseUrl(),
      _client = client ?? http.Client() {
    debugPrint('[TryOnService] Base URL: $_baseUrl');
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
      return 'http://10.0.2.2:8000';
    }

    return 'http://localhost:8000';
  }

  Future<TryOn?> tryOnOutfit({
    required List<Product> productSelected,
    String mode = 'mannequin',
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/api/v1/outfits/try-on'),
    );

    request.headers['Accept'] = 'application/json';

    final slotIds = <String, String>{
      'atasan_id': '',
      'bawahan_id': '',
      'alas_kaki_id': '',
      'kacamata_id': '',
      'topi_id': '',
    };

    for (final product in productSelected) {
      final fieldName = product.tryOnFieldName;
      if (fieldName == null || fieldName.isEmpty) continue;
      if (slotIds.containsKey(fieldName)) {
        slotIds[fieldName] = product.id;
      }
    }

    slotIds.forEach((fieldName, value) {
      if (value.isNotEmpty) {
        request.fields[fieldName] = value;
      }
    });

    request.fields['mode'] = mode;

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Gagal membuat preview: ${response.body}');
    }

    final decode = jsonDecode(response.body);
    final imgUrl =
        decode['generated_image_url'] ?? decode['generated_image_path'] ?? '';

    debugPrint('===================================');
    debugPrint(decode.toString());
    debugPrint('===================================');

    return TryOn(generatedImageURL: imgUrl);
  }
}
