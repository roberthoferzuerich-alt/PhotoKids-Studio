import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photokids_studio/core/theme/app_colors.dart';

class InstallAppDialog extends StatefulWidget {
  const InstallAppDialog({super.key});

  static const String appUrl = 'https://roberthoferzuerich-alt.github.io/PhotoKids-Studio/';
  static const String apkReleasesUrl = 'https://github.com/roberthoferzuerich-alt/PhotoKids-Studio/releases/tag/v1.0.1';
  static const String directApkUrl = 'https://github.com/roberthoferzuerich-alt/PhotoKids-Studio/releases/download/v1.0.1/app-release.apk';

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const InstallAppDialog(),
    );
  }

  @override
  State<InstallAppDialog> createState() => _InstallAppDialogState();
}

class _InstallAppDialogState extends State<InstallAppDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedQrMode = 0; // 0: Web-App, 1: APK-Download

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _copyLink(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: InstallAppDialog.appUrl));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 Link zur App in die Zwischenablage kopiert!'),
        backgroundColor: AppColors.turquoiseDark,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF231B30) : Colors.white;

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 660),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(
                        colors: [Color(0xFF2F2442), Color(0xFF20182E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFFFFEEF3), Color(0xFFE8FBF8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.pinkPrimary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('📲', style: TextStyle(fontSize: 26)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'App aufs Handy laden',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF222222),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'PhotoKids Studio für Android & Apple',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
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

            // Platform Tabs
            Container(
              color: isDark ? const Color(0xFF1B1426) : const Color(0xFFF7F5F9),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.pinkPrimary,
                indicatorWeight: 3,
                labelColor: AppColors.pinkPrimary,
                unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
                labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                tabs: const [
                  Tab(icon: Icon(Icons.android_rounded, size: 20), text: 'Android'),
                  Tab(icon: Icon(Icons.apple_rounded, size: 22), text: 'Apple (iOS)'),
                  Tab(icon: Icon(Icons.qr_code_2_rounded, size: 20), text: 'QR-Code'),
                ],
              ),
            ),

            // Tab Views
            Flexible(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAndroidTab(context, isDark),
                  _buildAppleTab(context, isDark),
                  _buildQrCodeTab(context, isDark),
                ],
              ),
            ),

            // Bottom Actions Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
              ),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppColors.turquoiseLight : AppColors.turquoiseDark,
                      side: BorderSide(color: isDark ? AppColors.turquoiseLight : AppColors.turquoiseDark),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Link kopieren', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: () => _copyLink(context),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pinkPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Schließen', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAndroidTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Method 1: Web App / PWA (Recommended)
          _buildMethodHeader('1. Als Web-App installieren 🌟', 'Empfohlen für Samsung, Google Pixel, Xiaomi & Co.', isDark),
          const SizedBox(height: 10),
          _buildStepCard(
            stepNumber: '1',
            icon: Icons.public_rounded,
            title: 'In Chrome öffnen',
            description: 'Öffne diesen Link in Google Chrome auf deinem Smartphone.',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildStepCard(
            stepNumber: '2',
            icon: Icons.more_vert_rounded,
            title: 'Menü antippen',
            description: 'Tippe oben rechts auf das Dreipunkte-Menü (⋮).',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildStepCard(
            stepNumber: '3',
            icon: Icons.add_to_home_screen_rounded,
            title: '„App installieren“ wählen',
            description: 'Wähle „App installieren“ oder „Zum Startbildschirm hinzufügen“.',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildStepCard(
            stepNumber: '4',
            icon: Icons.check_circle_rounded,
            title: 'Fertig!',
            description: 'PhotoKids Studio erscheint mit eigenem Icon und läuft im echten Vollbildmodus!',
            isDark: isDark,
            isSuccess: true,
          ),

          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 10),

          // Method 2: APK
          _buildMethodHeader('2. Native Android APK-Datei 🤖', 'Für vollständige Offline-Nutzung ohne Browser', isDark),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C243B) : const Color(0xFFF1FBF8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.turquoiseSecondary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.android_rounded, color: AppColors.turquoiseSecondary, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PhotoKids-Studio-v1.0.1.apk',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        'Direkter APK-Download (v1.0.1, 62.8 MB)',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.turquoiseSecondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('APK Link', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Clipboard.setData(const ClipboardData(text: InstallAppDialog.directApkUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('📥 Direkter APK-Download-Link kopiert!'),
                        backgroundColor: AppColors.turquoiseDark,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppleTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMethodHeader('Installation auf iPhone & iPad 🍎', 'Ganz einfach in 4 Schritten über Safari (ohne App Store Zwang)', isDark),
          const SizedBox(height: 12),
          _buildStepCard(
            stepNumber: '1',
            icon: Icons.explore_rounded,
            title: 'In Safari öffnen',
            description: 'Öffne diese Seite mit dem Safari-Browser auf deinem iPhone oder iPad.',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildStepCard(
            stepNumber: '2',
            icon: Icons.ios_share_rounded,
            title: 'Teilen-Button antippen',
            description: 'Tippe unten in der Leiste auf das Teilen-Symbol (Viereck mit Pfeil nach oben 📤).',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildStepCard(
            stepNumber: '3',
            icon: Icons.add_box_rounded,
            title: '„Zum Home-Bildschirm“',
            description: 'Scrolle im Menü etwas nach unten und wähle „Zum Home-Bildschirm“ (➕).',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildStepCard(
            stepNumber: '4',
            icon: Icons.done_all_rounded,
            title: '„Hinzufügen“ antippen',
            description: 'Tippe oben rechts auf „Hinzufügen“. PhotoKids Studio erscheint direkt auf deinem Home-Bildschirm!',
            isDark: isDark,
            isSuccess: true,
          ),
        ],
      ),
    );
  }

  Widget _buildQrCodeTab(BuildContext context, bool isDark) {
    final targetUrl = _selectedQrMode == 0 ? InstallAppDialog.appUrl : InstallAppDialog.directApkUrl;
    final qrImageUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=260x260&data=${Uri.encodeComponent(targetUrl)}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          // Mode Toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B1426) : const Color(0xFFEEEBF3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _selectedQrMode = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedQrMode == 0 ? AppColors.pinkPrimary : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _selectedQrMode == 0
                          ? [BoxShadow(color: AppColors.pinkPrimary.withValues(alpha: 0.3), blurRadius: 6)]
                          : null,
                    ),
                    child: Text(
                      '🌐 Web-App',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _selectedQrMode == 0 ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _selectedQrMode = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedQrMode == 1 ? AppColors.turquoiseSecondary : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _selectedQrMode == 1
                          ? [BoxShadow(color: AppColors.turquoiseSecondary.withValues(alpha: 0.3), blurRadius: 6)]
                          : null,
                    ),
                    child: Text(
                      '🤖 APK Download',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _selectedQrMode == 1 ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Text(
            _selectedQrMode == 0 ? 'Web-App am Handy öffnen 🌐' : 'Direkter APK-Download aufs Handy 📥',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _selectedQrMode == 0
                ? 'Halte die Kamera auf den QR-Code, um die Web-App direkt im Browser zu öffnen:'
                : 'Scanne den QR-Code, um PhotoKids-Studio-v1.0.0.apk (62.8 MB) direkt herunterzuladen:',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54),
          ),
          const SizedBox(height: 14),

          // QR Code Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                qrImageUrl,
                width: 180,
                height: 180,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 180,
                    height: 180,
                    color: Colors.white,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 180,
                    height: 180,
                    color: const Color(0xFFF7F5F9),
                    padding: const EdgeInsets.all(12),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.qr_code_2_rounded, size: 44, color: AppColors.pinkPrimary),
                          const SizedBox(height: 6),
                          Text(
                            targetUrl,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 14),

          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: targetUrl));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_selectedQrMode == 0 ? '📋 Web-App Link kopiert!' : '📥 APK-Download-Link kopiert!'),
                  backgroundColor: AppColors.turquoiseDark,
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C243B) : const Color(0xFFFFF0F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (_selectedQrMode == 0 ? AppColors.pinkPrimary : AppColors.turquoiseSecondary).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _selectedQrMode == 0 ? Icons.open_in_browser_rounded : Icons.file_download_outlined,
                    size: 16,
                    color: _selectedQrMode == 0 ? AppColors.pinkPrimary : AppColors.turquoiseSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _selectedQrMode == 0 ? 'Kopiere: WebApp Link' : 'Kopiere: Direkter APK-Link',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodHeader(String title, String subtitle, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildStepCard({
    required String stepNumber,
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
    bool isSuccess = false,
  }) {
    final cardColor = isDark
        ? (isSuccess ? const Color(0xFF1E3830) : const Color(0xFF2B2238))
        : (isSuccess ? const Color(0xFFE8F9F3) : Colors.white);

    final borderColor = isSuccess
        ? AppColors.turquoiseSecondary
        : (isDark ? Colors.white12 : const Color(0xFFEDE8F2));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isSuccess ? 1.5 : 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isSuccess ? AppColors.turquoiseSecondary : AppColors.pinkPrimary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: isSuccess
                          ? AppColors.turquoiseSecondary
                          : (isDark ? AppColors.pinkLight : AppColors.pinkPrimary),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
