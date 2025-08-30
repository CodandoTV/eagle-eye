import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class WidgetsUtil {
  static Widget buildMaterialAppWidgetTest({
    required Widget child,
    required WidgetTester tester,
  }) {
    TestWidgetsFlutterBinding.ensureInitialized();

    const baseColor = Color.fromARGB(255, 239, 232, 215);

    return MaterialApp(
      home: child,
      themeMode: ThemeMode.dark,
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
