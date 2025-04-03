import 'package:flutter/material.dart';
import '../ui/widgets/main_screen/about_app_screen.dart';

import '../ui/widgets/auth_screen/forget_password_screen.dart';
import '../ui/widgets/auth_screen/login_screen.dart';
import '../ui/widgets/auth_screen/register_screen.dart';
import '../ui/widgets/main_screen/main_screen_base.dart';

class Routes {
  static const String login = '/login';
  static const String forgetPassword = '/login/forgetPassword';
  static const String register = '/register';
  static const String main = '/main';
  static const String aboutApp = '/aboutApp';

  static final Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    forgetPassword: (context) => const ForgetPasswordScreen(),
    register: (context) => const RegisterScreen(),
    main: (context) => const MainScreenBase(),
    aboutApp: (context) => const AboutAppScreen()
  };
}