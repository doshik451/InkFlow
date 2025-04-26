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

  /// `No ideas:(`
  String get no_ideas {
    return Intl.message('No ideas:(', name: 'no_ideas', desc: '', args: []);
  }

  /// `No books:(`
  String get no_books {
    return Intl.message('No books:(', name: 'no_books', desc: '', args: []);
  }

  /// `No notes:(`
  String get no_notes {
    return Intl.message('No notes:(', name: 'no_notes', desc: '', args: []);
  }

  /// `No story arcs:(`
  String get no_story_arc {
    return Intl.message(
      'No story arcs:(',
      name: 'no_story_arc',
      desc: '',
      args: [],
    );
  }

  /// `No environment items:(`
  String get no_environment_items {
    return Intl.message(
      'No environment items:(',
      name: 'no_environment_items',
      desc: '',
      args: [],
    );
  }

  /// `No chapters:(`
  String get no_chapters {
    return Intl.message(
      'No chapters:(',
      name: 'no_chapters',
      desc: '',
      args: [],
    );
  }

  /// `No characters:(`
  String get no_characters {
    return Intl.message(
      'No characters:(',
      name: 'no_characters',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get done {
    return Intl.message('Done', name: 'done', desc: '', args: []);
  }

  /// `In mind`
  String get inMind {
    return Intl.message('In mind', name: 'inMind', desc: '', args: []);
  }

  /// `In progress`
  String get inProgress {
    return Intl.message('In progress', name: 'inProgress', desc: '', args: []);
  }

  /// `Canceled`
  String get canceled {
    return Intl.message('Canceled', name: 'canceled', desc: '', args: []);
  }

  /// `Frozen`
  String get frozen {
    return Intl.message('Frozen', name: 'frozen', desc: '', args: []);
  }

  /// `Draft`
  String get draft {
    return Intl.message('Draft', name: 'draft', desc: '', args: []);
  }

  /// `Loading...`
  String get loading {
    return Intl.message('Loading...', name: 'loading', desc: '', args: []);
  }

  /// `Related to: `
  String get relatedTo {
    return Intl.message('Related to: ', name: 'relatedTo', desc: '', args: []);
  }

  /// `General`
  String get general {
    return Intl.message('General', name: 'general', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Record is deleted`
  String get record_is_deleted {
    return Intl.message(
      'Record is deleted',
      name: 'record_is_deleted',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure?`
  String get are_you_sure {
    return Intl.message(
      'Are you sure?',
      name: 'are_you_sure',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Creating`
  String get creating {
    return Intl.message('Creating', name: 'creating', desc: '', args: []);
  }

  /// `Required field is empty`
  String get requiredField {
    return Intl.message(
      'Required field is empty',
      name: 'requiredField',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get title {
    return Intl.message('Title', name: 'title', desc: '', args: []);
  }

  /// `Description`
  String get description {
    return Intl.message('Description', name: 'description', desc: '', args: []);
  }

  /// `Author`
  String get author {
    return Intl.message('Author', name: 'author', desc: '', args: []);
  }

  /// `Theme`
  String get theme {
    return Intl.message('Theme', name: 'theme', desc: '', args: []);
  }

  /// `Message`
  String get message {
    return Intl.message('Message', name: 'message', desc: '', args: []);
  }

  /// `Setting`
  String get setting {
    return Intl.message('Setting', name: 'setting', desc: '', args: []);
  }

  /// `Genre`
  String get genre {
    return Intl.message('Genre', name: 'genre', desc: '', args: []);
  }

  /// `Status`
  String get status {
    return Intl.message('Status', name: 'status', desc: '', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Editing`
  String get editing {
    return Intl.message('Editing', name: 'editing', desc: '', args: []);
  }

  /// `Last update: `
  String get lastUpdate {
    return Intl.message(
      'Last update: ',
      name: 'lastUpdate',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message('No', name: 'no', desc: '', args: []);
  }

  /// `Unsaved data`
  String get unsaved_data {
    return Intl.message(
      'Unsaved data',
      name: 'unsaved_data',
      desc: '',
      args: [],
    );
  }

  /// `You have unsaved data. Save?`
  String get want_to_save {
    return Intl.message(
      'You have unsaved data. Save?',
      name: 'want_to_save',
      desc: '',
      args: [],
    );
  }

  /// `Choose mode`
  String get choose_mode {
    return Intl.message('Choose mode', name: 'choose_mode', desc: '', args: []);
  }

  /// `You are in writer mode`
  String get mode_changed_to_writer {
    return Intl.message(
      'You are in writer mode',
      name: 'mode_changed_to_writer',
      desc: '',
      args: [],
    );
  }

  /// `You are in reader mode`
  String get mode_changed_to_reader {
    return Intl.message(
      'You are in reader mode',
      name: 'mode_changed_to_reader',
      desc: '',
      args: [],
    );
  }

  /// `About book`
  String get aboutBook {
    return Intl.message('About book', name: 'aboutBook', desc: '', args: []);
  }

  /// `Plot`
  String get plot {
    return Intl.message('Plot', name: 'plot', desc: '', args: []);
  }

  /// `Characters`
  String get characters {
    return Intl.message('Characters', name: 'characters', desc: '', args: []);
  }

  /// `Environment`
  String get environment {
    return Intl.message('Environment', name: 'environment', desc: '', args: []);
  }

  /// `Notes`
  String get notes {
    return Intl.message('Notes', name: 'notes', desc: '', args: []);
  }

  /// `Data successfully updated`
  String get update_success {
    return Intl.message(
      'Data successfully updated',
      name: 'update_success',
      desc: '',
      args: [],
    );
  }

  /// `Record successfully created`
  String get create_success {
    return Intl.message(
      'Record successfully created',
      name: 'create_success',
      desc: '',
      args: [],
    );
  }

  /// `Add image`
  String get add_image {
    return Intl.message('Add image', name: 'add_image', desc: '', args: []);
  }

  /// `Features`
  String get features {
    return Intl.message('Features', name: 'features', desc: '', args: []);
  }

  /// `Arc's chapters`
  String get arcs_chapters {
    return Intl.message(
      'Arc\'s chapters',
      name: 'arcs_chapters',
      desc: '',
      args: [],
    );
  }

  /// `Add chapter`
  String get add_chapter {
    return Intl.message('Add chapter', name: 'add_chapter', desc: '', args: []);
  }

  /// `Add key moment`
  String get add_key_moment {
    return Intl.message(
      'Add key moment',
      name: 'add_key_moment',
      desc: '',
      args: [],
    );
  }

  /// `Key moments`
  String get key_moments {
    return Intl.message('Key moments', name: 'key_moments', desc: '', args: []);
  }

  /// `Add file (pdf, doc, docx, txt, epub, fb2)`
  String get add_book_file {
    return Intl.message(
      'Add file (pdf, doc, docx, txt, epub, fb2)',
      name: 'add_book_file',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Permission required`
  String get permissionRequiredTitle {
    return Intl.message(
      'Permission required',
      name: 'permissionRequiredTitle',
      desc: '',
      args: [],
    );
  }

  /// `To save files, storage access permission is required`
  String get storagePermissionMessage {
    return Intl.message(
      'To save files, storage access permission is required',
      name: 'storagePermissionMessage',
      desc: '',
      args: [],
    );
  }

  /// `File saved`
  String get file_saved {
    return Intl.message('File saved', name: 'file_saved', desc: '', args: []);
  }

  /// `Invalid file format`
  String get invalid_file_format {
    return Intl.message(
      'Invalid file format',
      name: 'invalid_file_format',
      desc: '',
      args: [],
    );
  }

  /// `Downloads folder not found`
  String get folder_not_found {
    return Intl.message(
      'Downloads folder not found',
      name: 'folder_not_found',
      desc: '',
      args: [],
    );
  }

  /// `The file wasn't saved`
  String get file_was_not_saved {
    return Intl.message(
      'The file wasn\'t saved',
      name: 'file_was_not_saved',
      desc: '',
      args: [],
    );
  }

  /// `Allies`
  String get allies {
    return Intl.message('Allies', name: 'allies', desc: '', args: []);
  }

  /// `Friends`
  String get friends {
    return Intl.message('Friends', name: 'friends', desc: '', args: []);
  }

  /// `Neutral`
  String get neutral {
    return Intl.message('Neutral', name: 'neutral', desc: '', args: []);
  }

  /// `Rivals`
  String get rivals {
    return Intl.message('Rivals', name: 'rivals', desc: '', args: []);
  }

  /// `Enemies`
  String get enemies {
    return Intl.message('Enemies', name: 'enemies', desc: '', args: []);
  }

  /// `Other`
  String get other {
    return Intl.message('Other', name: 'other', desc: '', args: []);
  }

  /// `Name`
  String get name {
    return Intl.message('Name', name: 'name', desc: '', args: []);
  }

  /// `Age`
  String get age {
    return Intl.message('Age', name: 'age', desc: '', args: []);
  }

  /// `Role`
  String get role {
    return Intl.message('Role', name: 'role', desc: '', args: []);
  }

  /// `Race`
  String get race {
    return Intl.message('Race', name: 'race', desc: '', args: []);
  }

  /// `Occupation`
  String get occupation {
    return Intl.message('Occupation', name: 'occupation', desc: '', args: []);
  }

  /// `Appearance description`
  String get appearanceDescription {
    return Intl.message(
      'Appearance description',
      name: 'appearanceDescription',
      desc: '',
      args: [],
    );
  }

  /// `After adding a character you will be able to add a picture`
  String get add_image_after_character {
    return Intl.message(
      'After adding a character you will be able to add a picture',
      name: 'add_image_after_character',
      desc: '',
      args: [],
    );
  }

  /// `Questionnaire`
  String get questionnaire {
    return Intl.message(
      'Questionnaire',
      name: 'questionnaire',
      desc: '',
      args: [],
    );
  }

  /// `References`
  String get references {
    return Intl.message('References', name: 'references', desc: '', args: []);
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
