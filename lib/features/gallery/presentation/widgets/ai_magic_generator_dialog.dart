import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photokids_studio/core/theme/app_colors.dart';
import 'package:photokids_studio/domain/entities/photo_entity.dart';
import 'package:photokids_studio/features/gallery/presentation/controllers/gallery_controller.dart';
import 'package:photokids_studio/services/ai/ai_image_generator_service.dart';

class AiMagicGeneratorDialog extends ConsumerStatefulWidget {
  const AiMagicGeneratorDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AiMagicGeneratorDialog(),
    );
  }

  @override
  ConsumerState<AiMagicGeneratorDialog> createState() => _AiMagicGeneratorDialogState();
}

class _AiMagicGeneratorDialogState extends ConsumerState<AiMagicGeneratorDialog> {
  final _promptController = TextEditingController();
  final _focusNode = FocusNode();
  String _selectedStyle = 'Pixar 3D 🎨';
  bool _isLoading = false;
  String? _errorMessage;
  PhotoEntity? _generatedPhoto;

  final List<String> _quickIdeas = const [
    '🦄 Einhorn im Zauberwald',
    '🚀 Astronauten-Katze im Weltall',
    '🦖 Freundlicher Dino mit Mütze',
    '🌈 Regenbogen-Schloss aus Zuckerwatte',
    '🐶 Süßer Welpe mit Sonnenbrille',
    '🐬 Delphin springt über Wellen',
    '🦁 Kleiner Löwenkönig im Dschungel',
    '🍦 Riesen-Eisbecher mit Erdbeeren',
  ];

  @override
  void dispose() {
    _promptController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _generateImage() async {
    final text = _promptController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'Bitte tippe oder sprich zuerst eine Idee ein! 😊';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _generatedPhoto = null;
    });

    try {
      final photo = await AiImageGeneratorService.generateImage(
        prompt: text,
        style: _selectedStyle,
      );

      if (photo != null) {
        await ref.read(galleryControllerProvider.notifier).saveNewPhoto(photo);
        if (mounted) {
          setState(() {
            _isLoading = false;
            _generatedPhoto = photo;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Das Bild konnte gerade nicht erstellt werden. Bitte versuche es erneut!';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Netzwerkfehler: Bitte prüfe deine Internetverbindung. ($e)';
        });
      }
    }
  }

  void _showVoiceInputHint() {
    _focusNode.requestFocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.mic_rounded, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Tippe auf das Mikrofon-Symbol 🎙️ auf deiner Handy-Tastatur, um direkt loszusprechen!',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.purpleAccent,
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.9),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF231C2E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.purpleGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Text('🪄', style: TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KI Zauber-Pinsel ✨',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          'Kostenlos Bilder mit Worten & Sprache zaubern',
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
              const Divider(height: 24),

              // Generated Result View (when ready)
              if (_generatedPhoto != null) ...[
                _buildSuccessView(_generatedPhoto!, isDark),
              ] else if (_isLoading) ...[
                _buildLoadingView(isDark),
              ] else ...[
                // Prompt Input Box
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C243B) : const Color(0xFFF7F4FA),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.purpleLight.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 14),
                      const Text('🎨', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _promptController,
                          focusNode: _focusNode,
                          maxLines: 1,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) {
                            FocusScope.of(context).unfocus();
                            _generateImage();
                          },
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          decoration: const InputDecoration(
                            hintText: 'Was soll die KI malen? (Text oder Sprache)...',
                            hintStyle: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.normal),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      // Speech / Microphone Button
                      IconButton(
                        icon: const Icon(Icons.mic_rounded, color: AppColors.purpleAccent, size: 26),
                        tooltip: 'Spracheingabe (Mikrofon)',
                        onPressed: _showVoiceInputHint,
                      ),
                      if (_promptController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          onPressed: () => setState(() => _promptController.clear()),
                        ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Style Selector
                const Text(
                  'Wähle einen Malstil:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: AiImageGeneratorService.styleModifiers.keys.map((style) {
                    final isSelected = _selectedStyle == style;
                    return ChoiceChip(
                      label: Text(style),
                      selected: isSelected,
                      selectedColor: AppColors.purpleAccent.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? AppColors.purpleAccent : (isDark ? Colors.white70 : Colors.black87),
                        fontSize: 12,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedStyle = style);
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 14),

                // Quick Ideas
                const Text(
                  'Oder wähle eine tolle Idee zum Starten:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _quickIdeas.map((idea) {
                    return ActionChip(
                      backgroundColor: isDark ? const Color(0xFF2C243B) : const Color(0xFFF1EDF8),
                      label: Text(idea, style: const TextStyle(fontSize: 12)),
                      onPressed: () {
                        setState(() {
                          _promptController.text = idea.split(' ').sublist(1).join(' ');
                        });
                      },
                    );
                  }).toList(),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],

                const SizedBox(height: 18),

                // Generate Button
                Container(
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: AppColors.purpleGradient,
                    borderRadius: BorderRadius.circular(27),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.purpleAccent.withValues(alpha: 0.4),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                    ),
                    onPressed: _generateImage,
                    icon: const Text('🪄', style: TextStyle(fontSize: 22)),
                    label: const Text(
                      'Bild herzaubern! 🎨',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.purpleGradient,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🪄', style: TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(color: AppColors.purpleAccent),
          const SizedBox(height: 18),
          const Text(
            'Die Zauberei malt dein Bild... ✨🎨',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Das dauert nur etwa 5 bis 10 Sekunden. Freu dich auf dein Kunstwerk!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(PhotoEntity photo, bool isDark) {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🎉', style: TextStyle(fontSize: 26)),
            SizedBox(width: 8),
            Text(
              'Juhu! Dein Bild ist fertig!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Image Preview
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Image.file(
              File(photo.filePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '💾 Automatisch in deiner Galerie gespeichert!',
          style: TextStyle(fontSize: 13, color: AppColors.turquoiseSecondary, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 18),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () {
                  setState(() {
                    _generatedPhoto = null;
                    _promptController.clear();
                  });
                },
                icon: const Text('🪄'),
                label: const Text('Nochmal zaubern', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pinkPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push('/viewer', extra: photo);
                },
                icon: const Icon(Icons.photo_rounded, size: 18),
                label: const Text('Ansehen & Verzieren 🎨', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
