import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photokids_studio/core/theme/app_colors.dart';
import 'package:photokids_studio/features/settings/presentation/controllers/settings_controller.dart';

/// Parental Gate Dialog:
/// Protects settings, permanent deletion, and cloud sync.
/// Can be unlocked either via parent PIN or a fun math problem for older parents.
class ParentalGateDialog extends ConsumerStatefulWidget {
  final VoidCallback onAuthenticated;

  const ParentalGateDialog({super.key, required this.onAuthenticated});

  static Future<void> show(BuildContext context, {required VoidCallback onAuthenticated}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ParentalGateDialog(onAuthenticated: onAuthenticated),
    );
  }

  @override
  ConsumerState<ParentalGateDialog> createState() => _ParentalGateDialogState();
}

class _ParentalGateDialogState extends ConsumerState<ParentalGateDialog> {
  final _pinController = TextEditingController();
  late int num1;
  late int num2;
  String? _error;

  @override
  void initState() {
    super.initState();
    final rand = Random();
    num1 = rand.nextInt(12) + 7;
    num2 = rand.nextInt(8) + 4;
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _verify() async {
    final input = _pinController.text.trim();
    final mathResult = (num1 * num2).toString();

    // Valid if matches math problem OR parent PIN
    if (input == mathResult) {
      Navigator.of(context).pop();
      widget.onAuthenticated();
      return;
    }

    final notifier = ref.read(settingsControllerProvider.notifier);
    final isValidPin = await notifier.verifyAndToggleKidMode(input);

    if (isValidPin) {
      if (mounted) {
        Navigator.of(context).pop();
        widget.onAuthenticated();
      }
    } else {
      setState(() {
        _error = 'Falsche PIN oder Rechenaufgabe!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Row(
        children: const [
          Icon(Icons.lock_rounded, color: AppColors.purpleAccent, size: 30),
          SizedBox(width: 10),
          Text(
            'Eltern-Bereich',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Für Erwachsene: Löse die Matheaufgabe oder gib deine Eltern-PIN ein:',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.yellowAccent.withValues(alpha: 0.2)
                    : AppColors.yellowSoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.yellowAccent.withValues(alpha: 0.6) : AppColors.yellowDark,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  'Wie viel ist $num1 × $num2 ?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFFFFE082) : const Color(0xFF6A4E00),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Antwort oder PIN (Standard: 1234)',
                errorText: _error,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                prefixIcon: const Icon(Icons.key_rounded),
              ),
              onSubmitted: (_) => _verify(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.pinkPrimary,
            foregroundColor: Colors.white,
          ),
          onPressed: _verify,
          child: const Text('Freischalten'),
        ),
      ],
    );
  }
}
