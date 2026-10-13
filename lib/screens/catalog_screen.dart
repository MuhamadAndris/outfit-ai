import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/format.dart';
import '../models/product.dart';
import '../state/outfit_controller.dart';
import '../widgets/primary_button.dart';
import '../widgets/product_card.dart';
import 'preview_screen.dart';

/// Layar 2b: pelanggan memilih produk sendiri dari katalog.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, required this.controller});

  final OutfitController controller;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String _query = '';
  ProductCategory? _category; // null = semua kategori

  OutfitController get _c => widget.controller;

  List<Product> get _visibleProducts => _c.catalog.where((p) {
        final matchCategory = _category == null || p.category == _category;
        final matchQuery = p.name.toLowerCase().contains(_query.toLowerCase());
        return matchCategory && matchQuery;
      }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih sendiri')),
      body: ListenableBuilder(
        listenable: _c,
        builder: (context, _) {
          final products = _visibleProducts;
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              children: [
                TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Cari produk',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _filterChip('Semua', _category == null, () => setState(() => _category = null)),
                      for (final cat in ProductCategory.values)
                        _filterChip(cat.label, _category == cat, () => setState(() => _category = cat)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    itemCount: products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (context, i) => ProductCard(
                      product: products[i],
                      selected: _c.isSelected(products[i]),
                      onTap: () => _c.toggleProduct(products[i]),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _summary(),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Lihat pratinjau',
                  onPressed: _c.selected.isEmpty
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PreviewScreen(controller: _c)),
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onTap()),
      );

  Widget _summary() {
    final over = _c.isOverBudget;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${_c.selected.length} item dipilih',
                  style: const TextStyle(fontSize: 13, color: AppColors.muted)),
              Text(formatRupiah(_c.total),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          Text(
            over
                ? 'Melebihi budget ${formatRupiah(-_c.remaining)}'
                : 'Sisa budget ${formatRupiah(_c.remaining)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: over ? AppColors.accent : AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
