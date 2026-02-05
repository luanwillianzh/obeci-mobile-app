import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/colors.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/bottom_nav_home_screen.dart';
import 'screens/admin/admin_layout.dart';
import 'screens/admin/admin_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/turma_provider.dart';
import 'providers/escola_provider.dart';
import 'providers/lembrete_provider.dart';
import 'providers/slide_provider.dart';

void main() {
  runApp(const OBECIMobileApp());
}

class OBECIMobileApp extends StatelessWidget {
  const OBECIMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TurmaProvider()),
        ChangeNotifierProvider(create: (_) => EscolaProvider()),
        ChangeNotifierProvider(create: (_) => LembreteProvider()),
        ChangeNotifierProvider(create: (_) => SlideProvider()),
      ],
      child: MaterialApp(
        title: 'OBECI Mobile',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.light(
            primary: OBECIColors.primary,
            secondary: OBECIColors.secondary,
            surface: OBECIColors.surface,
            background: OBECIColors.background,
            error: OBECIColors.error,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: OBECIColors.onSurface,
            onBackground: OBECIColors.foreground,
            onError: OBECIColors.onError,
          ),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const BottomNavHomeScreen(),
          '/admin': (context) => AdminLayout(child: const AdminScreen()),
        },
      ),
    );
  }
}
