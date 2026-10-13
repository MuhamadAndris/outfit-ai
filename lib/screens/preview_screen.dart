import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/app_theme.dart';
import '../core/format.dart';
import '../models/product.dart';
import '../state/outfit_controller.dart';
import '../widgets/mannequin_painter.dart';
import '../widgets/primary_button.dart';

enum _PreviewTarget { mannequin, photo }

/// Layar 3: lihat produk terpilih di manekin atau di foto badan sendiri.
class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key, required this.controller});

  final OutfitController controller;

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  _PreviewTarget _target = _PreviewTarget.mannequin;
  Uint8List? _photo;

  List<Product> get _items => widget.controller.selected;

  /// Ambil produk dari satu kategori, atau null jika tidak ada.
  Product? _pick(ProductCategory category) {
    for (final p in _items) {
      if (p.category == category) return p;
    }
    return null;
  }

  Future<void> _pickPhoto() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() => _photo = bytes);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Scaffold(
      appBar: AppBar(title: const Text('Pratinjau outfit')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<_PreviewTarget>(
                segments: const [
                  ButtonSegment(value: _PreviewTarget.mannequin, label: Text('Manekin')),
                  ButtonSegment(value: _PreviewTarget.photo, label: Text('Foto saya')),
                ],
                selected: {_target},
                onSelectionChanged: (s) => setState(() => _target = s.first),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.soft,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: _target == _PreviewTarget.mannequin ? _mannequin() : _photoView(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_items.length} item · ${formatRupiah(c.total)}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                Text('Sisa ${formatRupiah(c.remaining)}',
                    style: const TextStyle(color: AppColors.muted)),
              ],
            ),
            const SizedBox(height: 6),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Warna dan potongan mengikuti foto produk asli di katalog toko.',
                style: TextStyle(fontSize: 12, color: AppColors.muted, height: 1.5),
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Tambah semua ke keranjang',
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Keranjang belum dibuat. Sambungkan ke sistem toko.')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mannequin() => Center(
        child: SizedBox(
          width: 190,
          height: 330,
          child: CustomPaint(
            painter: MannequinPainter(
              top: _pick(ProductCategory.top),
              bottom: _pick(ProductCategory.bottom),
              shoes: _pick(ProductCategory.shoes),
              accessory: _pick(ProductCategory.accessory),
            ),
          ),
        ),
      );

  Widget _photoView() {
    final photo = _photo;
    if (photo == null) {
      return Center(
        child: OutlinedButton.icon(
          onPressed: _pickPhoto,
          icon: const Icon(Icons.photo_library_outlined),
          label: const Text('Pilih foto badan'),
        ),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.memory(photo, fit: BoxFit.cover),
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: const Text(
              'Pratinjau AI belum tersambung. Isi GeminiTryOnService di lib/services/try_on_service.dart.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
