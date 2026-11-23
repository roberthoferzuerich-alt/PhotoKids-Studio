import 'package:flutter/material.dart';
import 'package:denis_phote_world/core/theme/app_colors.dart';
import 'package:denis_phote_world/domain/entities/editor_models.dart';

class WebSizePickerSheet extends StatefulWidget {
  final WebPhotoPreset? currentPreset;
  final Function(WebPhotoPreset preset) onPresetSelected;
  final Function(int width, int height) onCustomSizeSelected;

  const WebSizePickerSheet({
    super.key,
    this.currentPreset,
    required this.onPresetSelected,
    required this.onCustomSizeSelected,
  });

  static Future<void> show(
    BuildContext context, {
    WebPhotoPreset? currentPreset,
    required Function(WebPhotoPreset preset) onPresetSelected,
    required Function(int width, int height) onCustomSizeSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WebSizePickerSheet(
        currentPreset: currentPreset,
        onPresetSelected: onPresetSelected,
        onCustomSizeSelected: onCustomSizeSelected,
      ),
    );
  }

  @override
  State<WebSizePickerSheet> createState() => _WebSizePickerSheetState();
}

class _WebSizePickerSheetState extends State<WebSizePickerSheet> {
  String _selectedCategory = 'Alle';
  final _customWidthController = TextEditingController(text: '1200');
  final _customHeightController = TextEditingController(text: '800');
  bool _maintainAspectRatio = true;
  double _lockedRatio = 1200 / 800;

  @override
  void dispose() {
    _customWidthController.dispose();
    _customHeightController.dispose();
    super.dispose();
  }

  void _onWidthChanged(String val) {
    if (!_maintainAspectRatio) return;
    final w = int.tryParse(val);
    if (w != null && w > 0) {
      final h = (w / _lockedRatio).round();
      _customHeightController.text = h.toString();
    }
  }

  void _onHeightChanged(String val) {
    if (!_maintainAspectRatio) return;
    final h = int.tryParse(val);
    if (h != null && h > 0) {
      final w = (h * _lockedRatio).round();
      _customWidthController.text = w.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final categories = ['Alle', 'Website', 'Social Media'];
    final filteredPresets = _selectedCategory == 'Alle'
        ? WebPhotoSizes.standardPresets
        : WebPhotoSizes.standardPresets.where((p) => p.category == _selectedCategory).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF221B2D) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 20, offset: Offset(0, -6)),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.turquoiseSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🌐', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Web- & Social-Media-Größen',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        'Standard-Auflösungen für Webseiten & Feeds',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Category Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppColors.turquoiseSecondary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 24),

          // Presets List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              itemCount: filteredPresets.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final preset = filteredPresets[index];
                final isSelected = widget.currentPreset?.id == preset.id;

                return Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.turquoiseSecondary.withValues(alpha: 0.15)
                        : (isDark ? const Color(0xFF2C243B) : const Color(0xFFF9F7FC)),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.turquoiseSecondary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(preset.iconEmoji, style: const TextStyle(fontSize: 26)),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            preset.title,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.turquoiseSecondary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            preset.resolutionLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.turquoiseDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        preset.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ),
                    onTap: () {
                      widget.onPresetSelected(preset);
                      Navigator.of(context).pop();
                    },
                  ),
                );
              },
            ),
          ),

          // Custom Size Section at the bottom
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B1525) : const Color(0xFFF3EEFA),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Benutzerdefinierte Pixelgröße ✏️',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Width input
                      Expanded(
                        child: TextField(
                          controller: _customWidthController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Breite (px)',
                            filled: true,
                            fillColor: isDark ? const Color(0xFF2B2338) : Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onChanged: _onWidthChanged,
                        ),
                      ),
                      IconButton(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          _maintainAspectRatio ? Icons.link_rounded : Icons.link_off_rounded,
                          color: _maintainAspectRatio ? AppColors.turquoiseSecondary : Colors.grey,
                        ),
                        tooltip: 'Seitenverhältnis sperren',
                        onPressed: () {
                          setState(() {
                            _maintainAspectRatio = !_maintainAspectRatio;
                            final w = int.tryParse(_customWidthController.text) ?? 1200;
                            final h = int.tryParse(_customHeightController.text) ?? 800;
                            if (h > 0) _lockedRatio = w / h;
                          });
                        },
                      ),
                      // Height input
                      Expanded(
                        child: TextField(
                          controller: _customHeightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Höhe (px)',
                            filled: true,
                            fillColor: isDark ? const Color(0xFF2B2338) : Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onChanged: _onHeightChanged,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Apply Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.turquoiseSecondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          final w = int.tryParse(_customWidthController.text) ?? 1200;
                          final h = int.tryParse(_customHeightController.text) ?? 800;
                          widget.onCustomSizeSelected(w, h);
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
