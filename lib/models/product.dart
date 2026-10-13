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

  final String id;
  final String name;
  final ProductCategory category;
  final int price; // dalam rupiah
  final Color color; // dipakai untuk mewarnai manekin
  final Set<Occasion> occasions; // tag acara yang cocok
  final String? imageUrl; // isi dengan foto produk asli dari katalog
}
