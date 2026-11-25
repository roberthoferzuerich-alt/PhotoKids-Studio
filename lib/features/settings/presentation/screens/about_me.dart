import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:photokids_studio/core/theme/app_colors.dart';
import 'package:photokids_studio/shared/widgets/install_app_dialog.dart';

class AboutMeScreen extends StatelessWidget {
  const AboutMeScreen({super.key});

  void _copyEmail(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: 'robert.hofer.zuerich@bluewin.ch'));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 E-Mail Adresse (robert.hofer.zuerich@bluewin.ch) in Zwischenablage kopiert!'),
        backgroundColor: AppColors.turquoiseDark,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareApp(BuildContext context) {
    Share.share(
      'Schau dir PhotoKids Studio an – die moderne, kindgerechte Foto- und Kreativ-App von Robert Hofer (Zürich)!\n'
      'GitHub: https://github.com/roberthoferzuerich-alt/PhotoKids-Studio.git',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Über mich & das Studio 👨‍💻'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Header Profile Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(
                        colors: [Color(0xFF2C243B), Color(0xFF1E1829)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFFFFF0F5), Color(0xFFE8F5E9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark ? Colors.white12 : AppColors.pinkPrimary.withValues(alpha: 0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar with Swiss Flag Accent
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.pinkGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.pinkPrimary.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('👨‍💻', style: TextStyle(fontSize: 52)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.redAccent, width: 1.5),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        child: const Text('🇨🇭', style: TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Name
                  const Text(
                    'Robert Hofer',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Location
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        'Zürich, Schweiz 🇨🇭',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Email Chip with Copy Action (Responsive & Overflow-Safe)
                  InkWell(
                    onTap: () => _copyEmail(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.turquoiseSecondary.withValues(alpha: isDark ? 0.2 : 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.turquoiseSecondary, width: 1.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.email_rounded, color: AppColors.turquoiseDark, size: 18),
                          const SizedBox(width: 8),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: const Text(
                                'robert.hofer.zuerich@bluewin.ch',
                                style: TextStyle(
                                  color: AppColors.turquoiseDark,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.copy_rounded, color: AppColors.turquoiseDark, size: 15),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Warm Invitation Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF282035) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.yellowAccent.withValues(alpha: 0.6),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.yellowAccent.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.yellowSoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Text('💌', style: TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Herzlich Willkommen!',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'PhotoKids Studio ist ein echtes Herzensprojekt. Entwickelt mit ganz viel Liebe für meine Tochter Denis '
                    'und unsere Familie – als sichere, bunte und kreative Heimat für unsere wertvollsten Fotos und Erinnerungen.',
                    style: TextStyle(fontSize: 14, height: 1.45),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.pinkSoft,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.pinkLight.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('✨', style: TextStyle(fontSize: 18)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '„Und wenn Du möchtest, bist Du herzlich eingeladen!“',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.italic,
                              color: AppColors.pinkDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ob für Fragen, neue Ideen für kinderfreundliche Fotofunktionen oder einen herzlichen Austausch: '
                    'Ich freue mich jederzeit über deine Kontaktaufnahme!',
                    style: TextStyle(fontSize: 13, height: 1.4, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Vision & Features Grid
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF282035) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Philosophie von PhotoKids Studio 🌟',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureBullet(
                    emoji: '🛡️',
                    title: '100% Kindersicher & Werbefrei',
                    description: 'Keine Werbung, kein Tracking, integrierter Eltern-Schutz (PIN/Mathe-Challenge).',
                  ),
                  _buildFeatureBullet(
                    emoji: '🔒',
                    title: 'Lokale Privatsphäre & SQLite',
                    description: 'Fotos und Alben verbleiben sicher auf dem Gerät der Familie.',
                  ),
                  _buildFeatureBullet(
                    emoji: '🎨',
                    title: 'Kreativstudio mit Herz',
                    description: 'Magische Bilderrahmen, Malbuch-Modus, Sprechblasen, Sticker & Grußkarten.',
                  ),
                  _buildFeatureBullet(
                    emoji: '🌐',
                    title: 'Web- & Social-Media Export',
                    description: 'Optimierte Bildgrößen für Webseiten, Blogs, Instagram und WhatsApp.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.turquoiseSecondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    icon: const Icon(Icons.mail_rounded, size: 20),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('E-Mail schreiben', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    onPressed: () => _copyEmail(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.pinkPrimary,
                      side: const BorderSide(color: AppColors.pinkPrimary, width: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    icon: const Icon(Icons.share_rounded, size: 20),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('App teilen', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    onPressed: () => _shareApp(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.turquoiseSecondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.install_mobile_rounded, size: 22),
                label: const Text('App aufs Smartphone laden 📲', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                onPressed: () => InstallAppDialog.show(context),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? AppColors.pinkLight : AppColors.pinkDark,
                  side: BorderSide(color: AppColors.pinkPrimary.withValues(alpha: 0.6), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.auto_awesome_rounded, size: 22),
                label: const Text('Alle 16 Repositories im Web ansehen 🚀', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                onPressed: () {
                  Clipboard.setData(const ClipboardData(text: 'https://roberthoferzuerich-alt.github.io/portfolio/'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🌐 Link zum neuen Portfolio kopiert! (https://roberthoferzuerich-alt.github.io/portfolio/)'),
                      backgroundColor: AppColors.pinkPrimary,
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Footer
            Center(
              child: Text(
                'PhotoKids Studio v1.0.1 • Zürich 🇨🇭\nEntwickelt mit Liebe für Denis & die ganze Familie',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.black45,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBullet({
    required String emoji,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
