import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:routefly/routefly.dart';
import 'package:fivethreeone_log/app/(public)/form_page.dart';
import 'package:fivethreeone_log/app/(public)/home_page.dart';
import 'package:fivethreeone_log/app/injector.dart';
import 'package:fivethreeone_log/app/interactor/providers/preferences_provider.dart';
import 'package:fivethreeone_log/routes.g.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  setupInjector();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(preferencesProvider.notifier).loadPreferences(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          final preferences = ref.watch(preferencesProvider);
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            darkTheme: ThemeData.dark(),
            routerConfig: Routefly.routerConfig(
              routes: routes,
              initialPath: preferences.rmData.isEmpty && preferences.percData.isEmpty && preferences.cycleWeekData.isEmpty ? '/form' : '/home',
            ),
            themeMode: ThemeMode.dark, // Apply dark theme
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('pt', 'BR'),
            ],
          );
        }
      },
    );
  }
}