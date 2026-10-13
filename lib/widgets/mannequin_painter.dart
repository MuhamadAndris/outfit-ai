import 'package:flutter/material.dart';

import '../models/product.dart';

/// Menggambar manekin sederhana, lalu mewarnai bagian tubuhnya
/// sesuai warna produk yang dipilih.
/// (Versi lanjutan: tempel foto produk asli di atas manekin.)
class MannequinPainter extends CustomPainter {
  MannequinPainter({this.top, this.bottom, this.shoes, this.accessory});

  final Product? top;
  final Product? bottom;
  final Product? shoes;
  final Product? accessory;

  static const _outline = Color(0xFFB8C0CE);
  static const _skin = Color(0xFFC9CFDA);
  static const _empty = Color(0xFFD5DAE3); // warna bagian yang belum dipilih

  RRect _box(double x, double y, double w, double h, double r) =>
      RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));

  void _draw(Canvas canvas, RRect shape, Color fill) {
    canvas.drawRRect(shape, Paint()..color = fill);
    canvas.drawRRect(
      shape,
      Paint()
        ..color = _outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Desain digambar di kotak 200x345, lalu diskalakan sesuai ukuran layar.
    final scale = size.height / 345;
    canvas.save();
    canvas.translate((size.width - 200 * scale) / 2, 0);
    canvas.scale(scale);

    final topColor = top?.color ?? _empty;
    final bottomColor = bottom?.color ?? _empty;
    final shoesColor = shoes?.color ?? _empty;

    // Kepala dan leher
    final skin = Paint()..color = _skin;
    canvas.drawOval(Rect.fromCenter(center: const Offset(100, 34), width: 44, height: 52), skin);
    canvas.drawRect(const Rect.fromLTWH(92, 58, 16, 16), skin);

    // Lengan, celana, badan (urutan penting: yang terakhir tampil di atas)
    _draw(canvas, _box(38, 80, 22, 100, 11), topColor);
    _draw(canvas, _box(140, 80, 22, 100, 11), topColor);
    _draw(canvas, _box(58, 191, 41, 122, 6), bottomColor);
    _draw(canvas, _box(101, 191, 41, 122, 6), bottomColor);
    _draw(canvas, _box(56, 74, 88, 112, 16), topColor);

    // Sepatu
    _draw(canvas, _box(52, 313, 48, 18, 9), shoesColor);
    _draw(canvas, _box(100, 313, 48, 18, 9), shoesColor);

    // Aksesori: topi di kepala, selain itu digambar sebagai sabuk
    final acc = accessory;
    if (acc != null) {
      if (acc.name.toLowerCase().contains('topi')) {
        _draw(canvas, _box(76, 6, 48, 16, 8), acc.color);
      } else {
        _draw(canvas, _box(56, 182, 88, 9, 2), acc.color);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(MannequinPainter old) =>
      old.top != top || old.bottom != bottom || old.shoes != shoes || old.accessory != accessory;
}
