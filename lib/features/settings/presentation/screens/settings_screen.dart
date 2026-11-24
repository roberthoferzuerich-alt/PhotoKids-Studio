import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photokids_studio/core/di/app_providers.dart';
import 'package:photokids_studio/core/theme/app_colors.dart';
import 'package:photokids_studio/core/utils/sample_data_seeder.dart';
import 'package:photokids_studio/features/gallery/presentation/controllers/gallery_controller.dart';
import 'package:photokids_studio/features/settings/presentation/controllers/settings_controller.dart';
import 'package:photokids_studio/shared/widgets/install_app_dialog.dart';
import 'package:photokids_studio/shared/widgets/parental_gate_dialog.dart';

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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkPrimary, foregroundColor: Colors.white),
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

  void _reSeedDemoPhotos(BuildContext context, WidgetRef ref) async {
    final photoRepo = ref.read(photoRepositoryProvider);
    final albumRepo = ref.read(albumRepositoryProvider);
    await SampleDataSeeder.forceReSeed(photoRepo, albumRepo);
    await ref.read(galleryControllerProvider.notifier).loadPhotos();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎨 Schöne neue Demobilder wurden erfolgreich erstellt!')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsControllerProvider);
    final settingsNotifier = ref.read(settingsControllerProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Eltern-Bereich & Einstellungen ⚙️'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 95),
        children: [
          // Kindermodus Section
          Card(
            child: SwitchListTile(
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.yellowLight,
                  shape: BoxShape.circle,
                ),
                child: const Text('👧', style: TextStyle(fontSize: 22)),
              ),
              title: const Text(
                'Kinder-Modus aktiv',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              subtitle: const Text('Verhindert unabsichtliches Löschen und schützt Systemeinstellungen.'),
              value: settingsState.isKidMode,
              activeColor: AppColors.pinkPrimary,
              onChanged: (active) {
                if (!active) {
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
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.pinkSoft,
                  shape: BoxShape.circle,
                ),
                child: const Text('🔐', style: TextStyle(fontSize: 22)),
              ),
              title: const Text('Eltern-PIN ändern', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('Schützt die Sicherheitsabfragen vor den Kleinen.'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ParentalGateDialog.show(
                  context,
                  onAuthenticated: () => _changeParentPin(context, ref),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Beautiful Demobilder neu laden Button
          Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.turquoiseSoft,
                  shape: BoxShape.circle,
                ),
                child: const Text('🎨', style: TextStyle(fontSize: 22)),
              ),
              title: const Text('Schöne Demobilder laden', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('Aktualisiert die Beispielbilder mit hübschen Strand-, Tier- & Regenbogengrafiken.'),
              trailing: const Icon(Icons.refresh_rounded, color: AppColors.turquoiseSecondary),
              onTap: () => _reSeedDemoPhotos(context, ref),
            ),
          ),
          const SizedBox(height: 12),

          // Cloud Sync (V2 Preview)
          Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.purpleSoft,
                  shape: BoxShape.circle,
                ),
                child: const Text('☁️', style: TextStyle(fontSize: 22)),
              ),
              title: const Text('Cloud-Synchronisation (V2)', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('OneDrive, Google Drive, Dropbox, iCloud Backup-Status'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.push('/cloud'),
            ),
          ),
          const SizedBox(height: 12),

          // App auf Smartphone installieren (Android & Apple)
          Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.turquoiseSoft,
                  shape: BoxShape.circle,
                ),
                child: const Text('📲', style: TextStyle(fontSize: 22)),
              ),
              title: const Text('App aufs Smartphone installieren 📱', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('Anleitung & QR-Code für Android (Samsung, Pixel) & Apple (iPhone, iPad).'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => InstallAppDialog.show(context),
            ),
          ),
          const SizedBox(height: 12),

          // Über Robert Hofer / About Me
          Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.pinkSoft,
                  shape: BoxShape.circle,
                ),
                child: const Text('👨‍💻', style: TextStyle(fontSize: 22)),
              ),
              title: const Text('Über Robert Hofer 🇨🇭', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text(
                'Zürich • robert.hofer.zuerich@bluewin.ch • Herzlich Eingeladen!',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.push('/about'),
            ),
          ),
          const SizedBox(height: 12),

          // Slideshow Speed
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('⏱️', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      const Text(
                        'Diashow Geschwindigkeit',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                      const Spacer(),
                      Text(
                        '${settingsState.slideshowSpeed}s',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.purpleAccent),
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
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: const Text('🗑️', style: TextStyle(fontSize: 22)),
              ),
              title: const Text('Papierkorb-Aufbewahrung', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('Gelöschte Fotos werden für 30 Tage aufbewahrt und können wiederhergestellt werden.'),
            ),
          ),
          const SizedBox(height: 24),

          // App Info
          const Center(
            child: Column(
              children: [
                Text(
                  'PhotoKids Studio v1.1.0',
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
