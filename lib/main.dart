import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/servicio_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ImpulsoPacenoApp());
}

class ImpulsoPacenoApp extends StatelessWidget {
  const ImpulsoPacenoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ServicioProvider()..cargarMisServicios(),
      child: MaterialApp(
        title: 'Impulso Paceño',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('es')],
        locale: const Locale('es'),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00695C),
          ),
          useMaterial3: true,
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
          cardTheme: const CardThemeData(
            elevation: 1,
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
