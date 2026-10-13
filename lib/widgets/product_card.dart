import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/format.dart';
import '../models/product.dart';
import 'product_image.dart';

/// Kartu produk di grid katalog. Tap untuk memilih atau membatalkan.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.selected,
    required this.onTap,
  });

  final Product product;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: cardDecoration(selected: selected),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ProductImage(product: product, width: double.infinity, height: double.infinity),
                  if (selected)
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        radius: 13,
                        backgroundColor: AppColors.accent,
                        child: Icon(Icons.check, size: 16, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            Text(formatRupiah(product.price),
                style: const TextStyle(fontSize: 13, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}
