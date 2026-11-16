import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/format.dart';
import '../state/outfit_controller.dart';
import '../widgets/primary_button.dart';
import 'catalog_screen.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.controller});

  final OutfitController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _styleList = ['Kasual', 'Formal', 'Santai'];
  final List<String> _genderList = ['Laki-laki', 'Perempuan'];

  bool _isSubmitting = false;

  Future<void> _onContinue(BuildContext context) async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final found = await widget.controller.findRecommendation();
      if (!mounted) return;

      if (!found) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Belum ada outfit yang cocok dengan budget ini. Coba naikkan budget.',
            ),
          ),
        );
        return;
      }

      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(controller: widget.controller),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('[CatalogScreen] GAGAL mencari rekomendasi: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mencari rekomendasi. Cek koneksi internet anda'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // const navy = Color(0xFF0F1D3A);
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
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
                                icon: Icon(Icons.checkroom),
                              ),
                            ],
                            selected: {widget.controller.mode},
                            onSelectionChanged: (s) {
                              final mode = s.first;
                              if (mode == PlanMode.manual) {
                                widget.controller.clearSelection();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CatalogScreen(
                                      controller: widget.controller,
                                    ),
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
                            onChanged: (value) =>
                                widget.controller.setPrompt(value),
                            decoration: InputDecoration(
                              labelText: 'Tuliskan permintaanmu',
                              hintText: 'Contoh: Outfit wawancara kerja, rapi tapi tidak kaku.',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                          const Text('Gender'),
                          Wrap(
                            spacing: 12,
                            children: _genderList.map((gender) {
                              final isSelected =
                                  gender == widget.controller.gender;

                              return ChoiceChip(
                                label: Text(gender),
                                selected: isSelected,
                                backgroundColor: Colors.white,
                                showCheckmark: false,
                                onSelected: (_) =>
                                    widget.controller.setGender(gender),
                                shape: StadiumBorder(
                                  side: BorderSide(color: Colors.grey.shade400),
                                ),
                                padding: EdgeInsetsGeometry.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 24),
                          const Text('Gaya'),
                          Wrap(
                            spacing: 12,
                            children: _styleList.map((gaya) {
                              final isSelected =
                                  widget.controller.style == gaya;
                              return ChoiceChip(
                                label: Text(gaya),
                                selected: isSelected,
                                onSelected: (_) =>
                                    widget.controller.setStyle(gaya),
                                showCheckmark: false,
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                shape: StadiumBorder(
                                  side: BorderSide(color: Colors.grey.shade400),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 24),
                          const _SectionLabel('Budget kamu'),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: cardDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formatRupiah(widget.controller.budget),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Slider(
                                  value: widget.controller.budget.toDouble(),
                                  min: 100000,
                                  max: 1000000,
                                  divisions: 18,
                                  onChanged: (v) =>
                                      widget.controller.setBudget(v.round()),
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
                    isLoading: _isSubmitting,
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
