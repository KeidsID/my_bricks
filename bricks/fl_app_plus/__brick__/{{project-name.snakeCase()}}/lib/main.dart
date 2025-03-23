import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "service_locator.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ServiceLocator.init();

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text("Hello World!"),
        ),
      ),
    );
  }
}
