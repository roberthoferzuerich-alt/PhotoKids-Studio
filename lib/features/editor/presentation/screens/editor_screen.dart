import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:denis_phote_world/core/constants/app_constants.dart';
import 'package:denis_phote_world/core/theme/app_colors.dart';
import 'package:denis_phote_world/domain/entities/editor_models.dart';
import 'package:denis_phote_world/domain/entities/photo_entity.dart';
import 'package:denis_phote_world/features/editor/presentation/controllers/editor_controller.dart';
import 'package:denis_phote_world/features/editor/presentation/widgets/web_size_picker_sheet.dart';
import 'package:denis_phote_world/features/gallery/presentation/controllers/gallery_controller.dart';

class EditorScreen extends ConsumerStatefulWidget {
  final PhotoEntity? photo;

  const EditorScreen({super.key, this.photo});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  List<Offset> _currentPoints = [];

  void _savePhoto() async {
    final editorNotifier = ref.read(editorControllerProvider(widget.photo).notifier);
    final saved = await editorNotifier.saveImage();

    if (saved != null && mounted) {
      ref.read(galleryControllerProvider.notifier).loadPhotos();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Foto erfolgreich gespeichert!')),
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    }
  }

  void _openWebSizePicker(BuildContext context, EditorState state, EditorNotifier notifier) {
    WebSizePickerSheet.show(
      context,
      currentPreset: state.selectedWebPreset,
      onPresetSelected: (preset) {
        notifier.applyWebPreset(preset);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🌐 Web-Größe aktiviert: ${preset.title} (${preset.resolutionLabel})'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.turquoiseDark,
          ),
        );
      },
      onCustomSizeSelected: (width, height) {
        notifier.applyCustomSize(width, height);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🌐 Eigene Web-Größe: $width × $height px'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.turquoiseDark,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photo;
    if (photo == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Kein Foto ausgewählt')),
      );
    }

    final editorState = ref.watch(editorControllerProvider(photo));
    final editorNotifier = ref.read(editorControllerProvider(photo).notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: const Text(
          'Studio Editor 🎨',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          // Web-Size Quick Action Icon
          IconButton(
            icon: const Icon(Icons.public_rounded, color: AppColors.turquoiseSecondary),
            tooltip: 'Web-Größe & Social Media Presets',
            onPressed: () => _openWebSizePicker(context, editorState, editorNotifier),
          ),
          // Undo & Redo
          IconButton(
            icon: const Icon(Icons.undo_rounded, size: 22),
            tooltip: 'Rückgängig',
            onPressed: editorState.strokes.isNotEmpty ? () => editorNotifier.undoStroke() : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo_rounded, size: 22),
            tooltip: 'Wiederholen',
            onPressed: editorState.undoneStrokes.isNotEmpty ? () => editorNotifier.redoStroke() : null,
          ),
          // Save Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pinkPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              icon: editorState.isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_rounded, size: 18),
              label: const Text('Speichern', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              onPressed: editorState.isSaving ? null : _savePhoto,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Active Web Preset Indicator Badge
          if (editorState.targetWidth != null && editorState.targetHeight != null)
            Container(
              margin: const EdgeInsets.only(top: 4, bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.turquoiseSecondary.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.turquoiseSecondary.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🌐', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    'Web-Größe: ${editorState.selectedWebPreset?.title ?? 'Benutzerdefiniert'} (${editorState.targetWidth} × ${editorState.targetHeight} px)',
                    style: const TextStyle(
                      color: AppColors.turquoiseLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      editorNotifier.applyCustomSize(photo.width, photo.height);
                      editorNotifier.setCropRatio(CropAspectRatio.free);
                    },
                    child: const Icon(Icons.close_rounded, size: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),

          // Canvas Area
          Expanded(
            child: Center(
              child: RotatedBox(
                quarterTurns: (editorState.rotationDegrees / 90).round() % 4,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..scale(
                      editorState.flipHorizontal ? -1.0 : 1.0,
                      editorState.flipVertical ? -1.0 : 1.0,
                    ),
                  child: AspectRatio(
                    aspectRatio: editorState.cropRatio.numericRatio ??
                        (photo.width > 0 && photo.height > 0 ? photo.width / photo.height : 1.0),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Base Photo
                        _buildEditorImage(photo, editorState),

                        // Drawing Layer (Painter)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onPanStart: (details) {
                            if (editorState.activeTool == EditorActiveTool.draw) {
                              setState(() {
                                _currentPoints = [details.localPosition];
                              });
                            }
                          },
                          onPanUpdate: (details) {
                            if (editorState.activeTool == EditorActiveTool.draw) {
                              setState(() {
                                _currentPoints.add(details.localPosition);
                              });
                            }
                          },
                          onPanEnd: (details) {
                            if (editorState.activeTool == EditorActiveTool.draw && _currentPoints.isNotEmpty) {
                              editorNotifier.addStroke(
                                DrawingStroke(
                                  points: List.from(_currentPoints),
                                  color: editorState.currentDrawColor,
                                  strokeWidth: editorState.currentBrushSize,
                                  toolType: editorState.currentToolType,
                                ),
                              );
                              setState(() {
                                _currentPoints = [];
                              });
                            }
                          },
                          child: CustomPaint(
                            painter: _EditorDrawingPainter(
                              strokes: editorState.strokes,
                              currentStrokePoints: _currentPoints,
                              currentColor: editorState.currentDrawColor,
                              currentWidth: editorState.currentBrushSize,
                              currentType: editorState.currentToolType,
                            ),
                          ),
                        ),

                        // Interactive Text Overlays
                        ...editorState.textOverlays.map((item) {
                          return Positioned(
                            left: item.position.dx,
                            top: item.position.dy,
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                setState(() {
                                  item.position += details.delta;
                                });
                              },
                              child: Transform.rotate(
                                angle: item.rotation,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black26,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white38),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        item.text,
                                        style: TextStyle(
                                          color: item.color,
                                          fontSize: item.fontSize,
                                          fontWeight: FontWeight.bold,
                                          shadows: item.hasShadow
                                              ? const [Shadow(blurRadius: 4, color: Colors.black)]
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: () => editorNotifier.removeTextOverlay(item.id),
                                        child: const Icon(Icons.cancel, color: Colors.white70, size: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),

                        // Interactive Stickers (Scale, Rotate, Drag)
                        ...editorState.stickers.map((sticker) {
                          return Positioned(
                            left: sticker.position.dx,
                            top: sticker.position.dy,
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                setState(() {
                                  sticker.position += details.delta;
                                });
                              },
                              child: Transform.rotate(
                                angle: sticker.rotation,
                                child: Transform.scale(
                                  scale: sticker.scale,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Text(
                                        sticker.emojiOrAsset,
                                        style: const TextStyle(fontSize: 48),
                                      ),
                                      Positioned(
                                        right: -10,
                                        top: -10,
                                        child: GestureDetector(
                                          onTap: () => editorNotifier.removeSticker(sticker.id),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.redAccent,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF1E1C24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sub-Toolbar panel for the active tool
              _buildActiveToolPanel(editorState, editorNotifier),

              // Bottom Primary Toolbar
              _buildPrimaryToolbar(editorState, editorNotifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditorImage(PhotoEntity photo, EditorState state) {
    final file = File(photo.filePath);
    if (!kIsWeb && file.existsSync()) {
      return ColorFiltered(
        colorFilter: _buildColorFilter(state.colorAdjustments),
        child: Image.file(file, fit: BoxFit.contain),
      );
    }
    return Container(
      color: Colors.grey[850],
      child: const Center(child: Icon(Icons.image, color: Colors.white30, size: 64)),
    );
  }

  ColorFilter _buildColorFilter(ColorAdjustmentParams params) {
    final b = params.brightness * 255;
    final c = params.contrast;
    final matrix = <double>[
      c, 0, 0, 0, b,
      0, c, 0, 0, b,
      0, 0, c, 0, b,
      0, 0, 0, 1, 0,
    ];
    return ColorFilter.matrix(matrix);
  }

  Widget _buildPrimaryToolbar(EditorState state, EditorNotifier notifier) {
    return Container(
      color: const Color(0xFF1E1C24),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildToolItem(
              icon: Icons.public_rounded,
              label: 'Web-Größe 🌐',
              isActive: state.selectedWebPreset != null,
              onTap: () => _openWebSizePicker(context, state, notifier),
            ),
            _buildToolItem(
              icon: Icons.crop_rounded,
              label: 'Zuschneiden',
              isActive: state.activeTool == EditorActiveTool.crop,
              onTap: () => notifier.setActiveTool(EditorActiveTool.crop),
            ),
            _buildToolItem(
              icon: Icons.brush_rounded,
              label: 'Malen 🎨',
              isActive: state.activeTool == EditorActiveTool.draw,
              onTap: () => notifier.setActiveTool(EditorActiveTool.draw),
            ),
            _buildToolItem(
              icon: Icons.text_fields_rounded,
              label: 'Text 🔤',
              isActive: state.activeTool == EditorActiveTool.text,
              onTap: () => notifier.setActiveTool(EditorActiveTool.text),
            ),
            _buildToolItem(
              icon: Icons.emoji_emotions_rounded,
              label: 'Sticker ⭐',
              isActive: state.activeTool == EditorActiveTool.stickers,
              onTap: () => notifier.setActiveTool(EditorActiveTool.stickers),
            ),
            _buildToolItem(
              icon: Icons.filter_vintage_rounded,
              label: 'Filter 🪄',
              isActive: state.activeTool == EditorActiveTool.filters,
              onTap: () => notifier.setActiveTool(EditorActiveTool.filters),
            ),
            _buildToolItem(
              icon: Icons.tune_rounded,
              label: 'Farben ⚙️',
              isActive: state.activeTool == EditorActiveTool.adjust,
              onTap: () => notifier.setActiveTool(EditorActiveTool.adjust),
            ),
            _buildToolItem(
              icon: Icons.rotate_90_degrees_cw_rounded,
              label: 'Drehen 🔄',
              isActive: false,
              onTap: () => notifier.rotate90(),
            ),
            _buildToolItem(
              icon: Icons.flip_rounded,
              label: 'Spiegeln ↔️',
              isActive: state.flipHorizontal,
              onTap: () => notifier.toggleFlipHorizontal(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.turquoiseSecondary.withValues(alpha: 0.35) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isActive ? Border.all(color: AppColors.turquoiseSecondary) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? AppColors.turquoiseLight : Colors.white70, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.white : Colors.white70,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveToolPanel(EditorState state, EditorNotifier notifier) {
    if (state.activeTool == EditorActiveTool.none) {
      return const SizedBox.shrink();
    }

    return Container(
      color: const Color(0xFF2C2834),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.activeTool == EditorActiveTool.crop) _buildCropOptions(state, notifier),
          if (state.activeTool == EditorActiveTool.draw) _buildDrawingOptions(state, notifier),
          if (state.activeTool == EditorActiveTool.text) _buildTextOptions(notifier),
          if (state.activeTool == EditorActiveTool.stickers) _buildStickerOptions(notifier),
          if (state.activeTool == EditorActiveTool.filters) _buildFilterOptions(state, notifier),
          if (state.activeTool == EditorActiveTool.adjust) _buildAdjustmentSliders(state, notifier),
        ],
      ),
    );
  }

  Widget _buildCropOptions(EditorState state, EditorNotifier notifier) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: CropAspectRatio.values.map((ratio) {
          final isSelected = state.cropRatio == ratio;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(ratio.label),
              selected: isSelected,
              selectedColor: AppColors.pinkPrimary,
              onSelected: (_) => notifier.setCropRatio(ratio),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDrawingOptions(EditorState state, EditorNotifier notifier) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDrawingToolBtn(
              icon: Icons.edit,
              label: 'Stift',
              isSelected: state.currentToolType == DrawingToolType.pen,
              onTap: () => notifier.setDrawingTool(DrawingToolType.pen),
            ),
            _buildDrawingToolBtn(
              icon: Icons.border_color,
              label: 'Marker',
              isSelected: state.currentToolType == DrawingToolType.marker,
              onTap: () => notifier.setDrawingTool(DrawingToolType.marker),
            ),
            _buildDrawingToolBtn(
              icon: Icons.brush,
              label: 'Pinsel',
              isSelected: state.currentToolType == DrawingToolType.brush,
              onTap: () => notifier.setDrawingTool(DrawingToolType.brush),
            ),
            _buildDrawingToolBtn(
              icon: Icons.auto_fix_normal,
              label: 'Radierer',
              isSelected: state.currentToolType == DrawingToolType.eraser,
              onTap: () => notifier.setDrawingTool(DrawingToolType.eraser),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: AppColors.drawingPalette.map((color) {
              final isSelected = state.currentDrawColor.value == color.value;
              return GestureDetector(
                onTap: () => notifier.setDrawColor(color),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Row(
          children: [
            const Icon(Icons.circle, color: Colors.white70, size: 8),
            Expanded(
              child: Slider(
                value: state.currentBrushSize,
                min: 2,
                max: 30,
                activeColor: AppColors.pinkPrimary,
                onChanged: (val) => notifier.setBrushSize(val),
              ),
            ),
            const Icon(Icons.circle, color: Colors.white70, size: 24),
          ],
        ),
      ],
    );
  }

  Widget _buildDrawingToolBtn({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ChoiceChip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.pinkPrimary,
        onSelected: (_) => onTap(),
      ),
    );
  }

  Widget _buildTextOptions(EditorNotifier notifier) {
    final textController = TextEditingController();
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: textController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Schreibe einen Text...',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkPrimary),
          onPressed: () {
            if (textController.text.trim().isNotEmpty) {
              notifier.addTextOverlay(textController.text.trim());
              textController.clear();
            }
          },
          child: const Text('Hinzufügen', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildStickerOptions(EditorNotifier notifier) {
    return DefaultTabController(
      length: AppConstants.stickerCategories.length,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
            isScrollable: true,
            indicatorColor: AppColors.yellowAccent,
            labelColor: Colors.white,
            tabs: AppConstants.stickerCategories.keys.map((k) => Tab(text: k)).toList(),
          ),
          SizedBox(
            height: 90,
            child: TabBarView(
              children: AppConstants.stickerCategories.values.map((stickers) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: stickers.map((emoji) {
                      return GestureDetector(
                        onTap: () => notifier.addSticker(emoji),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(emoji, style: const TextStyle(fontSize: 38)),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions(EditorState state, EditorNotifier notifier) {
    final presets = ['Original', 'KidsPop', 'Vintage', 'BW', 'Cool', 'Warm'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: presets.map((p) {
          final isSelected = state.activeFilterPreset == p || (p == 'Original' && state.activeFilterPreset == null);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ChoiceChip(
              label: Text(p),
              selected: isSelected,
              selectedColor: AppColors.purpleAccent,
              onSelected: (_) => notifier.applyFilterPreset(p == 'Original' ? null : p),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAdjustmentSliders(EditorState state, EditorNotifier notifier) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const SizedBox(width: 90, child: Text('Helligkeit', style: TextStyle(color: Colors.white70))),
            Expanded(
              child: Slider(
                value: state.colorAdjustments.brightness,
                min: -0.5,
                max: 0.5,
                activeColor: AppColors.yellowAccent,
                onChanged: (val) {
                  notifier.setColorAdjustments(state.colorAdjustments.copyWith(brightness: val));
                },
              ),
            ),
          ],
        ),
        Row(
          children: [
            const SizedBox(width: 90, child: Text('Kontrast', style: TextStyle(color: Colors.white70))),
            Expanded(
              child: Slider(
                value: state.colorAdjustments.contrast,
                min: 0.5,
                max: 1.8,
                activeColor: AppColors.turquoiseSecondary,
                onChanged: (val) {
                  notifier.setColorAdjustments(state.colorAdjustments.copyWith(contrast: val));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EditorDrawingPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final List<Offset> currentStrokePoints;
  final Color currentColor;
  final double currentWidth;
  final DrawingToolType currentType;

  _EditorDrawingPainter({
    required this.strokes,
    required this.currentStrokePoints,
    required this.currentColor,
    required this.currentWidth,
    required this.currentType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.points.length < 2) continue;
      for (int i = 0; i < stroke.points.length - 1; i++) {
        canvas.drawLine(stroke.points[i], stroke.points[i + 1], stroke.paint);
      }
    }

    if (currentStrokePoints.length > 1) {
      final activePaint = Paint()
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = currentWidth
        ..color = currentType == DrawingToolType.eraser ? Colors.white30 : currentColor
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < currentStrokePoints.length - 1; i++) {
        canvas.drawLine(currentStrokePoints[i], currentStrokePoints[i + 1], activePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _EditorDrawingPainter oldDelegate) => true;
}
