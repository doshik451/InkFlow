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

  /// `Appearance`
  String get appearance {
    return Intl.message('Appearance', name: 'appearance', desc: '', args: []);
  }

  /// `Clothing`
  String get clothing {
    return Intl.message('Clothing', name: 'clothing', desc: '', args: []);
  }

  /// `Moodboard`
  String get moodboard {
    return Intl.message('Moodboard', name: 'moodboard', desc: '', args: []);
  }

  /// `Wait for the images to finish uploading`
  String get waitForImageUpload {
    return Intl.message(
      'Wait for the images to finish uploading',
      name: 'waitForImageUpload',
      desc: '',
      args: [],
    );
  }

  /// `All references saved!`
  String get allReferencesSaved {
    return Intl.message(
      'All references saved!',
      name: 'allReferencesSaved',
      desc: '',
      args: [],
    );
  }

  /// `Caption saved`
  String get captionSaved {
    return Intl.message(
      'Caption saved',
      name: 'captionSaved',
      desc: '',
      args: [],
    );
  }

  /// `Tap to open link`
  String get tapToOpenLink {
    return Intl.message(
      'Tap to open link',
      name: 'tapToOpenLink',
      desc: '',
      args: [],
    );
  }

  /// `Image link`
  String get imageLink {
    return Intl.message('Image link', name: 'imageLink', desc: '', args: []);
  }

  /// `Please enter a valid URL`
  String get enterValidUrl {
    return Intl.message(
      'Please enter a valid URL',
      name: 'enterValidUrl',
      desc: '',
      args: [],
    );
  }

  /// `Link caption (optional)`
  String get linkCaptionOptional {
    return Intl.message(
      'Link caption (optional)',
      name: 'linkCaptionOptional',
      desc: '',
      args: [],
    );
  }

  /// `Add link`
  String get addLink {
    return Intl.message('Add link', name: 'addLink', desc: '', args: []);
  }

  /// `Character Relationships`
  String get characterRelationshipsTitle {
    return Intl.message(
      'Character Relationships',
      name: 'characterRelationshipsTitle',
      desc: '',
      args: [],
    );
  }

  /// `General Information`
  String get generalInformationTitle {
    return Intl.message(
      'General Information',
      name: 'generalInformationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Attitude to Society`
  String get attitudeToSocietyLabel {
    return Intl.message(
      'Attitude to Society',
      name: 'attitudeToSocietyLabel',
      desc: '',
      args: [],
    );
  }

  /// `Attachments`
  String get attachmentsLabel {
    return Intl.message(
      'Attachments',
      name: 'attachmentsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get saveButton {
    return Intl.message('Save', name: 'saveButton', desc: '', args: []);
  }

  /// `Family/Origin`
  String get familyRelationsTitle {
    return Intl.message(
      'Family/Origin',
      name: 'familyRelationsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Friends/Allies`
  String get friendsRelationsTitle {
    return Intl.message(
      'Friends/Allies',
      name: 'friendsRelationsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enemies/Competitors`
  String get enemiesRelationsTitle {
    return Intl.message(
      'Enemies/Competitors',
      name: 'enemiesRelationsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Other Relationships`
  String get otherRelationsTitle {
    return Intl.message(
      'Other Relationships',
      name: 'otherRelationsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Select a Character`
  String get selectCharacterLabel {
    return Intl.message(
      'Select a Character',
      name: 'selectCharacterLabel',
      desc: '',
      args: [],
    );
  }

  /// `First to Second Relation`
  String get firstToSecondRelationLabel {
    return Intl.message(
      'First to Second Relation',
      name: 'firstToSecondRelationLabel',
      desc: '',
      args: [],
    );
  }

  /// `Second to First Relation`
  String get secondToFirstRelationLabel {
    return Intl.message(
      'Second to First Relation',
      name: 'secondToFirstRelationLabel',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancelButton {
    return Intl.message('Cancel', name: 'cancelButton', desc: '', args: []);
  }

  /// `Add`
  String get addButton {
    return Intl.message('Add', name: 'addButton', desc: '', args: []);
  }

  /// `Current Relationships:`
  String get currentRelationsLabel {
    return Intl.message(
      'Current Relationships:',
      name: 'currentRelationsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Biography`
  String get biographyTitle {
    return Intl.message(
      'Biography',
      name: 'biographyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Past Events`
  String get pastEventsLabel {
    return Intl.message(
      'Past Events',
      name: 'pastEventsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Secrets`
  String get secretsLabel {
    return Intl.message('Secrets', name: 'secretsLabel', desc: '', args: []);
  }

  /// `Character Development`
  String get characterDevelopmentLabel {
    return Intl.message(
      'Character Development',
      name: 'characterDevelopmentLabel',
      desc: '',
      args: [],
    );
  }

  /// `Losses and Gains`
  String get lossesAndGainsLabel {
    return Intl.message(
      'Losses and Gains',
      name: 'lossesAndGainsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Inner Conflicts`
  String get innerConflictsLabel {
    return Intl.message(
      'Inner Conflicts',
      name: 'innerConflictsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Worst Memory`
  String get worstMemoryLabel {
    return Intl.message(
      'Worst Memory',
      name: 'worstMemoryLabel',
      desc: '',
      args: [],
    );
  }

  /// `Happiest Memory`
  String get happiestMemoryLabel {
    return Intl.message(
      'Happiest Memory',
      name: 'happiestMemoryLabel',
      desc: '',
      args: [],
    );
  }

  /// `Turning Point`
  String get turningPointLabel {
    return Intl.message(
      'Turning Point',
      name: 'turningPointLabel',
      desc: '',
      args: [],
    );
  }

  /// `Hidden Aspects`
  String get hiddenAspectsLabel {
    return Intl.message(
      'Hidden Aspects',
      name: 'hiddenAspectsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Save Biography`
  String get saveBiographyButton {
    return Intl.message(
      'Save Biography',
      name: 'saveBiographyButton',
      desc: '',
      args: [],
    );
  }

  /// `Additional Info`
  String get additionalInfoTitle {
    return Intl.message(
      'Additional Info',
      name: 'additionalInfoTitle',
      desc: '',
      args: [],
    );
  }

  /// `Quote`
  String get quoteLabel {
    return Intl.message('Quote', name: 'quoteLabel', desc: '', args: []);
  }

  /// `First Impression`
  String get firstImpressionLabel {
    return Intl.message(
      'First Impression',
      name: 'firstImpressionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Talents (comma separated)`
  String get talentsLabel {
    return Intl.message(
      'Talents (comma separated)',
      name: 'talentsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Artifacts (comma separated)`
  String get artifactsLabel {
    return Intl.message(
      'Artifacts (comma separated)',
      name: 'artifactsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Character Profile`
  String get characterProfileTitle {
    return Intl.message(
      'Character Profile',
      name: 'characterProfileTitle',
      desc: '',
      args: [],
    );
  }

  /// `Personality`
  String get personalityLabel {
    return Intl.message(
      'Personality',
      name: 'personalityLabel',
      desc: '',
      args: [],
    );
  }

  /// `Social Status`
  String get socialStatusLabel {
    return Intl.message(
      'Social Status',
      name: 'socialStatusLabel',
      desc: '',
      args: [],
    );
  }

  /// `Habits`
  String get habitsLabel {
    return Intl.message('Habits', name: 'habitsLabel', desc: '', args: []);
  }

  /// `Strengths`
  String get strengthsLabel {
    return Intl.message(
      'Strengths',
      name: 'strengthsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Weaknesses`
  String get weaknessesLabel {
    return Intl.message(
      'Weaknesses',
      name: 'weaknessesLabel',
      desc: '',
      args: [],
    );
  }

  /// `Beliefs`
  String get beliefsLabel {
    return Intl.message('Beliefs', name: 'beliefsLabel', desc: '', args: []);
  }

  /// `Goal`
  String get goalLabel {
    return Intl.message('Goal', name: 'goalLabel', desc: '', args: []);
  }

  /// `Motivation`
  String get motivationLabel {
    return Intl.message(
      'Motivation',
      name: 'motivationLabel',
      desc: '',
      args: [],
    );
  }

  /// `Admires`
  String get admiresLabel {
    return Intl.message('Admires', name: 'admiresLabel', desc: '', args: []);
  }

  /// `Irritates or Fears`
  String get irritatesOrFearsLabel {
    return Intl.message(
      'Irritates or Fears',
      name: 'irritatesOrFearsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Inspires`
  String get inspiresLabel {
    return Intl.message('Inspires', name: 'inspiresLabel', desc: '', args: []);
  }

  /// `Temperament`
  String get temperamentLabel {
    return Intl.message(
      'Temperament',
      name: 'temperamentLabel',
      desc: '',
      args: [],
    );
  }

  /// `Stress Behavior`
  String get stressBehaviorLabel {
    return Intl.message(
      'Stress Behavior',
      name: 'stressBehaviorLabel',
      desc: '',
      args: [],
    );
  }

  /// `Attitude to Life`
  String get attitudeToLifeLabel {
    return Intl.message(
      'Attitude to Life',
      name: 'attitudeToLifeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Inner Contradictions`
  String get innerContradictionsLabel {
    return Intl.message(
      'Inner Contradictions',
      name: 'innerContradictionsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Plan`
  String get plan {
    return Intl.message('Plan', name: 'plan', desc: '', args: []);
  }

  /// `No reads in plan`
  String get no_books_in_plan {
    return Intl.message(
      'No reads in plan',
      name: 'no_books_in_plan',
      desc: '',
      args: [],
    );
  }

  /// `High`
  String get high {
    return Intl.message('High', name: 'high', desc: '', args: []);
  }

  /// `Medium`
  String get medium {
    return Intl.message('Medium', name: 'medium', desc: '', args: []);
  }

  /// `Low`
  String get low {
    return Intl.message('Low', name: 'low', desc: '', args: []);
  }

  /// `Not defined`
  String get notDefined {
    return Intl.message('Not defined', name: 'notDefined', desc: '', args: []);
  }

  /// `Work name`
  String get workName {
    return Intl.message('Work name', name: 'workName', desc: '', args: []);
  }

  /// `Genre/tags`
  String get genreNTags {
    return Intl.message('Genre/tags', name: 'genreNTags', desc: '', args: []);
  }

  /// `Priority`
  String get priority {
    return Intl.message('Priority', name: 'priority', desc: '', args: []);
  }

  /// `Links`
  String get links {
    return Intl.message('Links', name: 'links', desc: '', args: []);
  }

  /// `Add link`
  String get add_link {
    return Intl.message('Add link', name: 'add_link', desc: '', args: []);
  }

  /// `Plot`
  String get criterion_plot {
    return Intl.message('Plot', name: 'criterion_plot', desc: '', args: []);
  }

  /// `Characters`
  String get criterion_characters {
    return Intl.message(
      'Characters',
      name: 'criterion_characters',
      desc: '',
      args: [],
    );
  }

  /// `Worldbuilding`
  String get criterion_worldbuilding {
    return Intl.message(
      'Worldbuilding',
      name: 'criterion_worldbuilding',
      desc: '',
      args: [],
    );
  }

  /// `Emotional impact`
  String get criterion_emotion {
    return Intl.message(
      'Emotional impact',
      name: 'criterion_emotion',
      desc: '',
      args: [],
    );
  }

  /// `Writing Style`
  String get criterion_writingStyle {
    return Intl.message(
      'Writing Style',
      name: 'criterion_writingStyle',
      desc: '',
      args: [],
    );
  }

  /// `Read`
  String get category_read {
    return Intl.message('Read', name: 'category_read', desc: '', args: []);
  }

  /// `Favorite`
  String get category_favorite {
    return Intl.message(
      'Favorite',
      name: 'category_favorite',
      desc: '',
      args: [],
    );
  }

  /// `Abandoned`
  String get category_abandoned {
    return Intl.message(
      'Abandoned',
      name: 'category_abandoned',
      desc: '',
      args: [],
    );
  }

  /// `Want to reread`
  String get category_reRead {
    return Intl.message(
      'Want to reread',
      name: 'category_reRead',
      desc: '',
      args: [],
    );
  }

  /// `Disliked`
  String get category_disliked {
    return Intl.message(
      'Disliked',
      name: 'category_disliked',
      desc: '',
      args: [],
    );
  }

  /// `In process`
  String get category_in_process {
    return Intl.message(
      'In process',
      name: 'category_in_process',
      desc: '',
      args: [],
    );
  }

  /// `Categories`
  String get categories {
    return Intl.message('Categories', name: 'categories', desc: '', args: []);
  }

  /// `No categories:(`
  String get no_categories {
    return Intl.message(
      'No categories:(',
      name: 'no_categories',
      desc: '',
      args: [],
    );
  }

  /// `Select color`
  String get selectColor {
    return Intl.message(
      'Select color',
      name: 'selectColor',
      desc: '',
      args: [],
    );
  }

  /// `Color`
  String get color {
    return Intl.message('Color', name: 'color', desc: '', args: []);
  }

  /// `OK`
  String get ok {
    return Intl.message('OK', name: 'ok', desc: '', args: []);
  }

  /// `Collection`
  String get collection {
    return Intl.message('Collection', name: 'collection', desc: '', args: []);
  }

  /// `404 - Not Found`
  String get notFoundPageText {
    return Intl.message(
      '404 - Not Found',
      name: 'notFoundPageText',
      desc: '',
      args: [],
    );
  }

  /// `Reading dates`
  String get reading_dates {
    return Intl.message(
      'Reading dates',
      name: 'reading_dates',
      desc: '',
      args: [],
    );
  }

  /// `First select the start date`
  String get select_start_date {
    return Intl.message(
      'First select the start date',
      name: 'select_start_date',
      desc: '',
      args: [],
    );
  }

  /// `General impression`
  String get general_impression {
    return Intl.message(
      'General impression',
      name: 'general_impression',
      desc: '',
      args: [],
    );
  }

  /// `Review and criteria`
  String get review_and_criteria {
    return Intl.message(
      'Review and criteria',
      name: 'review_and_criteria',
      desc: '',
      args: [],
    );
  }

  /// `Moments`
  String get moments {
    return Intl.message('Moments', name: 'moments', desc: '', args: []);
  }

  /// `Review`
  String get review {
    return Intl.message('Review', name: 'review', desc: '', args: []);
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
