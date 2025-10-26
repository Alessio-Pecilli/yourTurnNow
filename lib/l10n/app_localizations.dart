import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Roommates'**
  String get appTitle;

  /// No description provided for @nav_todo.
  ///
  /// In en, this message translates to:
  /// **'TO-DO'**
  String get nav_todo;

  /// No description provided for @nav_profile.
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get nav_profile;

  /// No description provided for @nav_admin.
  ///
  /// In en, this message translates to:
  /// **'ADMIN'**
  String get nav_admin;

  /// No description provided for @nav_download.
  ///
  /// In en, this message translates to:
  /// **'DOWNLOAD'**
  String get nav_download;

  /// No description provided for @nav_new.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get nav_new;

  /// No description provided for @todos_filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get todos_filter_all;

  /// No description provided for @todos_filter_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get todos_filter_done;

  /// No description provided for @todos_filter_open.
  ///
  /// In en, this message translates to:
  /// **'To do'**
  String get todos_filter_open;

  /// No description provided for @todos_order_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get todos_order_date;

  /// No description provided for @todos_order_cost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get todos_order_cost;

  /// No description provided for @todos_order_new.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get todos_order_new;

  /// No description provided for @categories_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categories_all;

  /// No description provided for @profile_you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get profile_you;

  /// No description provided for @table_title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get table_title;

  /// No description provided for @table_categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get table_categories;

  /// No description provided for @table_cost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get table_cost;

  /// No description provided for @table_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get table_date;

  /// No description provided for @table_creator.
  ///
  /// In en, this message translates to:
  /// **'Creator'**
  String get table_creator;

  /// No description provided for @table_assignees.
  ///
  /// In en, this message translates to:
  /// **'Assignees'**
  String get table_assignees;

  // Common
  String get common_cancel;
  String get common_save;
  String get common_add;
  String get common_delete;
  String get common_ok;
  String get common_csv;
  String get common_pdf;
  String get common_download;
  String get common_language;

  // Profile
  String get profile_login_required;
  String get pagination_prev;
  String get pagination_next;

  // ToDo dialog
  String get todo_dialog_new_task;
  String get todo_dialog_edit_task;
  String get todo_dialog_title_label;
  String get todo_dialog_title_required;
  String get todo_dialog_cost_label;
  String get todo_dialog_cost_required;
  String get todo_dialog_categories;
  String get todo_dialog_due_date;
  String get todo_dialog_optional;
  String get todo_dialog_notes_label;
  String get todo_dialog_notes_hint;
  String get todo_dialog_assign_to;
  String get todo_dialog_no_roommates;

  // Admin
  String get admin_add_category;
  String get admin_category_name;
  String get admin_add_roommate;
  String get admin_roommate_name;
  String get admin_edit_roommate;
  String get admin_stats_title;

  // Admin management sections
  String get admin_manage_categories;
  String get admin_no_categories;
  String get admin_add_category_btn;
  String get admin_manage_roommates;
  String get admin_no_roommates;
  String get admin_add_roommate_btn;

  // Transaction dialogs
  String get dialog_delete_transaction_title;
  String get dialog_delete_transaction_content;
  String get snackbar_transaction_deleted;
  String get dialog_edit_transaction_title;
  String get snackbar_transaction_updated;
  String get dialog_new_transaction_title;

  // Transactions fields
  String get tx_amount_label;
  String get tx_amount_hint;
  String get tx_amount_required;
  String get tx_amount_nonzero;
  String get tx_note_label;
  String get tx_note_hint;

  // Export and tables
  String get export_csv_desc;
  String get export_pdf_desc;
  String get table_category;
  String get table_amount_eur;
  String get table_roommate;
  String get table_tasks_completed;

  // Downloads
  String get download_charts_title;
  String get pdf_generated_success;
  String get export_choose_format;
  String get common_edit;
  String get common_actions;
  String get common_retry;
  String get common_reset;
  String get transactions_empty;
  String get transactions_add_first;
  String get todos_empty;
  String get todos_add_first;
  String get help_title;
  String get help_bullet_amount;
  String get help_bullet_filters;
  String get help_bullet_add;
  String get help_hide;
  String get weather_loading;
  String get weather_error;
  String get weather_loading_city;
  String get weather_humidity;
  String get weather_wind;
  String get me_balance_current;
  String get csv_generated;
  String get shortcuts_hint;
  String get charts_exported_file;

  // Admin page extras
  String get admin_chart_todo_done;
  String get admin_chart_todo_open;
  String get admin_chart_total_budget;
  String get no_data_available;
  String get total_label;
  String get select_icon;
  String get select_color;
  String get error_name_icon_required;
  String get error_operation_not_allowed;
  String get error_cannot_delete_logged_in;
  String get error_cannot_delete;
  String get error_category_in_use;
  String get error_roommate_in_use;
  String get confirm_delete_roommate;
  String get confirm_delete_title;
  String get confirm_delete_category;
  String get no_category;
  String get csv_section_expenses_by_category;
  String get csv_section_tasks_by_roommate;
  String get csv_section_status_todos;
  String get csv_status;
  String get csv_quantity;
  String get pdf_expenses_by_category_title;
  String get pdf_tasks_by_roommate_title;
  String get pdf_todo_status_title;
  String get pie_hint_category_for;
  String get pie_label_amount_of_total;
  String get csv_total;
  String get csv_generated_on;
  String get color_label;
  String get no_transactions_to_export;

  // Charts
  String get chart_expense_trend_title;
  String get chart_balance;

  String get profile_unknown;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'it': return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
