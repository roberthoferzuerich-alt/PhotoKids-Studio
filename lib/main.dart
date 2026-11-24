import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photokids_studio/core/constants/app_constants.dart';
import 'package:photokids_studio/core/di/app_providers.dart';
import 'package:photokids_studio/core/router/app_router.dart';
import 'package:photokids_studio/core/theme/app_theme.dart';
import 'package:photokids_studio/core/utils/sample_data_seeder.dart';
import 'package:photokids_studio/features/gallery/presentation/controllers/gallery_controller.dart';
import 'package:photokids_studio/features/settings/presentation/controllers/settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();

  try {
    final photoRepo = container.read(photoRepositoryProvider);
    final albumRepo = container.read(albumRepositoryProvider);

    await SampleDataSeeder.seedInitialDataIfNeeded(photoRepo, albumRepo);
    await container.read(galleryControllerProvider.notifier).loadPhotos();
  } catch (e, stack) {
    debugPrint('Startup initialization error: $e\n$stack');
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const PhotoKidsStudioApp(),
    ),
  );
}

class PhotoKidsStudioApp extends ConsumerWidget {
  const PhotoKidsStudioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsControllerProvider);

    ThemeMode themeMode;
    switch (settingsState.themeMode) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
    }

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('de', 'DE'),
        Locale('en', 'US'),
      ],
    );
  }
}
