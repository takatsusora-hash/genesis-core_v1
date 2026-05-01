import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class GenesisCoreApp extends StatelessWidget {
  const GenesisCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GenesisCore',
      theme: genesisCoreDarkTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
