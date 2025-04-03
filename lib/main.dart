import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc/language/locale_cubit.dart';
import 'bloc/language/locale_state.dart';
import 'bloc/theme/theme_cubit.dart';
import 'firebase_options.dart';
import 'generated/l10n.dart';
import 'ui/theme/theme.dart';
import 'utils/routes.dart';
import 'utils/settings/settings_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final sharedPreferences = await SharedPreferences.getInstance();
  final settingsRepository = SettingsRepository(sharedPreferences: sharedPreferences);
  final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeCubit(settingsRepository: settingsRepository)),
        BlocProvider(create: (context) => LocaleCubit()..loadSavedLocale()),
      ],
      child: MyApp(initialRoute: isLoggedIn ? Routes.main : Routes.login, preferences: prefs,),
    ),
  );
}

class MyApp extends StatefulWidget {
  final String initialRoute;
  final SharedPreferences preferences;

  const MyApp({super.key, required this.initialRoute, required this.preferences});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final SettingsRepository settingRepository;

  @override
  void initState() {
    super.initState();
    settingRepository = SettingsRepository(sharedPreferences: widget.preferences);
    context.read<LocaleCubit>().loadSavedLocale();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<LocaleCubit, LocaleState>(
          builder: (context, localeState) {
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
              initialRoute: widget.initialRoute,
              onGenerateRoute: (settings) {
                WidgetBuilder? builder = Routes.routes[settings.name];
                if (builder != null) {
                  return MaterialPageRoute(builder: builder, settings: settings);
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
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("404 - Not Found")));
  }
}