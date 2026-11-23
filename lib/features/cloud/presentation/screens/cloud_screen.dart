import 'package:flutter/material.dart';
import 'package:denis_phote_world/core/theme/app_colors.dart';
import 'package:denis_phote_world/services/cloud/cloud_sync_service.dart';

class CloudScreen extends StatefulWidget {
  const CloudScreen({super.key});

  @override
  State<CloudScreen> createState() => _CloudScreenState();
}

class _CloudScreenState extends State<CloudScreen> {
  final Map<CloudProviderType, bool> _connected = {
    CloudProviderType.googleDrive: false,
    CloudProviderType.oneDrive: false,
    CloudProviderType.dropbox: false,
    CloudProviderType.iCloud: false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud & Backup (Version 2) ☁️'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.turquoiseLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.turquoiseSecondary.withOpacity(0.4)),
            ),
            child: Row(
              children: const [
                Text('🛡️', style: TextStyle(fontSize: 32)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Deine Fotos werden sicher und verschlüsselt gespeichert. Die Architektur ist für Offline-Nutzung optimiert.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildCloudTile(
            title: 'Google Drive',
            iconEmoji: '🌐',
            type: CloudProviderType.googleDrive,
          ),
          _buildCloudTile(
            title: 'Microsoft OneDrive',
            iconEmoji: '💼',
            type: CloudProviderType.oneDrive,
          ),
          _buildCloudTile(
            title: 'Dropbox',
            iconEmoji: '📦',
            type: CloudProviderType.dropbox,
          ),
          _buildCloudTile(
            title: 'Apple iCloud',
            iconEmoji: '🍎',
            type: CloudProviderType.iCloud,
          ),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Vorbereitung für KI-Funktionen (Version 3) 🤖', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 8),
                  Text('• Automatische Verschlagwortung (Tags)'),
                  Text('• Objekterkennung (Tiere, Spielzeuge, Natur)'),
                  Text('• Gesichtserkennung & Familien-Gruppierung'),
                  Text('• Duplikaterkennung für Speicherplatzersparnis'),
                  Text('• Hintergrund entfernen (1-Klick Magie)'),
                  Text('• Intelligente Suche in natürlicher Sprache'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloudTile({
    required String title,
    required String iconEmoji,
    required CloudProviderType type,
  }) {
    final isConnected = _connected[type] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        leading: Text(iconEmoji, style: const TextStyle(fontSize: 30)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(isConnected ? 'Verbunden & synchronisiert' : 'Nicht verbunden'),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isConnected ? Colors.grey[300] : AppColors.turquoiseSecondary,
            foregroundColor: isConnected ? Colors.black87 : Colors.white,
          ),
          onPressed: () {
            setState(() {
              _connected[type] = !isConnected;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  !isConnected ? '$title erfolgreich verbunden!' : '$title getrennt.',
                ),
              ),
            );
          },
          child: Text(isConnected ? 'Trennen' : 'Verbinden'),
        ),
      ),
    );
  }
}
