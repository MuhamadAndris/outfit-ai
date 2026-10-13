import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/format.dart';
import '../models/product.dart';
import '../state/outfit_controller.dart';
import '../widgets/primary_button.dart';
import 'catalog_screen.dart';
import 'result_screen.dart';

/// Layar 1: pilih mode (AI atau pilih sendiri), isi budget dan acara.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});

  final OutfitController controller;

  void _onContinue(BuildContext context) {
    if (controller.mode == PlanMode.manual) {
      controller.clearSelection();
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => CatalogScreen(controller: controller)));
      return;
    }

    final found = controller.findRecommendation();
    if (!found) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Belum ada outfit yang cocok dengan budget ini. Coba naikkan budget.'),
      ));
      return;
    }
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => ResultScreen(controller: controller)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final isAi = controller.mode == PlanMode.ai;
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Mau tampil untuk apa?',
                              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, height: 1.2)),
                          const SizedBox(height: 8),
                          const Text('Isi budget dan acaranya, kami pilihkan outfit dari katalog toko.',
                              style: TextStyle(fontSize: 15, color: AppColors.muted, height: 1.5)),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: SegmentedButton<PlanMode>(
                              segments: const [
                                ButtonSegment(value: PlanMode.ai, label: Text('Rekomendasi AI')),
                                ButtonSegment(value: PlanMode.manual, label: Text('Pilih sendiri')),
                              ],
                              selected: {controller.mode},
                              onSelectionChanged: (s) => controller.setMode(s.first),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const _SectionLabel('Budget kamu'),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: cardDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(formatRupiah(controller.budget),
                                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                                Slider(
                                  value: controller.budget.toDouble(),
                                  min: 100000,
                                  max: 1000000,
                                  divisions: 18,
                                  onChanged: (v) => controller.setBudget(v.round()),
                                ),
                              ],
                            ),
                          ),
                          if (isAi) ...[
                            const SizedBox(height: 24),
                            const _SectionLabel('Acara'),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                for (final o in Occasion.values)
                                  ChoiceChip(
                                    label: Text(o.label),
                                    selected: controller.occasion == o,
                                    onSelected: (_) => controller.setOccasion(o),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: isAi ? 'Cari rekomendasi' : 'Pilih produk',
                    onPressed: () => _onContinue(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.muted)),
      );
}
