import 'package:flutter/material.dart';

import '../models/product.dart';

/// Data contoh. Ganti dengan data katalog toko (API atau database).
final List<Product> sampleProducts = const [
  // Atasan
  Product(id: 't1', name: 'Kemeja putih', category: ProductCategory.top, price: 149000, color: Colors.white, occasions: {Occasion.wawancara, Occasion.kondangan, Occasion.kuliah}),
  Product(id: 't2', name: 'Kemeja batik', category: ProductCategory.top, price: 199000, color: Color(0xFF8A5A2B), occasions: {Occasion.kondangan}),
  Product(id: 't3', name: 'Kaos polos hitam', category: ProductCategory.top, price: 79000, color: Color(0xFF222222), occasions: {Occasion.hangout, Occasion.kuliah}),
  Product(id: 't4', name: 'Kaos olahraga', category: ProductCategory.top, price: 89000, color: Color(0xFF2E7D6B), occasions: {Occasion.olahraga}),
  Product(id: 't5', name: 'Polo navy', category: ProductCategory.top, price: 129000, color: Color(0xFF1F3A5F), occasions: {Occasion.kuliah, Occasion.hangout, Occasion.wawancara}),
  // Bawahan
  Product(id: 'b1', name: 'Celana chino navy', category: ProductCategory.bottom, price: 139000, color: Color(0xFF1F3A5F), occasions: {Occasion.wawancara, Occasion.kuliah, Occasion.hangout}),
  Product(id: 'b2', name: 'Celana bahan hitam', category: ProductCategory.bottom, price: 169000, color: Color(0xFF1A1A1A), occasions: {Occasion.wawancara, Occasion.kondangan}),
  Product(id: 'b3', name: 'Jeans biru', category: ProductCategory.bottom, price: 159000, color: Color(0xFF3D5A80), occasions: {Occasion.kuliah, Occasion.hangout}),
  Product(id: 'b4', name: 'Celana training', category: ProductCategory.bottom, price: 99000, color: Color(0xFF333A45), occasions: {Occasion.olahraga}),
  // Alas kaki
  Product(id: 's1', name: 'Loafer hitam', category: ProductCategory.shoes, price: 129000, color: Color(0xFF111111), occasions: {Occasion.wawancara, Occasion.kondangan}),
  Product(id: 's2', name: 'Sneakers putih', category: ProductCategory.shoes, price: 249000, color: Color(0xFFF1F1F1), occasions: {Occasion.kuliah, Occasion.hangout}),
  Product(id: 's3', name: 'Sepatu lari', category: ProductCategory.shoes, price: 299000, color: Color(0xFFE4572E), occasions: {Occasion.olahraga}),
  // Aksesori
  Product(id: 'a1', name: 'Sabuk kulit', category: ProductCategory.accessory, price: 49000, color: Color(0xFF3B2F2F), occasions: {Occasion.wawancara, Occasion.kondangan}),
  Product(id: 'a2', name: 'Topi hitam', category: ProductCategory.accessory, price: 59000, color: Color(0xFF222222), occasions: {Occasion.hangout, Occasion.olahraga}),
];
