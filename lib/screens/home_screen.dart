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
    final found = controller.findRecommendation();
    if (!found) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Belum ada outfit yang cocok dengan budget ini. Coba naikkan budget.',
          ),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ResultScreen(controller: controller)),
    );
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
                          SegmentedButton<PlanMode>(
                            segments: const [
                              ButtonSegment(
                                value: PlanMode.ai,
                                label: Text('Rekomendasi AI'),
                              ),
                              ButtonSegment(
                                value: PlanMode.manual,
                                label: Text('Pilih sendiri'),
                              ),
                            ],
                            selected: {controller.mode},
                            onSelectionChanged: (s) {
                              final mode = s.first;
                              if (mode == PlanMode.manual) {
                                controller.clearSelection();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CatalogScreen(controller: controller),
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Bingung mau pakai apa? Tanya AI.',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Ceritakan kebutuhanmu, kami rekomendasikan untukmu.',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.muted,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 14),
                          TextField(
                            maxLines: 4,
                            decoration: InputDecoration(
                              labelText: 'Tuliskan permintaanmu',
                              hintText: 'Contoh: Outfit wawancara kerja, rapi tapi tidak kaku.',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          // const SizedBox(height: 10),
                          // Row(
                          //   children: [
                          //     const Expanded(
                          //       child: Divider(
                          //         color: Color(0xFFBFC5CE),
                          //         thickness: 1,
                          //       ),
                          //     ),
                          //     const SizedBox(width: 12),
                          //     const Text(
                          //       'atau atur sendiri',
                          //       style: TextStyle(
                          //         fontSize: 14,
                          //         color: AppColors.muted,
                          //       ),
                          //     ),
                          //     const SizedBox(width: 12),
                          //     const Expanded(
                          //       child: Divider(
                          //         color: Color(0xFFBFC5CE),
                          //         thickness: 1,
                          //       ),
                          //     ),
                          //   ],
                          // ),

                          // const SizedBox(height: 14),
                          // const _SectionLabel('Acara'),
                          // Wrap(
                          //   spacing: 10,
                          //   runSpacing: 10,
                          //   children: [
                          //     for (final o in Occasion.values)
                          //       ChoiceChip(
                          //         label: Text(o.label),
                          //         selected: controller.occasion == o,
                          //         onSelected: (_) => controller.setOccasion(o),
                          //       ),
                          //   ],
                          // ),
                          const SizedBox(height: 24),
                          const _SectionLabel('Budget kamu'),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: cardDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formatRupiah(controller.budget),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Slider(
                                  value: controller.budget.toDouble(),
                                  min: 100000,
                                  max: 1000000,
                                  divisions: 18,
                                  onChanged: (v) =>
                                      controller.setBudget(v.round()),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Cari rekomendasi',
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
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.muted,
      ),
    ),
  );
}
