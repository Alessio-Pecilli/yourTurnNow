// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Roommates';

  @override
  String get nav_todo => 'TO-DO';

  @override
  String get nav_profile => 'PROFILE';

  @override
  String get nav_admin => 'ADMIN';

  @override
  String get nav_download => 'DOWNLOAD';

  @override
  String get nav_new => 'NEW';

  @override
  String get todos_filter_all => 'All';

  @override
  String get todos_filter_done => 'Done';

  @override
  String get todos_filter_open => 'To do';

  @override
  String get todos_order_date => 'Date';

  @override
  String get todos_order_cost => 'Cost';

  @override
  String get todos_order_new => 'New';

  @override
  String get categories_all => 'All';

  @override
  String get profile_you => 'You';

  @override
  String get table_title => 'Title';

  @override
  String get table_categories => 'Categories';

  @override
  String get table_cost => 'Cost';

  @override
  String get table_date => 'Date';

  @override
  String get table_creator => 'Creator';

  @override
  String get table_assignees => 'Assignees';

  // Common
  @override
  String get common_cancel => 'Cancel';
  @override
  String get common_save => 'Save';
  @override
  String get common_add => 'Add';
  @override
  String get common_delete => 'Delete';
  @override
  String get common_ok => 'OK';
  @override
  String get common_csv => 'CSV';
  @override
  String get common_pdf => 'PDF';
  @override
  String get common_download => 'Download';
  @override
  String get common_language => 'Language';

  // Profile
  @override
  String get profile_login_required => 'Log in to view the profile.';
  @override
  String get pagination_prev => 'Previous page';
  @override
  String get pagination_next => 'Next page';

  // ToDo dialog
  @override
  String get todo_dialog_new_task => 'New Task';
  @override
  String get todo_dialog_edit_task => 'Edit Task';
  @override
  String get todo_dialog_title_label => 'Title *';
  @override
  String get todo_dialog_title_required => 'Title is required';
  @override
  String get todo_dialog_cost_label => 'Cost (€) *';
  @override
  String get todo_dialog_cost_required => 'Cost is required';
  @override
  String get todo_dialog_categories => 'Categories';
  @override
  String get todo_dialog_due_date => 'Due date';
  @override
  String get todo_dialog_optional => 'Optional';
  @override
  String get todo_dialog_notes_label => 'Notes (optional)';
  @override
  String get todo_dialog_notes_hint => 'Details...';
  @override
  String get todo_dialog_assign_to => 'Assign to';
  @override
  String get todo_dialog_no_roommates => 'No roommates available. Please login.';

  // Admin
  @override
  String get admin_add_category => 'Add new category';
  @override
  String get admin_category_name => 'Category name';
  @override
  String get admin_add_roommate => 'Add Roommate';
  @override
  String get admin_roommate_name => 'Roommate name';
  @override
  String get admin_edit_roommate => 'Edit Roommate';
  @override
  String get admin_stats_title => 'Admin Statistics';

  // Export and tables
  @override
  String get export_csv_desc => 'Export tables to CSV.';
  @override
  String get export_pdf_desc => 'Export tables to PDF.';
  @override
  String get table_category => 'Category';
  @override
  String get table_amount_eur => 'Amount (EUR)';
  @override
  String get table_roommate => 'Roommate';
  @override
  String get table_tasks_completed => 'Tasks completed';

  // Downloads
  @override
  String get download_charts_title => 'Download chart data';
  @override
  String get pdf_generated_success => 'Charts PDF generated successfully';
  @override
  String get export_choose_format => 'Choose export format';
  @override
  String get common_edit => 'Edit';
  @override
  String get common_actions => 'Actions';
  @override
  String get common_retry => 'Retry';
  @override
  String get common_reset => 'Reset';
  @override
  String get transactions_empty => 'No transactions';
  @override
  String get transactions_add_first => 'Add the first transaction to get started.';
  @override
  String get todos_empty => 'No tasks';
  @override
  String get todos_add_first => 'Add the first task to organize your home.';
  @override
  String get help_title => 'How it works';
  @override
  String get help_bullet_amount => '• Amount: positive = credit, negative = debit.';
  @override
  String get help_bullet_filters => '• Filters: choose a category and/or a date range.';
  @override
  String get help_bullet_add => '• Add: use the Add button to insert a new item.';
  @override
  String get help_hide => 'Hide help';
  @override
  String get weather_loading => 'Loading...';
  @override
  String get weather_error => 'Weather error';
  @override
  String get weather_loading_city => 'Loading weather for {city}...';
  @override
  String get weather_humidity => 'Humidity: {value}%';
  @override
  String get weather_wind => 'Wind: {value} m/s';
  @override
  String get me_balance_current => 'Current balance';
  @override
  String get csv_generated => 'CSV generated';
  @override
  String get shortcuts_hint => 'Shortcuts: H = Home • S = Download • A = Add Transaction';
  @override
  String get charts_exported_file => 'Chart data exported: {filename}';
  @override
  String get error_cannot_delete => 'Cannot delete';
  @override
  String get error_category_in_use => 'The category "{name}" is still in use in some to-dos. Remove it first.';
  @override
  String get confirm_delete_title => 'Confirm deletion';
  @override
  String get confirm_delete_category => 'Are you sure you want to delete the category "{name}"?';
  @override
  String get csv_section_status_todos => '=== STATUS TODOS ===';
  @override
  String get csv_status => 'Status';
  @override
  String get csv_quantity => 'Quantity';
  @override
  String get csv_total => 'TOTAL';
  @override
  String get csv_generated_on => 'Generated on: {timestamp}';
  @override
  String get pdf_todo_status_title => 'To-Do status';
  @override
  String get admin_chart_todo_done => 'Completed Todos';
  @override
  String get admin_chart_todo_open => 'Open Todos';
  @override
  String get admin_chart_total_budget => 'Total Budget';
  @override
  String get no_data_available => 'No data available';
  @override
  String get total_label => 'Total';
  @override
  String get select_icon => 'Select icon';
  @override
  String get select_color => 'Select color';
  @override
  String get error_name_icon_required => 'Enter a name and choose an icon before adding the category.';
  @override
  String get error_operation_not_allowed => 'Operation not allowed';
  @override
  String get error_cannot_delete_logged_in => 'You cannot delete your account while logged in.';
  @override
  String get error_roommate_in_use => '{name} still has assigned to-dos. Remove them first.';
  @override
  String get confirm_delete_roommate => 'Are you sure you want to delete "{name}"?';
  @override
  String get no_category => 'No category';
  @override
  String get csv_section_expenses_by_category => '=== EXPENSES BY CATEGORY ===';
  @override
  String get csv_section_tasks_by_roommate => '=== COMPLETED TASKS PER ROOMMATE ===';
  @override
  String get pdf_expenses_by_category_title => 'Expenses by category';
  @override
  String get pdf_tasks_by_roommate_title => 'Completed tasks per roommate';
  @override
  String get pie_hint_category_for => 'Expense category for {title}';
  @override
  String get pie_label_amount_of_total => '{category}: {amount} EUR, {percent}% of total';
  @override
  String get profile_unknown => 'Unknown';
  @override
  String get color_label => 'Color {name}';
  @override
  String get lang_italian => 'Italian';
  @override
  String get lang_english => 'English';
  @override
  String get no_transactions_to_export => 'No transactions to export';
  @override
  String get chart_expense_trend_title => 'Expense trend over time';
  @override
  String get chart_balance => 'Balance';
  @override
  String get dialog_delete_transaction_title => 'Delete transaction';
  @override
  String get dialog_delete_transaction_content => 'Are you sure you want to delete this transaction?';
  @override
  String get snackbar_transaction_deleted => 'Transaction deleted.';
  @override
  String get dialog_edit_transaction_title => 'Edit transaction';
  @override
  String get snackbar_transaction_updated => 'Transaction updated.';
  @override
  String get dialog_new_transaction_title => 'New transaction';
  @override
  String get admin_manage_categories => 'Manage Categories';
  @override
  String get admin_no_categories => 'No categories';
  @override
  String get admin_add_category_btn => 'Add Category';
  @override
  String get admin_manage_roommates => 'Manage Roommates';
  @override
  String get admin_no_roommates => 'No roommates';
  @override
  String get admin_add_roommate_btn => 'Add Roommate';
  @override
  String get tx_amount_label => 'Amount (€)';
  @override
  String get tx_amount_hint => 'positive = credit, negative = debit';
  @override
  String get tx_amount_required => 'Amount is required';
  @override
  String get tx_amount_nonzero => 'Enter a number different from 0';
  @override
  String get tx_note_label => 'Note (optional)';
  @override
  String get tx_note_hint => 'e.g. expense description';
}
