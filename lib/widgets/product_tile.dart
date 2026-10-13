import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/format.dart';
import '../models/product.dart';
import 'product_image.dart';

/// Baris produk (dipakai di layar hasil rekomendasi).
class ProductTile extends StatelessWidget {
  const ProductTile({super.key, required this.product, this.subtitle});

  final Product product;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: cardDecoration(),
      child: Row(
        children: [
          ProductImage(product: product, width: 68),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(subtitle!,
                        style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                  ),
              ],
            ),
          ),
          Text(formatRupiah(product.price),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
