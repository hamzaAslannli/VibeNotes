import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibe_notes/core/theme/app_theme.dart';
import 'package:vibe_notes/features/notes/presentation/pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // In a real app we might initialize the DB here or via a provider that bootstraps the app
  runApp(const ProviderScope(child: VibeNotesApp()));
}

class VibeNotesApp extends StatelessWidget {
  const VibeNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibe Notes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomePage(),
    );
  }
}
