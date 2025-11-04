// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Coinquilini';

  @override
  String get nav_todo => 'TO-DO';

  @override
  String get nav_profile => 'PROFILO';

  @override
  String get nav_admin => 'ADMIN';

  @override
  String get nav_download => 'DOWNLOAD';

  @override
  String get nav_new => 'NUOVO';

  @override
  String get todos_filter_all => 'Tutti';

  @override
  String get todos_filter_done => 'Fatti';

  @override
  String get todos_filter_open => 'Da fare';

  @override
  String get todos_order_date => 'Data';

  @override
  String get todos_order_cost => 'Costo';

  @override
  String get todos_order_new => 'Nuovo';

  @override
  String get categories_all => 'Tutte';

  @override
  String get profile_you => 'Tu';

  @override
  String get table_title => 'Titolo';

  @override
  String get table_categories => 'Categorie';

  @override
  String get table_cost => 'Costo';

  @override
  String get table_date => 'Data';

  @override
  String get table_creator => 'Creatore';

  @override
  String get table_assignees => 'Assegnatari';

  // Common
  @override
  String get common_cancel => 'Annulla';
  @override
  String get common_save => 'Salva';
  @override
  String get common_add => 'Aggiungi';
  @override
  String get common_delete => 'Elimina';
  @override
  String get common_ok => 'OK';
  @override
  String get common_csv => 'CSV';
  @override
  String get common_pdf => 'PDF';
  @override
  String get common_download => 'Scarica';
  @override
  String get common_language => 'Lingua';

  // Profile
  @override
  String get profile_login_required => 'Effettua il login per vedere il profilo.';
  @override
  String get pagination_prev => 'Pagina precedente';
  @override
  String get pagination_next => 'Pagina successiva';

  // ToDo dialog
  @override
  String get todo_dialog_new_task => 'Nuovo Task';
  @override
  String get todo_dialog_edit_task => 'Modifica Task';
  @override
  String get todo_dialog_title_label => 'Titolo *';
  @override
  String get todo_dialog_title_required => 'Titolo obbligatorio';
  @override
  String get todo_dialog_cost_label => 'Costo (€) *';
  @override
  String get todo_dialog_cost_required => 'Costo obbligatorio';
  @override
  String get todo_dialog_categories => 'Categorie';
  @override
  String get todo_dialog_due_date => 'Scadenza';
  @override
  String get todo_dialog_optional => 'Opzionale';
  @override
  String get todo_dialog_notes_label => 'Note (opzionale)';
  @override
  String get todo_dialog_notes_hint => 'Dettagli...';
  @override
  String get todo_dialog_assign_to => 'Assegna a';
  @override
  String get todo_dialog_no_roommates => 'Nessun coinquilino disponibile. Fai login.';

  // Admin
  @override
  String get admin_add_category => 'Aggiungi nuova categoria';
  @override
  String get admin_category_name => 'Nome categoria';
  @override
  String get admin_add_roommate => 'Aggiungi Coinquilino';
  @override
  String get admin_roommate_name => 'Nome coinquilino';
  @override
  String get admin_edit_roommate => 'Modifica Coinquilino';
  @override
  String get admin_stats_title => 'Statistiche Admin';

  // Export and tables
  @override
  String get export_csv_desc => 'Esporta tabelle in CSV.';
  @override
  String get export_pdf_desc => 'Esporta tabelle in PDF.';
  @override
  String get table_category => 'Categoria';
  @override
  String get table_amount_eur => 'Importo (EUR)';
  @override
  String get table_roommate => 'Coinquilino';
  @override
  String get table_tasks_completed => 'Task completati';

  // Downloads
  @override
  String get download_charts_title => 'Scarica dati grafici';
  @override
  String get pdf_generated_success => 'PDF dei dati grafici generato con successo';
  @override
  String get export_choose_format => 'Scegli il formato da esportare';
  @override
  String get common_edit => 'Modifica';
  @override
  String get common_actions => 'Azioni';
  @override
  String get common_retry => 'Riprova';
  @override
  String get common_reset => 'Reset';
  @override
  String get transactions_empty => 'Nessuna transazione';
  @override
  String get transactions_add_first => 'Aggiungi la prima transazione per iniziare.';
  @override
  String get todos_empty => 'Nessun task';
  @override
  String get todos_add_first => 'Aggiungi il primo task per organizzare la casa.';
  @override
  String get help_title => 'Come funziona';
  @override
  String get help_bullet_amount => '• Importo: positivo = accredito, negativo = addebito.';
  @override
  String get help_bullet_filters => '• Filtri: scegli una categoria e/o un intervallo di date.';
  @override
  String get help_bullet_add => '• Aggiungi: usa il pulsante ‘Aggiungi’ per inserire una nuova voce.';
  @override
  String get help_hide => 'Nascondi aiuto';
  @override
  String get weather_loading => 'Caricamento...';
  @override
  String get weather_error => 'Errore meteo';
  @override
  String get weather_loading_city => 'Caricamento meteo per {city}...';
  @override
  String get weather_humidity => 'Umidità: {value}%';
  @override
  String get weather_wind => 'Vento: {value} m/s';
  @override
  String get me_balance_current => 'Saldo attuale';
  @override
  String get csv_generated => 'CSV generato';
  @override
  String get shortcuts_hint => 'Scorciatoie: H = Home • S = Scarica • A = Aggiungi Transazione';
  @override
  String get charts_exported_file => 'Dati grafici esportati: {filename}';
  @override
  String get error_cannot_delete => 'Impossibile eliminare';
  @override
  String get error_category_in_use => 'La categoria "{name}" è ancora in uso in alcuni to-do. Rimuovila prima.';
  @override
  String get confirm_delete_title => 'Conferma eliminazione';
  @override
  String get confirm_delete_category => 'Sei sicuro di voler eliminare la categoria "{name}"?';
  @override
  String get csv_section_status_todos => '=== STATO TODOS ===';
  @override
  String get csv_status => 'Stato';
  @override
  String get csv_quantity => 'Quantità';
  @override
  String get csv_total => 'TOTALE';
  @override
  String get csv_generated_on => 'Generato il: {timestamp}';
  @override
  String get pdf_todo_status_title => 'Stato dei To-Do';
  @override
  String get admin_chart_todo_done => 'Todo Completati';
  @override
  String get admin_chart_todo_open => 'Todo Da Fare';
  @override
  String get admin_chart_total_budget => 'Budget Totale';
  @override
  String get no_data_available => 'Nessun dato disponibile';
  @override
  String get total_label => 'Totale';
  @override
  String get select_icon => 'Seleziona icona';
  @override
  String get select_color => 'Seleziona colore';
  @override
  String get error_name_icon_required => "Inserisci un nome e scegli un'icona prima di aggiungere la categoria.";
  @override
  String get error_operation_not_allowed => 'Operazione non consentita';
  @override
  String get error_cannot_delete_logged_in => 'Non puoi eliminare il tuo account mentre sei connesso.';
  @override
  String get error_roommate_in_use => '{name} ha ancora dei to‑do assegnati. Rimuovili prima.';
  @override
  String get confirm_delete_roommate => 'Sei sicuro di voler eliminare "{name}"?';
  @override
  String get no_category => 'Senza categoria';
  @override
  String get csv_section_expenses_by_category => '=== SPESE PER CATEGORIA ===';
  @override
  String get csv_section_tasks_by_roommate => '=== TASK COMPLETATI PER COINQUILINO ===';
  @override
  String get pdf_expenses_by_category_title => 'Spese per categoria';
  @override
  String get pdf_tasks_by_roommate_title => 'Task completati per coinquilino';
  @override
  String get pie_hint_category_for => 'Categoria di spesa per {title}';
  @override
  String get pie_label_amount_of_total => '{category}: {amount} EUR, {percent}% del totale';
  @override
  String get profile_unknown => 'Sconosciuto';
  @override
  String get color_label => 'Colore {name}';
  @override
  String get lang_italian => 'Italiano';
  @override
  String get lang_english => 'Inglese';
  @override
  String get no_transactions_to_export => 'Nessuna transazione da esportare';
  @override
  String get chart_expense_trend_title => 'Andamento delle spese nel tempo';
  @override
  String get chart_balance => 'Saldo';
  @override
  String get dialog_delete_transaction_title => 'Elimina transazione';
  @override
  String get dialog_delete_transaction_content => 'Sei sicuro di voler eliminare questa transazione?';
  @override
  String get snackbar_transaction_deleted => 'Transazione eliminata.';
  @override
  String get dialog_edit_transaction_title => 'Modifica transazione';
  @override
  String get snackbar_transaction_updated => 'Transazione modificata.';
  @override
  String get dialog_new_transaction_title => 'Nuova transazione';
  @override
  String get admin_manage_categories => 'Gestione Categorie';
  @override
  String get admin_no_categories => 'Nessuna categoria presente';
  @override
  String get admin_add_category_btn => 'Aggiungi Categoria';
  @override
  String get admin_manage_roommates => 'Gestione Coinquilini';
  @override
  String get admin_no_roommates => 'Nessun coinquilino presente';
  @override
  String get admin_add_roommate_btn => 'Aggiungi Coinquilino';
  @override
  String get tx_amount_label => 'Importo (€)';
  @override
  String get tx_amount_hint => 'positivo = accredito, negativo = addebito';
  @override
  String get tx_amount_required => 'Importo obbligatorio';
  @override
  String get tx_amount_nonzero => 'Inserisci un numero diverso da 0';
  @override
  String get tx_note_label => 'Nota (opzionale)';
  @override
  String get tx_note_hint => 'es. descrizione della spesa';
}
