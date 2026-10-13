import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/product.dart';

/// Foto produk. Jika belum ada imageUrl, tampil kotak placeholder.
class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.product, this.width, this.height = 68});

  final Product product;
  final double? width;
  final double height;

  Widget _placeholder() => const ColoredBox(
        color: AppColors.soft,
        child: Center(child: Icon(Icons.checkroom, color: AppColors.muted)),
      );

  @override
  Widget build(BuildContext context) {
    final url = product.imageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: width,
        height: height,
        child: url == null
            ? _placeholder()
            : Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder()),
      ),
    );
  }
}
