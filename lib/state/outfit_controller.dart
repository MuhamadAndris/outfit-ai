import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:outfit_ai/widgets/pick_image.dart';

import '../models/product.dart';
import '../services/recommendation_service.dart';

enum PlanMode { ai, manual }

enum PreviewMode { mannequin, user_photo }

/// Menyimpan semua data yang dipakai lintas layar:
/// Layar cukup mendengarkan controller ini (lihat ListenableBuilder).
class OutfitController extends ChangeNotifier {
  OutfitController({RecommendationService? service})
    : _service = service ?? RecommendationService() {
    _syncRequestPrompt();
  }

  final RecommendationService _service;

  PlanMode mode = PlanMode.ai;
  PreviewMode previewMode = PreviewMode.mannequin;
  int budget = 500000;
  String prompt = '';
  String gender = 'Laki-laki';
  String style = 'Formal';
  String requestPrompt = '';
  String prevPrompt = '';
  File? selectedImage;
  List<Product> selected = const [];
  OutfitRecommendation? recommendation;
  String generatedImageURL = '';
  List<String> prevCombinationCode = [];

  int get total => selected.fold(0, (sum, p) => sum + p.price);
  int get remaining => budget - total;
  bool get isOverBudget => remaining < 0;

  Future<void> selectImage() async {
    final image = await pickImage();

    if (image != null) {
      selectedImage = image;
      notifyListeners();
    }
  }

  void setMode(PlanMode value) {
    mode = value;
    notifyListeners();
  }

  void setPreviewMode(PreviewMode value) {
    previewMode = value;
    notifyListeners();
  }

  void setBudget(int value) {
    budget = value;
    notifyListeners();
  }

  void _syncRequestPrompt() {
    requestPrompt = [
      prompt.trim(),
      style.trim(),
      gender.trim(),
    ].where((value) => value.isNotEmpty).join(', ');
  }

  void setPrompt(String value) {
    prompt = value;
    _syncRequestPrompt();
    notifyListeners();
  }

  void setGender(String value) {
    gender = value;
    _syncRequestPrompt();
    notifyListeners();
  }

  void setStyle(String value) {
    style = value;
    _syncRequestPrompt();
    notifyListeners();
  }

  Future<bool> findRecommendation({bool refresh = false}) async {
    recommendation = await _service.recommend(
      budget: budget,
      prompt: requestPrompt,
      prevCombinationCode: refresh ? prevCombinationCode : [],
      refresh: refresh,
      mode: previewMode,
      userPhoto: selectedImage,
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
