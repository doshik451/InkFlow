import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inkflow/modes/reader/main_screen/main_screen_base.dart';
import 'package:inkflow/ui/widgets/auth_screen/choose_mode.dart';

import '../bloc/mode/app_mode_cubit.dart';
import '../modes/app_mode.dart';
import '../modes/writer/idea/ideas_list_screen.dart';
import '../modes/general/about_app_screen.dart';
import '../modes/writer/main_screen/main_screen_base.dart';
import '../modes/general/profile_screen.dart';
import '../ui/widgets/auth_screen/forget_password_screen.dart';
import '../ui/widgets/auth_screen/login_screen.dart';
import '../ui/widgets/auth_screen/register_screen.dart';

class Routes {
  static const String login = '/login';
  static const String forgetPassword = '/login/forgetPassword';
  static const String register = '/register';
  static const String aboutApp = '/aboutApp';
  static const String profile = '/profile';
  static const String modeSelection = '/modeSelection';

  static const String mainScreenWriter = '/mainScreenWriter';
  static const String ideasList = '/idea';

  static const String mainScreenReader = '/mainScreenReader';

  static String getMainRoute(BuildContext context) {
    try {
      final mode = context.read<AppModeCubit>().state;
      return mode == AppMode.writerMode ? mainScreenWriter : mainScreenReader;
    } catch (e) {
      return mainScreenWriter; // fallback
    }
  }

  static final Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    forgetPassword: (context) => const ForgetPasswordScreen(),
    register: (context) => const RegisterScreen(),
    aboutApp: (context) => const AboutAppScreen(),
    profile: (context) => const ProfileScreen(),
    modeSelection: (context) => const ChooseMode(),

    mainScreenWriter: (context) => const MainScreenBaseWriter(),
    ideasList: (context) => const IdeasListScreen(),

    mainScreenReader: (context) => const MainScreenBaseReader(),
  };

  static WidgetBuilder? getRouteBuilder(BuildContext context, String routeName) {
    if ([login, forgetPassword, register, aboutApp, profile, ideasList, modeSelection].contains(routeName)) {
      return routes[routeName];
    }

    if (routeName == mainScreenWriter || routeName == mainScreenReader) {
      final mainRoute = getMainRoute(context);
      return routes[mainRoute];
    }

    return null;
  }
}