import 'package:go_router/go_router.dart';
import 'package:denis_phote_world/domain/entities/photo_entity.dart';
import 'package:denis_phote_world/features/albums/presentation/screens/albums_screen.dart';
import 'package:denis_phote_world/features/cloud/presentation/screens/cloud_screen.dart';
import 'package:denis_phote_world/features/editor/presentation/screens/editor_screen.dart';
import 'package:denis_phote_world/features/gallery/presentation/screens/gallery_screen.dart';
import 'package:denis_phote_world/features/settings/presentation/screens/settings_screen.dart';
import 'package:denis_phote_world/features/slideshow/presentation/screens/slideshow_screen.dart';
import 'package:denis_phote_world/features/viewer/presentation/screens/viewer_screen.dart';
import 'package:denis_phote_world/shared/widgets/main_navigation_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainNavigationShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const GalleryScreen(),
        ),
        GoRoute(
          path: '/albums',
          builder: (context, state) => const AlbumsScreen(),
        ),
        GoRoute(
          path: '/slideshow',
          builder: (context, state) => const SlideshowScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/cloud',
          builder: (context, state) => const CloudScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/viewer',
      builder: (context, state) {
        final photo = state.extra as PhotoEntity?;
        return ViewerScreen(photo: photo);
      },
    ),
    GoRoute(
      path: '/editor',
      builder: (context, state) {
        final photo = state.extra as PhotoEntity?;
        return EditorScreen(photo: photo);
      },
    ),
  ],
);
