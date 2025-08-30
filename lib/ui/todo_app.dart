import 'package:flutter/material.dart';
import 'package:todoapp/ui/l10n/app_localizations.dart';
import 'package:todoapp/ui/todo_app_router_config.dart';

class TodoApp extends StatelessWidget {
  final _todoAppRouterConfig = TodoAppRouterConfig();

  TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    const baseColor = Color.fromARGB(255, 239, 232, 215);
    return MaterialApp.router(
      title: 'Todo list',
      routerConfig: _todoAppRouterConfig.config(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: baseColor,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: baseColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
    );
  }
}
