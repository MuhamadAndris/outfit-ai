import 'package:flutter/material.dart';
import 'package:outfit_ai/api_exception.dart';

import '../core/app_theme.dart';
import '../core/format.dart';
import '../state/outfit_controller.dart';
import '../widgets/primary_button.dart';
import 'catalog_screen.dart';
import 'result_screen.dart';

/// Warna khusus layar ini. Kalau sudah ada di AppColors, pindahkan ke sana.
class _HomeColors {
  static const ground = Color(0xFFFBF8F6);
  static const accent = Color(0xFFC4411E);
  static const tint = Color(0xFFFCE9E2);
  static const tintText = Color(0xFF8F2A10);
  static const border = Color(0xFFE6DFDA);
  static const hairline = Color(0xFFEFE9E5);
  static const track = Color(0xFFEFE9E5);
  static const trackSoft = Color(0xFFF4EFEC);
  static const label = Color(0xFF5E5550);
  static const hint = Color(0xFF7A706B);
  static const chipText = Color(0xFF3A322F);
}

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

      final errorMessage = parseApiError(e.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _HomeColors.ground,
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            final hasImage = widget.controller.selectedImage != null;
            final isPhotoMode =
                widget.controller.previewMode == PreviewMode.user_photo;

            final canSubmit = !isPhotoMode || hasImage;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mode utama
                        _PillSegmented<PlanMode>(
                          items: const [
                            _SegmentItem<PlanMode>(
                              value: PlanMode.ai,
                              label: 'Rekomendasi AI',
                              icon: Icons.auto_awesome,
                            ),
                            _SegmentItem<PlanMode>(
                              value: PlanMode.manual,
                              label: 'Pilih sendiri',
                              icon: Icons.checkroom,
                            ),
                          ],
                          selected: widget.controller.mode,
                          onChanged: (mode) {
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

                        // Judul
                        const SizedBox(height: 24),
                        const Text(
                          'Bingung mau pakai apa? Tanya AI.',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ceritakan kebutuhanmu, kami rekomendasikan untukmu.',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.muted,
                            height: 1.4,
                          ),
                        ),

                        // Permintaan
                        const SizedBox(height: 20),
                        const _SectionLabel('Permintaanmu'),
                        TextField(
                          minLines: 3,
                          maxLines: 4,
                          style: const TextStyle(fontSize: 15, height: 1.45),
                          onChanged: (value) =>
                              widget.controller.setPrompt(value),
                          decoration: InputDecoration(
                            hintText: 'Tuliskan permintaanmu',
                            hintStyle: const TextStyle(color: _HomeColors.hint),
                            helperText: 'Contoh: Outfit wawancara kerja, rapi tapi tidak kaku.',
                            helperMaxLines: 2,
                            helperStyle: const TextStyle(
                              fontSize: 13,
                              color: _HomeColors.hint,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: _HomeColors.border,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: _HomeColors.accent,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),

                        // Preferensi
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _HomeColors.hairline),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _SectionLabel('Gender'),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _genderList.map((gender) {
                                  return _OptionChip(
                                    label: gender,
                                    selected:
                                        gender == widget.controller.gender,
                                    onSelected: () =>
                                        widget.controller.setGender(gender),
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: 20),
                              const _SectionLabel('Gaya'),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _styleList.map((gaya) {
                                  return _OptionChip(
                                    label: gaya,
                                    selected: widget.controller.style == gaya,
                                    onSelected: () =>
                                        widget.controller.setStyle(gaya),
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: 20),
                              const _SectionLabel('Mode tampilan'),
                              _PillSegmented<PreviewMode>(
                                trackColor: _HomeColors.trackSoft,
                                radius: 14,
                                items: const [
                                  _SegmentItem<PreviewMode>(
                                    value: PreviewMode.mannequin,
                                    label: 'Manekin',
                                  ),
                                  _SegmentItem<PreviewMode>(
                                    value: PreviewMode.user_photo,
                                    label: 'Foto kamu',
                                  ),
                                ],
                                selected: widget.controller.previewMode,
                                onChanged: (mode) =>
                                    widget.controller.setPreviewMode(mode),
                              ),

                              if (widget.controller.previewMode ==
                                  PreviewMode.user_photo)
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(top: 16),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _HomeColors.ground,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _HomeColors.hairline,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () =>
                                            widget.controller.selectImage(),
                                        child: Container(
                                          width: 72,
                                          height: 96,
                                          decoration: BoxDecoration(
                                            color: _HomeColors.track,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: hasImage
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: Image.file(
                                                    widget
                                                        .controller
                                                        .selectedImage!,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.add_a_photo_outlined,
                                                  color: _HomeColors.hint,
                                                ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              hasImage
                                                  ? 'Foto kamu sudah dipilih'
                                                  : 'Belum ada foto',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              hasImage
                                                  ? 'Rekomendasi akan dicoba langsung di fotomu.'
                                                  : 'Unggah foto agar rekomendasi bisa dicoba langsung di fotomu.',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                height: 1.4,
                                                color: _HomeColors.label,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            OutlinedButton.icon(
                                              onPressed: () => widget.controller
                                                  .selectImage(),
                                              icon: const Icon(
                                                Icons.photo_camera_outlined,
                                                size: 18,
                                              ),
                                              label: Text(
                                                hasImage
                                                    ? 'Ganti foto'
                                                    : 'Pilih foto',
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                minimumSize: const Size(0, 44),
                                                foregroundColor: Colors.black,
                                                backgroundColor: Colors.white,
                                                side: const BorderSide(
                                                  color: _HomeColors.border,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                textStyle: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
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

                // CTA tetap di bawah
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: _HomeColors.hairline),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x0F1F1A18),
                        blurRadius: 16,
                        offset: Offset(0, -6),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      child: PrimaryButton(
                        label: 'Cari rekomendasi',
                        isLoading: _isSubmitting,
                        onPressed: canSubmit
                            ? () => _onContinue(context)
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
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

/// Chip pilihan seragam: terpilih = warna tint + garis aksen + centang.
class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: true,
      checkmarkColor: _HomeColors.tintText,
      backgroundColor: Colors.white,
      selectedColor: _HomeColors.tint,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      pressElevation: 0,
      side: BorderSide(
        color: selected ? _HomeColors.accent : _HomeColors.border,
      ),
      shape: const StadiumBorder(),
      labelStyle: TextStyle(
        fontSize: 14,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        color: selected ? _HomeColors.tintText : _HomeColors.chipText,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    );
  }
}

class _SegmentItem<T> {
  const _SegmentItem({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// Segmented control halus: track abu hangat, pilihan aktif berupa pil putih.
class _PillSegmented<T> extends StatelessWidget {
  const _PillSegmented({
    required this.items,
    required this.selected,
    required this.onChanged,
    this.trackColor = _HomeColors.track,
    this.radius = 16,
  });

  final List<_SegmentItem<T>> items;
  final T selected;
  final ValueChanged<T> onChanged;
  final Color trackColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final innerRadius = BorderRadius.circular(radius - 4);
    final children = <Widget>[];

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final isSelected = item.value == selected;

      if (i > 0) children.add(const SizedBox(width: 4));
      children.add(
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: innerRadius,
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: Color(0x1F1F1A18),
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: innerRadius,
                onTap: () => onChanged(item.value),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (item.icon != null) ...[
                      Icon(
                        item.icon,
                        size: 18,
                        color: isSelected
                            ? _HomeColors.accent
                            : _HomeColors.label,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected ? Colors.black : _HomeColors.label,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(children: children),
    );
  }
}
