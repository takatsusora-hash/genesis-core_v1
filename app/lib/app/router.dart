import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/chat/presentation/chat_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/lab/presentation/lab_page.dart';
import '../features/log/presentation/log_page.dart';
import '../features/my_core/presentation/my_core_page.dart';
import '../shared/widgets/main_scaffold.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/home', builder: (_, __) => const HomePage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/my-core', builder: (_, __) => const MyCorePage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/chat', builder: (_, __) => const ChatPage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/log', builder: (_, __) => const LogPage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/lab', builder: (_, __) => const LabPage()),
          ],
        ),
      ],
    ),
  ],
);
