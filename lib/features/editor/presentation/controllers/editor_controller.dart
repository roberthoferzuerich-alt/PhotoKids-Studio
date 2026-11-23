import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:denis_phote_world/core/di/app_providers.dart';
import 'package:denis_phote_world/domain/entities/editor_models.dart';
import 'package:denis_phote_world/domain/entities/photo_entity.dart';
import 'package:denis_phote_world/services/image/image_processing_service.dart';

enum EditorActiveTool {
  none,
  crop,
  webSize,
  frames,
  filters,
  draw,
  text,
  stickers,
  adjust,
  resize,
}

class EditorState {
  final PhotoEntity? photo;
  final EditorActiveTool activeTool;
  final CropAspectRatio cropRatio;
  final WebPhotoPreset? selectedWebPreset;
  final PhotoFramePreset? selectedFrame;
  final bool showBeforeAfterComparison;
  final int? targetWidth;
  final int? targetHeight;
  final List<DrawingStroke> strokes;
  final List<DrawingStroke> undoneStrokes;
  final Color currentDrawColor;
  final double currentBrushSize;
  final DrawingToolType currentToolType;
  final List<TextOverlay> textOverlays;
  final List<StickerItem> stickers;
  final ColorAdjustmentParams colorAdjustments;
  final String? activeFilterPreset;
  final int rotationDegrees;
  final bool flipHorizontal;
  final bool flipVertical;
  final bool isSaving;
  final String? errorMessage;

  const EditorState({
    this.photo,
    this.activeTool = EditorActiveTool.none,
    this.cropRatio = CropAspectRatio.free,
    this.selectedWebPreset,
    this.selectedFrame,
    this.showBeforeAfterComparison = false,
    this.targetWidth,
    this.targetHeight,
    this.strokes = const [],
    this.undoneStrokes = const [],
    this.currentDrawColor = Colors.pinkAccent,
    this.currentBrushSize = 6.0,
    this.currentToolType = DrawingToolType.pen,
    this.textOverlays = const [],
    this.stickers = const [],
    this.colorAdjustments = const ColorAdjustmentParams(),
    this.activeFilterPreset,
    this.rotationDegrees = 0,
    this.flipHorizontal = false,
    this.flipVertical = false,
    this.isSaving = false,
    this.errorMessage,
  });

  EditorState copyWith({
    PhotoEntity? photo,
    EditorActiveTool? activeTool,
    CropAspectRatio? cropRatio,
    WebPhotoPreset? selectedWebPreset,
    PhotoFramePreset? selectedFrame,
    bool? showBeforeAfterComparison,
    int? targetWidth,
    int? targetHeight,
    List<DrawingStroke>? strokes,
    List<DrawingStroke>? undoneStrokes,
    Color? currentDrawColor,
    double? currentBrushSize,
    DrawingToolType? currentToolType,
    List<TextOverlay>? textOverlays,
    List<StickerItem>? stickers,
    ColorAdjustmentParams? colorAdjustments,
    String? activeFilterPreset,
    int? rotationDegrees,
    bool? flipHorizontal,
    bool? flipVertical,
    bool? isSaving,
    String? errorMessage,
  }) {
    return EditorState(
      photo: photo ?? this.photo,
      activeTool: activeTool ?? this.activeTool,
      cropRatio: cropRatio ?? this.cropRatio,
      selectedWebPreset: selectedWebPreset ?? this.selectedWebPreset,
      selectedFrame: selectedFrame ?? this.selectedFrame,
      showBeforeAfterComparison: showBeforeAfterComparison ?? this.showBeforeAfterComparison,
      targetWidth: targetWidth ?? this.targetWidth,
      targetHeight: targetHeight ?? this.targetHeight,
      strokes: strokes ?? this.strokes,
      undoneStrokes: undoneStrokes ?? this.undoneStrokes,
      currentDrawColor: currentDrawColor ?? this.currentDrawColor,
      currentBrushSize: currentBrushSize ?? this.currentBrushSize,
      currentToolType: currentToolType ?? this.currentToolType,
      textOverlays: textOverlays ?? this.textOverlays,
      stickers: stickers ?? this.stickers,
      colorAdjustments: colorAdjustments ?? this.colorAdjustments,
      activeFilterPreset: activeFilterPreset ?? this.activeFilterPreset,
      rotationDegrees: rotationDegrees ?? this.rotationDegrees,
      flipHorizontal: flipHorizontal ?? this.flipHorizontal,
      flipVertical: flipVertical ?? this.flipVertical,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}

class EditorNotifier extends StateNotifier<EditorState> {
  final Ref _ref;

  EditorNotifier(this._ref, PhotoEntity? photo) : super(EditorState(photo: photo));

  void setActiveTool(EditorActiveTool tool) {
    state = state.copyWith(activeTool: tool == state.activeTool ? EditorActiveTool.none : tool);
  }

  void setCropRatio(CropAspectRatio ratio) {
    state = state.copyWith(cropRatio: ratio);
  }

  void applyWebPreset(WebPhotoPreset preset) {
    state = state.copyWith(
      cropRatio: preset.cropRatio,
      selectedWebPreset: preset,
      targetWidth: preset.width,
      targetHeight: preset.height,
    );
  }

  void applyCustomSize(int width, int height) {
    state = state.copyWith(
      targetWidth: width,
      targetHeight: height,
    );
  }

  void setDrawColor(Color color) {
    state = state.copyWith(currentDrawColor: color);
  }

  void setBrushSize(double size) {
    state = state.copyWith(currentBrushSize: size);
  }

  void setDrawingTool(DrawingToolType type) {
    state = state.copyWith(currentToolType: type);
  }

  void addStroke(DrawingStroke stroke) {
    state = state.copyWith(
      strokes: [...state.strokes, stroke],
      undoneStrokes: [],
    );
  }

  void undoStroke() {
    if (state.strokes.isNotEmpty) {
      final last = state.strokes.last;
      state = state.copyWith(
        strokes: state.strokes.sublist(0, state.strokes.length - 1),
        undoneStrokes: [...state.undoneStrokes, last],
      );
    }
  }

  void redoStroke() {
    if (state.undoneStrokes.isNotEmpty) {
      final redo = state.undoneStrokes.last;
      state = state.copyWith(
        strokes: [...state.strokes, redo],
        undoneStrokes: state.undoneStrokes.sublist(0, state.undoneStrokes.length - 1),
      );
    }
  }

  void clearStrokes() {
    state = state.copyWith(strokes: [], undoneStrokes: []);
  }

  void setFrame(PhotoFramePreset? frame) {
    state = state.copyWith(selectedFrame: frame);
  }

  void toggleBeforeAfter() {
    state = state.copyWith(showBeforeAfterComparison: !state.showBeforeAfterComparison);
  }

  void addTextOverlay(String text, {Color color = Colors.white, SpeechBubbleType bubbleType = SpeechBubbleType.none, Color? bubbleColor}) {
    final overlay = TextOverlay(
      id: const Uuid().v4(),
      text: text,
      position: const Offset(120, 180),
      color: color,
      bubbleType: bubbleType,
      bubbleColor: bubbleColor,
    );
    state = state.copyWith(textOverlays: [...state.textOverlays, overlay]);
  }

  void addSpeechBubble(String text, SpeechBubbleType bubbleType, {Color? bubbleColor, Color textColor = Colors.black87}) {
    addTextOverlay(text, color: textColor, bubbleType: bubbleType, bubbleColor: bubbleColor ?? Colors.white);
  }

  void removeTextOverlay(String id) {
    state = state.copyWith(textOverlays: state.textOverlays.where((t) => t.id != id).toList());
  }

  void addSticker(String emojiOrAsset) {
    final sticker = StickerItem(
      id: const Uuid().v4(),
      emojiOrAsset: emojiOrAsset,
      position: const Offset(150, 150),
    );
    state = state.copyWith(stickers: [...state.stickers, sticker]);
  }

  void removeSticker(String id) {
    state = state.copyWith(stickers: state.stickers.where((s) => s.id != id).toList());
  }

  void rotate90() {
    state = state.copyWith(rotationDegrees: (state.rotationDegrees + 90) % 360);
  }

  void toggleFlipHorizontal() {
    state = state.copyWith(flipHorizontal: !state.flipHorizontal);
  }

  void toggleFlipVertical() {
    state = state.copyWith(flipVertical: !state.flipVertical);
  }

  void setColorAdjustments(ColorAdjustmentParams params) {
    state = state.copyWith(colorAdjustments: params);
  }

  void applyFilterPreset(String? preset) {
    state = state.copyWith(activeFilterPreset: preset);
  }

  Future<PhotoEntity?> saveImage() async {
    final current = state.photo;
    if (current == null) return null;

    state = state.copyWith(isSaving: true);
    try {
      final originalFile = File(current.filePath);
      if (!await originalFile.exists()) {
        throw Exception('Originaldatei nicht gefunden');
      }

      final bytes = await originalFile.readAsBytes();
      final processedBytes = await ImageProcessingService.processImage(
        ImageProcessInput(
          imageBytes: bytes,
          resizeWidth: state.targetWidth,
          resizeHeight: state.targetHeight,
          rotateDegrees: state.rotationDegrees,
          flipHorizontal: state.flipHorizontal,
          flipVertical: state.flipVertical,
          brightness: state.colorAdjustments.brightness,
          contrast: state.colorAdjustments.contrast,
          saturation: state.colorAdjustments.saturation,
          filterPreset: state.activeFilterPreset,
        ),
      );

      // Save as new edited photo file
      final docsDir = await getApplicationDocumentsDirectory();
      final newId = const Uuid().v4();
      final newFileName = 'edited_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final newFilePath = p.join(docsDir.path, newFileName);

      final newFile = File(newFilePath);
      await newFile.writeAsBytes(processedBytes);

      final newPhoto = PhotoEntity(
        id: newId,
        filePath: newFilePath,
        fileName: newFileName,
        fileExtension: 'jpg',
        fileSizeBytes: processedBytes.lengthInBytes,
        width: state.targetWidth ?? current.width,
        height: state.targetHeight ?? current.height,
        dateTaken: DateTime.now(),
        dateAdded: DateTime.now(),
        category: 'Bearbeitet 🎨',
        tags: [...current.tags, 'bearbeitet', if (state.selectedWebPreset != null) 'web_optimiert'],
      );

      final repo = _ref.read(photoRepositoryProvider);
      await repo.savePhoto(newPhoto);

      state = state.copyWith(isSaving: false);
      return newPhoto;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return null;
    }
  }
}

final editorControllerProvider = StateNotifierProvider.family<EditorNotifier, EditorState, PhotoEntity?>((ref, photo) {
  return EditorNotifier(ref, photo);
});
