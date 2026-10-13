import '../core/format.dart';
import '../models/product.dart';

/// Hasil rekomendasi: daftar item + penjelasan singkat.
class OutfitRecommendation {
  const OutfitRecommendation({required this.items, required this.explanation});

  final List<Product> items;
  final String explanation;

  int get total => items.fold(0, (sum, p) => sum + p.price);
}

/// Otak rekomendasi. Alurnya (pendekatan hybrid):
///   1. FILTER    : ambil produk yang cocok dengan acara.
///   2. OPTIMASI  : pilih kombinasi terbaik yang tidak melewati budget.
///   3. PENJELASAN: teks alasan (bisa diganti panggilan ke Gemini).
class RecommendationService {
  OutfitRecommendation? recommend({
    required List<Product> catalog,
    required int budget,
    required Occasion occasion,
  }) {
    // Langkah 1: filter per kategori.
    final options = {
      for (final category in ProductCategory.values)
        category: catalog
            .where((p) => p.category == category && p.occasions.contains(occasion))
            .toList(),
    };

    // Langkah 2: cari kombinasi terbaik (katalog kecil, jadi cukup dicoba semua).
    // Skor: makin lengkap outfit-nya makin bagus, lalu makin dekat ke budget.
    List<Product>? best;
    var bestScore = -1;

    void search(int index, List<Product> chosen, int total) {
      if (index == ProductCategory.values.length) {
        final score = chosen.length * 1000000 + total;
        if (score > bestScore) {
          bestScore = score;
          best = List.of(chosen);
        }
        return;
      }
      final category = ProductCategory.values[index];
      for (final product in options[category]!) {
        if (total + product.price <= budget) {
          chosen.add(product);
          search(index + 1, chosen, total + product.price);
          chosen.removeLast();
        }
      }
      // Aksesori boleh dilewati, kategori lain wajib ada.
      if (category == ProductCategory.accessory) {
        search(index + 1, chosen, total);
      }
    }

    search(0, [], 0);

    final result = best;
    if (result == null) return null;
    return OutfitRecommendation(
      items: result,
      explanation: _explain(result, occasion, budget),
    );
  }

  // Langkah 3: penjelasan. Ganti dengan panggilan Gemini jika ingin
  // bahasa yang lebih natural. Kirim daftar item + acara sebagai prompt.
  String _explain(List<Product> items, Occasion occasion, int budget) {
    final total = items.fold(0, (sum, p) => sum + p.price);
    return 'Semua item cocok untuk ${occasion.label.toLowerCase()}, '
        'dan totalnya ${formatRupiah(total)} masih di dalam budget '
        '${formatRupiah(budget)}.';
  }
}
