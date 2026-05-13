import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'package:purificadora_app/features/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const PurificadoraApp());
}

class PurificadoraApp extends StatelessWidget {
  const PurificadoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Purificadora',
      theme: AppTheme.lightTheme,

      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);

        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: TextScaler.linear(1.0)),
          child: child!,
        );
      },

      home: const LoginScreen(),
    );
  }
}
