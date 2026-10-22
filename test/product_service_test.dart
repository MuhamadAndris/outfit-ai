import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:outfit_ai/models/product.dart';
import 'package:outfit_ai/services/product_service.dart';

void main() {
  group('ProductService', () {
    test('maps backend item payload into Product model', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), contains('/api/v1/items'));

        final payload = [
          {
            'id': 12,
            'name': 'Kemeja Linen Putih',
            'price': 150000,
            'description': 'Kemeja linen putih',
            'image_path': '/uploads/item-12.jpg',
            'image_url': 'http://localhost:8000/uploads/item-12.jpg',
            'category': {
              'id': 1,
              'name': 'atasan',
              'body_zone': 'upper',
              'created_at': '2026-10-23T10:00:00Z',
            },
            'created_at': '2026-10-23T10:00:00Z',
          },
        ];

        return http.Response(jsonEncode(payload), 200);
      });

      final service = ProductService(
        baseUrl: 'http://example.com',
        client: mockClient,
      );
      final products = await service.fetchProduct();

      expect(products, hasLength(1));
      expect(products.first.id, '12');
      expect(products.first.name, 'Kemeja Linen Putih');
      expect(products.first.category, ProductCategory.top);
      expect(products.first.price, 150000);
      expect(
        products.first.imageUrl,
        'http://localhost:8000/uploads/item-12.jpg',
      );
    });
  });
}
