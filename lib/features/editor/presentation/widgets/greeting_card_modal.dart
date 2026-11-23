import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:denis_phote_world/core/theme/app_colors.dart';
import 'package:denis_phote_world/domain/entities/photo_entity.dart';

class GreetingCardPreset {
  final String title;
  final String defaultMessage;
  final String emoji;
  final Color primaryColor;
  final Color secondaryColor;
  final String borderDecoration;

  const GreetingCardPreset({
    required this.title,
    required this.defaultMessage,
    required this.emoji,
    required this.primaryColor,
    required this.secondaryColor,
    required this.borderDecoration,
  });
}

class GreetingCardModal extends StatefulWidget {
  final PhotoEntity photo;

  const GreetingCardModal({super.key, required this.photo});

  static Future<void> show(BuildContext context, {required PhotoEntity photo}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GreetingCardModal(photo: photo),
    );
  }

  @override
  State<GreetingCardModal> createState() => _GreetingCardModalState();
}

class _GreetingCardModalState extends State<GreetingCardModal> {
  static const List<GreetingCardPreset> presets = [
    GreetingCardPreset(
      title: 'Für Oma & Opa ❤️',
      defaultMessage: 'Ihr seid die allerbesten Großeltern der Welt! Hab euch lieb!',
      emoji: '👵👴',
      primaryColor: Color(0xFFFF5964),
      secondaryColor: Color(0xFFFFE5D9),
      borderDecoration: '❤️ 🌸 ❤️ 🌸',
    ),
    GreetingCardPreset(
      title: 'Für Mama & Papa 💖',
      defaultMessage: 'Danke, dass ihr immer für mich da seid! Das schönste Lächeln für euch!',
      emoji: '👨‍👩‍👧',
      primaryColor: Color(0xFFFF70A6),
      secondaryColor: Color(0xFFFFF0F5),
      borderDecoration: '💖 ✨ 💖 ✨',
    ),
    GreetingCardPreset(
      title: 'Alles Gute zum Geburtstag! 🎂',
      defaultMessage: 'Happy Birthday! Lass dich heute feiern und reich beschenken! Hurra!',
      emoji: '🎉',
      primaryColor: Color(0xFFFFB703),
      secondaryColor: Color(0xFFFFF8E7),
      borderDecoration: '🎈 🎂 🎈 🎂',
    ),
    GreetingCardPreset(
      title: 'Schöne Feriengrüße 🏖️',
      defaultMessage: 'Sonnige Urlaubsgrüße! Das Meer ist herrlich und wir haben viel Spaß!',
      emoji: '☀️',
      primaryColor: Color(0xFF00B4D8),
      secondaryColor: Color(0xFFE0F7FA),
      borderDecoration: '🏖️ 🐚 🏖️ 🐚',
    ),
    GreetingCardPreset(
      title: 'Beste Freunde für immer! 👯',
      defaultMessage: 'Zusammen lachen macht am meisten Spaß! Schön, dass es dich gibt!',
      emoji: '⭐',
      primaryColor: Color(0xFF7209B7),
      secondaryColor: Color(0xFFF3E8FF),
      borderDecoration: '⭐ 🌈 ⭐ 🌈',
    ),
    GreetingCardPreset(
      title: 'Frohe Festtage & Neujahr 🎄',
      defaultMessage: 'Eine zauberhafte Weihnachtszeit und einen glücklichen Start ins neue Jahr!',
      emoji: '🎁',
      primaryColor: Color(0xFF2D6A4F),
      secondaryColor: Color(0xFFE8F5E9),
      borderDecoration: '🎄 ⭐ 🎄 ⭐',
    ),
  ];

  late GreetingCardPreset _selectedPreset;
  late TextEditingController _customMessageController;

  @override
  void initState() {
    super.initState();
    _selectedPreset = presets.first;
    _customMessageController = TextEditingController(text: _selectedPreset.defaultMessage);
  }

  @override
  void dispose() {
    _customMessageController.dispose();
    super.dispose();
  }

  void _shareCard() async {
    final photo = widget.photo;
    final text = '${_selectedPreset.title}\n\n"${_customMessageController.text}"\n\nErstellt mit PhotoKids Studio 🎨';
    if (!kIsWeb && File(photo.filePath).existsSync()) {
      await Share.shareXFiles([XFile(photo.filePath)], text: text);
    } else {
      await Share.share(text);
    }
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('💌 Grußkarte erfolgreich geteilt!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle & Header
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.pinkSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('💌', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Grußkarten & Druck-Vorbereitung',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Zaubere eine persönliche Fotokarte für deine Liebsten',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
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
          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Presets Chips Carousel
                  const Text('1. Anlass wählen:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: presets.map((preset) {
                        final isSelected = preset.title == _selectedPreset.title;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text('${preset.emoji} ${preset.title.split(' ').first}'),
                            selected: isSelected,
                            selectedColor: preset.primaryColor.withValues(alpha: 0.25),
                            side: BorderSide(
                              color: isSelected ? preset.primaryColor : Colors.grey[300]!,
                              width: isSelected ? 2.0 : 1.0,
                            ),
                            labelStyle: TextStyle(
                              color: isSelected ? preset.primaryColor : Colors.black87,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              if (val) {
                                setState(() {
                                  _selectedPreset = preset;
                                  _customMessageController.text = preset.defaultMessage;
                                });
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Greeting Card Live Preview Box
                  const Text('2. Kartenvorschau:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      width: 290,
                      decoration: BoxDecoration(
                        color: _selectedPreset.secondaryColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _selectedPreset.primaryColor, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Card Header Title
                          Text(
                            _selectedPreset.title,
                            style: TextStyle(
                              color: _selectedPreset.primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(_selectedPreset.borderDecoration, style: const TextStyle(fontSize: 11)),
                          const SizedBox(height: 8),

                          // Photo In Card
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              height: 160,
                              width: double.infinity,
                              child: _buildPhotoThumbnail(widget.photo),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Message Text
                          Text(
                            '"${_customMessageController.text}"',
                            style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),

                          // Signature
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Mit ganz viel Liebe 💖',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _selectedPreset.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Editable Message Input
                  const Text('3. Grußtext anpassen:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _customMessageController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      hintText: 'Schreibe hier deinen persönlichen Gruß...',
                    ),
                    onChanged: (val) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.print_rounded),
                      label: const Text('Drucken 🖨️', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: _shareCard,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pinkPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.send_rounded),
                      label: const Text('Karte teilen 💌', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: _shareCard,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoThumbnail(PhotoEntity photo) {
    if (!kIsWeb) {
      final file = File(photo.filePath);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }
    return Container(
      color: Colors.grey[300],
      child: const Center(child: Icon(Icons.image, size: 40, color: Colors.black26)),
    );
  }
}
