import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../state/outfit_controller.dart';
import '../widgets/budget_bar.dart';
import '../widgets/primary_button.dart';
import '../widgets/product_tile.dart';
import 'preview_screen.dart';

/// Layar 2a: hasil rekomendasi AI.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.controller});

  final OutfitController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rekomendasi outfit')),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          // final explanation = controller.recommendation?.explanation ?? '';
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      BudgetBar(
                        total: controller.total,
                        budget: controller.budget,
                      ),
                      const SizedBox(height: 12),
                      // Text(
                      //   explanation,
                      //   style: const TextStyle(
                      //     fontSize: 13,
                      //     color: AppColors.muted,
                      //     height: 1.5,
                      //   ),
                      // ),
                      const SizedBox(height: 12),
                      for (final product in controller.selected) ...[
                        ProductTile(product: product, subtitle: product.reason),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
                PrimaryButton(
                  label: 'Lihat pratinjau',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PreviewScreen(controller: controller),
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
}
