// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `InkFlow`
  String get app_name {
    return Intl.message('InkFlow', name: 'app_name', desc: '', args: []);
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Enter the correct email`
  String get enter_correct_email {
    return Intl.message(
      'Enter the correct email',
      name: 'enter_correct_email',
      desc: '',
      args: [],
    );
  }

  /// `Forget password?`
  String get forget_password {
    return Intl.message(
      'Forget password?',
      name: 'forget_password',
      desc: '',
      args: [],
    );
  }

  /// `Registration`
  String get registration {
    return Intl.message(
      'Registration',
      name: 'registration',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get username {
    return Intl.message('Username', name: 'username', desc: '', args: []);
  }

  /// `Passwords don't match`
  String get passwords_do_not_match {
    return Intl.message(
      'Passwords don\'t match',
      name: 'passwords_do_not_match',
      desc: '',
      args: [],
    );
  }

  /// `Confirm password`
  String get confirm_password {
    return Intl.message(
      'Confirm password',
      name: 'confirm_password',
      desc: '',
      args: [],
    );
  }

  /// `Reset password`
  String get reset_password {
    return Intl.message(
      'Reset password',
      name: 'reset_password',
      desc: '',
      args: [],
    );
  }

  /// `Send reset letter`
  String get send_email_to_reset {
    return Intl.message(
      'Send reset letter',
      name: 'send_email_to_reset',
      desc: '',
      args: [],
    );
  }

  /// `Books`
  String get books {
    return Intl.message('Books', name: 'books', desc: '', args: []);
  }

  /// `Ideas`
  String get ideas {
    return Intl.message('Ideas', name: 'ideas', desc: '', args: []);
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `Registration failed`
  String get registration_failed {
    return Intl.message(
      'Registration failed',
      name: 'registration_failed',
      desc: '',
      args: [],
    );
  }

  /// `Must be 8 or more characters, plus letters and numbers`
  String get password_invalid {
    return Intl.message(
      'Must be 8 or more characters, plus letters and numbers',
      name: 'password_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Login failed`
  String get login_failed {
    return Intl.message(
      'Login failed',
      name: 'login_failed',
      desc: '',
      args: [],
    );
  }

  /// `Password reset email sent`
  String get password_reset_email_sent {
    return Intl.message(
      'Password reset email sent',
      name: 'password_reset_email_sent',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred`
  String get an_error_occurred {
    return Intl.message(
      'An error occurred',
      name: 'an_error_occurred',
      desc: '',
      args: [],
    );
  }

  /// `Unknown`
  String get unknown {
    return Intl.message('Unknown', name: 'unknown', desc: '', args: []);
  }

  /// `We don't have access`
  String get don_t_have_access {
    return Intl.message(
      'We don\'t have access',
      name: 'don_t_have_access',
      desc: '',
      args: [],
    );
  }

  /// `Dark theme`
  String get dark_theme {
    return Intl.message('Dark theme', name: 'dark_theme', desc: '', args: []);
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }

  /// `Change language`
  String get change_lang {
    return Intl.message(
      'Change language',
      name: 'change_lang',
      desc: '',
      args: [],
    );
  }

  /// `About app`
  String get about_app {
    return Intl.message('About app', name: 'about_app', desc: '', args: []);
  }

  /// `Change mode`
  String get change_mode {
    return Intl.message('Change mode', name: 'change_mode', desc: '', args: []);
  }

  /// `A Program for Writers and Readers`
  String get about_app_subtitle {
    return Intl.message(
      'A Program for Writers and Readers',
      name: 'about_app_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Writer Mode`
  String get writer_mode_title {
    return Intl.message(
      'Writer Mode',
      name: 'writer_mode_title',
      desc: '',
      args: [],
    );
  }

  /// `Here, you can organize your creative ideas, develop plots, and flesh out characters. You can:\n- Jot down ideas for future works.\n- Keep detailed notes for each book.\n- Store information about your projects.`
  String get writer_mode_description {
    return Intl.message(
      'Here, you can organize your creative ideas, develop plots, and flesh out characters. You can:\n- Jot down ideas for future works.\n- Keep detailed notes for each book.\n- Store information about your projects.',
      name: 'writer_mode_description',
      desc: '',
      args: [],
    );
  }

  /// `Reader Mode`
  String get reader_mode_title {
    return Intl.message(
      'Reader Mode',
      name: 'reader_mode_title',
      desc: '',
      args: [],
    );
  }

  /// `This mode helps you manage your reading experience. You can:\n- Save quotes from books you’ve read.\n- Rate books based on different criteria.\n- Maintain a to-read list.`
  String get reader_mode_description {
    return Intl.message(
      'This mode helps you manage your reading experience. You can:\n- Save quotes from books you’ve read.\n- Rate books based on different criteria.\n- Maintain a to-read list.',
      name: 'reader_mode_description',
      desc: '',
      args: [],
    );
  }

  /// `InkFlow is your digital companion in the world of literature.`
  String get about_app_conclusion {
    return Intl.message(
      'InkFlow is your digital companion in the world of literature.',
      name: 'about_app_conclusion',
      desc: '',
      args: [],
    );
  }

  /// `Support the project`
  String get support_the_project {
    return Intl.message(
      'Support the project',
      name: 'support_the_project',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ru'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
