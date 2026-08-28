import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:controle_gastos/firebase_options.dart';

import 'package:controle_gastos/controller/home_controller.dart';
import 'package:controle_gastos/controller/despesas_recorrentes_controller.dart';
import 'package:controle_gastos/controller/relatorios_controller.dart';

import 'package:controle_gastos/screens/splash_screen.dart';

// ============================================================
// INICIALIZAÇÃO DO APLICATIVO
// ============================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await initializeDateFormatting();

  Intl.defaultLocale = 'pt_BR';

  runApp(const MyApp());
}

// ============================================================
// APLICATIVO PRINCIPAL
// ============================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // ============================================================
  // CRIAR HOME CONTROLLER
  // ============================================================

  HomeController criarHomeController(BuildContext contexto) {
    return HomeController();
  }

  // ============================================================
  // CRIAR DESPESAS RECORRENTES CONTROLLER
  // ============================================================

  DespesasRecorrentesController criarDespesasRecorrentesController(
    BuildContext contexto,
  ) {
    return DespesasRecorrentesController();
  }

  // ============================================================
  // CRIAR RELATÓRIOS CONTROLLER
  // ============================================================

  RelatoriosController criarRelatoriosController(BuildContext contexto) {
    return RelatoriosController();
  }

  // ============================================================
  // CONSTRUÇÃO DO APLICATIVO
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HomeController>(create: criarHomeController),

        ChangeNotifierProvider<DespesasRecorrentesController>(
          create: criarDespesasRecorrentesController,
        ),

        ChangeNotifierProvider<RelatoriosController>(
          create: criarRelatoriosController,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        locale: const Locale('pt', 'BR'),

        supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],

        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        theme: ThemeData(
          useMaterial3: true,

          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF272757),
            brightness: Brightness.light,
          ),

          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF272757),
            foregroundColor: Colors.white,
            elevation: 4,
          ),

          cardTheme: const CardThemeData(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),

          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          brightness: Brightness.light,

          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),

        themeMode: ThemeMode.light,

        home: const SplashScreen(),
      ),
    );
  }
}
