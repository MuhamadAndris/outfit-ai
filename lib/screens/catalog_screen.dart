import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/format.dart';
import '../models/product.dart';
import '../state/outfit_controller.dart';
import '../widgets/primary_button.dart';
import '../widgets/product_card.dart';
import 'preview_screen.dart';
import '../services/product_service.dart';

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

  final ProductService _productService = ProductService();

  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;

  OutfitController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    debugPrint('[CatalogScreen] Mulai memuat produk...');
    debugPrint('[CatalogScreen] Memanggil ProductService.fetchProduct()');

    try {
      final products = await _productService.fetchProduct();

      debugPrint('[CatalogScreen] Berhasil menerima data backend');
      debugPrint('[CatalogScreen] Jumlah produk: ${products.length}');

      // Tampilkan detail produk yang diterima.
      for (final product in products) {
        debugPrint(
          '[CatalogScreen] '
          'Nama: ${product.name} | '
          'Kategori: ${product.category}',
        );
      }

      if (!mounted) {
        debugPrint(
          '[CatalogScreen] Widget sudah tidak aktif, '
          'setState dibatalkan.',
        );
        return;
      }

      setState(() {
        _products = products;
        _isLoading = false;
        _error = null;
      });

      debugPrint(
        '[CatalogScreen] State diperbarui. '
        'Total produk di katalog: ${_products.length}',
      );
    } catch (e, stackTrace) {
      debugPrint('[CatalogScreen] GAGAL memuat produk: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      debugPrint('[CatalogScreen] Error ditampilkan di UI: $_error');
    }
  }

  List<Product> get _visibleProducts => _products.where((p) {
    final matchCategory = _category == null || p.category == _category;

    final matchQuery = p.name.toLowerCase().contains(_query.toLowerCase());

    return matchCategory && matchQuery;
  }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih sendiri')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Gagal mengambil produk'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _isLoading = true);
                      _loadProducts();
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          : ListenableBuilder(
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
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 44,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _filterChip(
                              'Semua',
                              _category == null,
                              () => setState(() => _category = null),
                            ),
                            for (final cat in ProductCategory.values)
                              _filterChip(
                                cat.label,
                                _category == cat,
                                () => setState(() => _category = cat),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: GridView.builder(
                          itemCount: products.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
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
                                MaterialPageRoute(
                                  builder: (_) => PreviewScreen(controller: _c),
                                ),
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) =>
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onTap(),
        ),
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
              Text(
                '${_c.selected.length} item dipilih',
                style: const TextStyle(fontSize: 13, color: AppColors.muted),
              ),
              Text(
                formatRupiah(_c.total),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
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
