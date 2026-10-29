import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/format.dart';
import '../models/product.dart';
import '../state/outfit_controller.dart';
import '../widgets/primary_button.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key, required this.controller});

  final OutfitController controller;

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  List<Product> get _items => widget.controller.selected;

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Scaffold(
      appBar: AppBar(title: const Text('Pratinjau outfit')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.soft,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: _mannequin(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_items.length} item · ${formatRupiah(c.total)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  c.isOverBudget
                      ? 'Melebihi budget ${formatRupiah(-c.remaining)}'
                      : 'Sisa ${formatRupiah(c.remaining)}',
                  style: TextStyle(
                    color: c.isOverBudget ? AppColors.accent : AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Warna dan potongan mengikuti foto produk asli di katalog toko.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.muted,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Tambah semua ke keranjang',
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Keranjang belum dibuat. Sambungkan ke sistem toko.',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mannequin() => SizedBox(
    width: double.infinity,
    height: double.infinity,
    child: Image.network(
      widget.controller.generatedImageURL,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        return const Center(child: Text('Gagal memuat gambar'));
      },
    ),
  );
}
