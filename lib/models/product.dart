import 'package:flutter/material.dart';

enum ProductCategory {
  top('Atasan'),
  bottom('Bawahan'),
  shoes('Alas kaki'),
  accessory('Aksesori');

  const ProductCategory(this.label);
  final String label;
}

/// Satu produk di katalog toko.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.imageUrl,
  });

  // NOTE: NEXT LANJUT BUAT HAPUS SEMUA ELEMENT YANG TIDAK DI PAKAI, CONTOH SEPERTI YANG ADA DIPRODUK INI, SAMAKAN DENGAN YANG DI DB

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
  final String? imageUrl; // isi dengan foto produk asli dari katalog
}
