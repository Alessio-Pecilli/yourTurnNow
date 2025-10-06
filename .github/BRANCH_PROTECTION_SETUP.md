# 🛡️ Branch Protection Setup

Per proteggere i branch principali e assicurarti che i test passino sempre prima del merge, segui questi passi:

## 1. Configurazione su GitHub

Vai nelle **Settings** del repository GitHub → **Branches** → **Add rule**

### Per il branch `main`:
- ✅ **Require status checks to pass before merging**
  - ✅ **Require branches to be up to date before merging**  
  - ✅ Seleziona: `🔍 Run Tests`
  - ✅ Seleziona: `🏗️ Build Check`
- ✅ **Require pull request reviews before merging**
- ✅ **Dismiss stale PR approvals when new commits are pushed**
- ✅ **Require review from code owners**
- ✅ **Restrict pushes that create files larger than 100MB**
- ✅ **Block force pushes**
- ✅ **Require linear history** (opzionale, per un history più pulito)

### Per il branch `develop`:
- ✅ **Require status checks to pass before merging**
  - ✅ **Require branches to be up to date before merging**
  - ✅ Seleziona: `🔍 Run Tests`
  - ✅ Seleziona: `🏗️ Build Check`
- ✅ **Block force pushes**

## 2. Workflow di lavoro consigliato

```bash
# 1. Crea un nuovo branch per la feature
git checkout -b feature/nuova-funzionalità

# 2. Sviluppa e testa localmente
flutter test

# 3. Commit e push
git add .
git commit -m "✨ Aggiungi nuova funzionalità"
git push origin feature/nuova-funzionalità

# 4. Apri una Pull Request su GitHub
# I test verranno eseguiti automaticamente

# 5. Dopo l'approvazione, merge nella develop
# 6. Periodicamente, merge develop in main per i rilasci
```

## 3. Comandi di test locali

```bash
# Esegui tutti i test
flutter test

# Esegui test con coverage
flutter test --coverage

# Analizza il codice
flutter analyze

# Controlla la formattazione
dart format --set-exit-if-changed .

# Build per verificare compilazione
flutter build web
flutter build apk --debug
```

## 4. Struttura dei test creata

```
test/
├── models/
│   ├── todo_category_test.dart
│   ├── expense_category_test.dart
│   ├── money_tx_test.dart
│   └── roommate_test.dart
├── widgets/
│   ├── transaction_tile_card_test.dart
│   └── profile_header_test.dart
├── services/
│   └── csv_export_service_test.dart
├── providers/
│   └── categories_provider_test.dart
└── placeholder_test.dart
```

## 5. Badge per README (opzionale)

Aggiungi questi badge al tuo README.md:

```markdown
![CI Tests](https://github.com/YOUR-USERNAME/YOUR-REPO/workflows/🧪%20CI%20Tests/badge.svg)
[![codecov](https://codecov.io/gh/YOUR-USERNAME/YOUR-REPO/branch/main/graph/badge.svg)](https://codecov.io/gh/YOUR-USERNAME/YOUR-REPO)
```

## 6. Configurazione IDE (VS Code)

Aggiungi al tuo `.vscode/settings.json`:

```json
{
  "dart.runPubGetOnPubspecChanges": true,
  "dart.previewFlutterUiGuides": true,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  },
  "flutter.checkForSdkUpdates": false
}
```