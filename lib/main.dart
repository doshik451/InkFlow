import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc/language/locale_cubit.dart';
import 'bloc/language/locale_state.dart';
import 'bloc/mode/app_mode_cubit.dart';
import 'bloc/theme/theme_cubit.dart';
import 'firebase_options.dart';
import 'generated/l10n.dart';
import 'modes/app_mode.dart';
import 'modes/theme/theme.dart';
import 'utils/routes.dart';
import 'utils/settings/settings_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final sharedPreferences = await SharedPreferences.getInstance();
  final settingsRepository = SettingsRepository(sharedPreferences: sharedPreferences);
  final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeCubit(settingsRepository: settingsRepository)),
        BlocProvider(create: (context) => LocaleCubit()..loadSavedLocale()),
        BlocProvider(create: (context) => AppModeCubit(settingsRepo: settingsRepository)),
      ],
      child: MyApp(
        isLoggedIn: isLoggedIn,
        settingsRepository: settingsRepository,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  final SettingsRepository settingsRepository;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    required this.settingsRepository,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    context.read<LocaleCubit>().loadSavedLocale();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<LocaleCubit, LocaleState>(
          builder: (context, localeState) {
            return BlocBuilder<AppModeCubit, AppMode>(
              builder: (context, appMode) {
                // Определяем начальный маршрут
                final initialRoute = widget.isLoggedIn
                    ? Routes.getMainRoute(context)
                    : Routes.login;

                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  locale: localeState.locale,
                  localizationsDelegates: [
                    S.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: S.delegate.supportedLocales,
                  theme: themeState.isDark ? darkThemeData : lightThemeData,
                  initialRoute: initialRoute, // Теперь точно String, не String?
                  onGenerateRoute: (settings) {
                    final routeName = settings.name ?? Routes.login; // Обработка null
                    final builder = Routes.getRouteBuilder(context, routeName);
                    if (builder != null) {
                      return MaterialPageRoute(
                        builder: builder,
                        settings: settings,
                      );
                    }
                    return MaterialPageRoute(
                      builder: (context) => const NotFoundScreen(),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("404 - Not Found")));
  }
}