import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:your_turn/l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_turn/src/models/user_data.dart';
import 'package:your_turn/src/pages/login_page.dart';
import 'package:your_turn/src/pages/todo_page.dart';
import 'package:your_turn/src/pages/profile_page.dart';
import 'package:your_turn/src/providers/roommates_provider.dart';
import 'package:your_turn/src/providers/user_provider.dart';
import 'package:your_turn/src/utils/a11y_scroll_behavior.dart';
import 'package:your_turn/src/providers/locale_provider.dart';

// 👉 Aggiungi questo import
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  // Carica le variabili d’ambiente dal file .env
  await dotenv.load(fileName: ".env");

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final utente = ref.watch(userProvider);

    // Side-effect post-build
    if (utente != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(roommatesProvider.notifier).ensure(
              utente.id,
              name: utente.name,
              photoUrl: utente.photoUrl,
            );
      });
    }

    ref.listen<UserData?>(userProvider, (_, succ) {
      if (succ != null) {
        ref.read(roommatesProvider.notifier).ensure(
              succ.id,
              name: succ.name,
              photoUrl: succ.photoUrl,
            );
      }
    });

    const seed = Color(0xFF2563EB);

    final baseText = const TextTheme(
      displaySmall: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2),
      titleLarge: TextStyle(fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(height: 1.25),
    );

    ThemeData buildTheme(Brightness b) => ThemeData(
          useMaterial3: true,
          colorSchemeSeed: seed,
          brightness: b,
          visualDensity: VisualDensity.standard,
          textTheme: baseText,
          fontFamily: 'SafeFont',
          focusColor: Colors.transparent,
          splashFactory: InkSparkle.splashFactory,
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              minimumSize: const Size(240, 56),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            color: b == Brightness.dark
                ? Colors.white.withOpacity(0.06)
                : Colors.white.withOpacity(0.75),
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            border: OutlineInputBorder(borderSide: BorderSide.none),
          ),
        );

    final router = GoRouter(
      initialLocation: utente == null ? '/login' : '/todo',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/todo',
          builder: (context, state) => const TodoPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
      redirect: (context, state) {
        final loc = state.uri.toString();
        if (utente == null && loc != '/login') {
          return '/login';
        }
        if (utente != null && loc == '/login') {
          return '/todo';
        }
        return null;
      },
    );

    final currentLocale = ref.watch(localeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      themeMode: ThemeMode.light,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      highContrastTheme: buildTheme(Brightness.light),
      highContrastDarkTheme: buildTheme(Brightness.dark),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: currentLocale,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            disableAnimations:
                MediaQuery.maybeOf(context)?.disableAnimations ?? false,
            textScaler:
                media.textScaler.clamp(minScaleFactor: 1.0, maxScaleFactor: 2.0),
          ),
          child: ScrollConfiguration(
            behavior: const A11yScrollBehavior(),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      routerConfig: router,
    );
  }
}
