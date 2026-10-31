import 'package:flutter/material.dart';
import 'package:outfit_ai/core/app_theme.dart';

import '../state/outfit_controller.dart';
import '../widgets/budget_bar.dart';
import '../widgets/primary_button.dart';
import '../widgets/product_tile.dart';
import 'preview_screen.dart';

/// Layar 2a: hasil rekomendasi AI.
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.controller});

  final OutfitController controller;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isSubmitting = false;

  Future<void> _onRefresh() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final found = await widget.controller.findRecommendation(refresh: true);

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
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mendapatkan rekomendasi: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rekomendasi outfit')),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final prompt = widget.controller.prompt;
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      BudgetBar(
                        total: widget.controller.total,
                        budget: widget.controller.budget,
                      ),

                      prompt.isNotEmpty
                          ? Row(
                              children: [
                                const SizedBox(height: 50),
                                Text(
                                  'Permintaan: $prompt',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.muted,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            )
                          : Row(children: [const SizedBox(height: 12)]),

                      for (final product in widget.controller.selected) ...[
                        ProductTile(product: product, subtitle: product.reason),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _onRefresh,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            "Rekomendasi lain",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 7),
                PrimaryButton(
                  label: 'Lihat pratinjau',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PreviewScreen(controller: widget.controller),
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
