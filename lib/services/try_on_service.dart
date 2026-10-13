import 'dart:typed_data';

import '../models/product.dart';

/// Kontrak untuk fitur "pakai di foto saya".
/// Layar pratinjau cukup memanggil [generate], tidak peduli AI apa di belakangnya.
abstract class TryOnService {
  Future<Uint8List> generate({
    required Uint8List userPhoto,
    required List<Product> items,
  });
}

/// TODO: sambungkan ke Gemini (kirim foto pengguna + foto produk dari katalog,
/// lalu terima gambar hasilnya).
class GeminiTryOnService implements TryOnService {
  @override
  Future<Uint8List> generate({
    required Uint8List userPhoto,
    required List<Product> items,
  }) {
    throw UnimplementedError('Sambungkan ke Gemini API di sini.');
  }
}
