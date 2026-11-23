import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:denis_phote_world/core/theme/app_colors.dart';
import 'package:denis_phote_world/features/settings/presentation/controllers/settings_controller.dart';
import 'package:denis_phote_world/shared/widgets/parental_gate_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _changeParentPin(BuildContext context, WidgetRef ref) {
    final pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Neue Eltern-PIN festlegen 🔒'),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            hintText: '4-stellige PIN eingeben',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () {
              final pin = pinController.text.trim();
              if (pin.length >= 4) {
                ref.read(settingsControllerProvider.notifier).setParentPin(pin);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN erfolgreich gespeichert!')),
                );
              }
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsControllerProvider);
    final settingsNotifier = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen ⚙️'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Kindermodus Section
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: SwitchListTile(
              secondary: const Text('👧', style: TextStyle(fontSize: 28)),
              title: const Text(
                'Kinder-Modus aktiv',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: const Text('Verhindert unabsichtliches Löschen und schützt Systemeinstellungen.'),
              value: settingsState.isKidMode,
              activeColor: AppColors.pinkPrimary,
              onChanged: (active) {
                if (!active) {
                  // Unlocking kid mode requires parental gate
                  ParentalGateDialog.show(
                    context,
                    onAuthenticated: () => settingsNotifier.setKidModeDirect(false),
                  );
                } else {
                  settingsNotifier.setKidModeDirect(true);
                }
              },
            ),
          ),
          const SizedBox(height: 12),

          // Eltern-PIN Section
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: ListTile(
              leading: const Text('🔐', style: TextStyle(fontSize: 28)),
              title: const Text('Eltern-PIN ändern', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Schützt die Sicherheitsabfragen vor den Kleinen.'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                ParentalGateDialog.show(
                  context,
                  onAuthenticated: () => _changeParentPin(context, ref),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Cloud Sync (V2 Preview)
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: ListTile(
              leading: const Text('☁️', style: TextStyle(fontSize: 28)),
              title: const Text('Cloud-Synchronisation (Version 2)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('OneDrive, Google Drive, Dropbox, iCloud Backup-Status'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () => context.push('/cloud'),
            ),
          ),
          const SizedBox(height: 12),

          // Slideshow Speed
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('⏱️', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      const Text(
                        'Diashow Geschwindigkeit',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Spacer(),
                      Text(
                        '${settingsState.slideshowSpeed} Sekunden',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.purpleAccent),
                      ),
                    ],
                  ),
                  Slider(
                    value: settingsState.slideshowSpeed.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    activeColor: AppColors.purpleAccent,
                    onChanged: (val) => settingsNotifier.setSlideshowSpeed(val.toInt()),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Retention Info
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: const ListTile(
              leading: Text('🗑️', style: TextStyle(fontSize: 28)),
              title: Text('Papierkorb-Aufbewahrung', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Gelöschte Fotos werden für 30 Tage aufbewahrt und können wiederhergestellt werden.'),
            ),
          ),
          const SizedBox(height: 24),

          // App Info
          Center(
            child: Column(
              children: const [
                Text(
                  'PhotoKids Studio v1.0.0',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                SizedBox(height: 4),
                Text(
                  'Mit Liebe gebaut für Kinder & Familien 💖',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
