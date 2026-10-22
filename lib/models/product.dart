import 'package:flutter/material.dart';

enum ProductCategory {
  top('Atasan'),
  bottom('Bawahan'),
  shoes('Alas kaki'),
  accessory('Aksesori');

  const ProductCategory(this.label);
  final String label;
}

enum Occasion {
  kuliah('Kuliah'),
  wawancara('Wawancara'),
  kondangan('Kondangan'),
  hangout('Hangout'),
  olahraga('Olahraga');

  const Occasion(this.label);
  final String label;
}

/// Satu produk di katalog toko.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.color,
    required this.occasions,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawCategory = json['category'];
    final category = _categoryFromValue(rawCategory);
    final rawPrice = json['price'];
    final rawId = json['id'];

    return Product(
      id: rawId?.toString() ?? '',
      name: (json['name'] ?? 'Produk').toString(),
      category: category,
      price: _parseInt(rawPrice),
      color: _parseColor(json['color']) ?? _fallbackColor(category),
      occasions:
          _parseOccasions(json['occasions']) ?? _defaultOccasions(category),
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? json['image_path'],
    );
  }

  static ProductCategory _categoryFromValue(dynamic rawCategory) {
    final value = rawCategory is Map
        ? rawCategory['body_zone'] ?? rawCategory['name']
        : rawCategory;
    final normalized = (value ?? 'upper').toString().trim().toLowerCase();

    switch (normalized) {
      case 'upper':
      case 'atasan':
      case 'top':
        return ProductCategory.top;
      case 'lower':
      case 'bawahan':
      case 'bottom':
        return ProductCategory.bottom;
      case 'feet':
      case 'shoes':
      case 'sepatu':
        return ProductCategory.shoes;
      case 'accessory':
      case 'aksesori':
      case 'outer':
        return ProductCategory.accessory;
      default:
        return ProductCategory.top;
    }
  }

  static Set<Occasion>? _parseOccasions(dynamic rawOccasions) {
    if (rawOccasions is! List || rawOccasions.isEmpty) return null;

    final occasions = <Occasion>{};
    for (final item in rawOccasions) {
      final value = item.toString().trim().toLowerCase();
      switch (value) {
        case 'kuliah':
          occasions.add(Occasion.kuliah);
          break;
        case 'wawancara':
          occasions.add(Occasion.wawancara);
          break;
        case 'kondangan':
          occasions.add(Occasion.kondangan);
          break;
        case 'hangout':
        case 'hang out':
          occasions.add(Occasion.hangout);
          break;
        case 'olahraga':
          occasions.add(Occasion.olahraga);
          break;
      }
    }

    return occasions;
  }

  static Set<Occasion> _defaultOccasions(ProductCategory category) {
    switch (category) {
      case ProductCategory.top:
        return {Occasion.kuliah, Occasion.hangout};
      case ProductCategory.bottom:
        return {Occasion.kuliah, Occasion.wawancara};
      case ProductCategory.shoes:
        return {Occasion.kuliah, Occasion.hangout};
      case ProductCategory.accessory:
        return {Occasion.kondangan, Occasion.wawancara};
    }
  }

  static Color? _parseColor(dynamic rawColor) {
    if (rawColor == null) return null;
    if (rawColor is int) return Color(rawColor);
    if (rawColor is String) {
      final value = rawColor.trim();
      final hex = value.replaceAll('#', '');
      if (hex.length == 6 || hex.length == 8) {
        final parsed = int.tryParse('FF$hex', radix: 16);
        if (parsed != null) return Color(parsed);
      }
    }
    return null;
  }

  static Color _fallbackColor(ProductCategory category) {
    switch (category) {
      case ProductCategory.top:
        return const Color(0xFFB7C3D9);
      case ProductCategory.bottom:
        return const Color(0xFF4D5E7A);
      case ProductCategory.shoes:
        return const Color(0xFF2B2B2B);
      case ProductCategory.accessory:
        return const Color(0xFF8A674E);
    }
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String)
      return int.tryParse(value.replaceAll('.', '').replaceAll(',', '')) ?? 0;
    return 0;
  }

  final String id;
  final String name;
  final ProductCategory category;
  final int price; // dalam rupiah
  final Color color; // dipakai untuk mewarnai manekin
  final Set<Occasion> occasions; // tag acara yang cocok
  final String? imageUrl; // isi dengan foto produk asli dari katalog
}
