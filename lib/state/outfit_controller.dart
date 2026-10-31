import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/recommendation_service.dart';

enum PlanMode { ai, manual }

/// Menyimpan semua data yang dipakai lintas layar:
/// Layar cukup mendengarkan controller ini (lihat ListenableBuilder).
class OutfitController extends ChangeNotifier {
  OutfitController({RecommendationService? service})
    : _service = service ?? RecommendationService();

  final RecommendationService _service;

  PlanMode mode = PlanMode.ai;
  int budget = 500000;
  String prompt = '';
  String prevPrompt = '';
  List<Product> selected = const [];
  OutfitRecommendation? recommendation;
  String generatedImageURL = '';
  List<String> prevCombinationCode = [];

  int get total => selected.fold(0, (sum, p) => sum + p.price);
  int get remaining => budget - total;
  bool get isOverBudget => remaining < 0;

  void setMode(PlanMode value) {
    mode = value;
    notifyListeners();
  }

  void setBudget(int value) {
    budget = value;
    notifyListeners();
  }

  void setPrompt(String value) {
    prompt = value;
    notifyListeners();
  }

  /// Jalur 1: minta AI. Mengembalikan false jika tidak ada outfit yang cocok.
  Future<bool> findRecommendation({bool refresh = false}) async {
    recommendation = await _service.recommend(
      budget: budget,
      prompt: prompt,
      prevCombinationCode: refresh ? prevCombinationCode : [],
      refresh: refresh,
    );
    selected = recommendation?.items ?? const [];
    generatedImageURL = recommendation?.generatedImageURL ?? '';

    recommendation?.newCombinationCode.forEach((c) {
      final exists = prevCombinationCode.any((codes) => codes == c);
      if (!exists) prevCombinationCode.add(c);
    });

    notifyListeners();
    return recommendation != null;
  }

  /// Jalur 2: pilih sendiri. Satu kategori hanya boleh satu produk.
  void toggleProduct(Product product) {
    if (selected.any((p) => p.id == product.id)) {
      selected = selected.where((p) => p.id != product.id).toList();
    } else {
      selected = [
        ...selected.where((p) => p.category != product.category),
        product,
      ];
    }
    notifyListeners();
  }

  bool isSelected(Product product) => selected.any((p) => p.id == product.id);

  void setGeneratedImageURL(String value) {
    generatedImageURL = value;
    notifyListeners();
  }

  void clearSelection() {
    selected = const [];
    recommendation = null;
    generatedImageURL = '';
    prevCombinationCode = [];
    notifyListeners();
  }
}
