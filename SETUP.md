# Hesabatna v2 - Quick Setup Guide

## Prerequisites
- Flutter SDK installed (version 3.9.2 or higher)
- Android Studio / VS Code with Flutter extensions
- An Android emulator or iOS simulator, or a physical device

## Quick Start

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Generate Hive Type Adapters (Already Done)
The Hive type adapters have been generated. If you need to regenerate them:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Run the Application

**For Android:**
```bash
flutter run
```

**For iOS:**
```bash
flutter run -d ios
```

**For Web (Not recommended for this offline-first app):**
```bash
flutter run -d chrome
```

## Project Structure

```
lib/
├── models/               # Data models with Hive annotations
│   ├── group.dart
│   ├── group.g.dart     # Generated adapter
│   ├── member.dart
│   ├── member.g.dart    # Generated adapter
│   ├── expense.dart
│   ├── expense.g.dart   # Generated adapter
│   ├── expense_share.dart
│   ├── expense_share.g.dart  # Generated adapter
│   ├── payment.dart
│   └── payment.g.dart   # Generated adapter
├── services/            # Business logic
│   ├── database_service.dart    # Hive database operations
│   ├── balance_service.dart     # Balance calculations
│   └── export_service.dart      # PDF/JSON export
├── providers/           # Riverpod state management
│   ├── groups_provider.dart
│   ├── expenses_provider.dart
│   ├── payments_provider.dart
│   └── balance_provider.dart
├── screens/            # Main screens
│   ├── groups_list_screen.dart       # Home screen
│   ├── group_detail_screen.dart      # Group details with tabs
│   ├── add_expense_screen.dart       # Add/edit expense
│   └── add_payment_screen.dart       # Add settlement
├── widgets/            # Reusable widgets
│   ├── add_group_dialog.dart
│   ├── add_member_dialog.dart
│   ├── group_summary_tab.dart        # Summary tab content
│   └── member_detail_tab.dart        # Member tab content
└── main.dart           # App entry point
```

## Testing the Application

### First Time Setup
1. **Create a Group**: Tap "New Group" and name it (e.g., "Weekend Trip")
2. **Add Members**: Open the group, tap menu → "Add Member", add at least 2-3 members
3. **Add an Expense**: 
   - Tap the + button
   - Enter "Lunch" as description
   - Enter 90 as amount
   - Select who paid
   - Choose "Equal" split
   - Select all members as beneficiaries
   - Tap "Add Expense"
4. **View Balances**: Check the Summary tab to see who owes whom
5. **Record a Settlement**:
   - Tap "Settle" button
   - Select From/To members
   - Enter amount
   - Tap "Record Settlement"
6. **Export**: Tap menu → "Export PDF" to see the generated report

## Troubleshooting

### Build Runner Issues
If you get errors about missing generated files:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Hive Database Issues
If you need to clear the database during development:
```dart
// Add this temporarily in main.dart before DatabaseService.init()
await Hive.deleteBoxFromDisk('groups');
await Hive.deleteBoxFromDisk('members');
await Hive.deleteBoxFromDisk('expenses');
await Hive.deleteBoxFromDisk('expense_shares');
await Hive.deleteBoxFromDisk('payments');
```

### Hot Reload Issues
If UI doesn't update after code changes:
1. Try hot restart (Shift + R in terminal)
2. If that doesn't work, stop and restart: `flutter run`

## Development Tips

### Adding New Fields to Models
1. Update the model file (e.g., `group.dart`)
2. Run build_runner to regenerate adapters:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
3. Increment the `@HiveField` index for new fields

### Debugging
- Use `print()` statements or the debugger
- Check the console for error messages
- Use Flutter DevTools for advanced debugging

## Performance Notes
- The app is optimized for groups with up to 50 members
- Can handle 500+ transactions per group efficiently
- All calculations happen in memory for instant updates

## Next Steps: Adding Voice Input (Optional)

If you'd like to add voice input using Gemini API:
1. Add dependencies to `pubspec.yaml`:
   ```yaml
   speech_to_text: ^6.3.0
   google_generative_ai: ^0.2.0
   ```
2. Create a voice input service
3. Integrate with the Add Expense screen
4. Use Gemini to parse natural language like "Ahmed paid 300 for dinner"

Let me know if you need help implementing this feature!

## Support

If you encounter any issues:
1. Check the console for error messages
2. Ensure all dependencies are installed
3. Try `flutter clean` and rebuild
4. Check that Hive adapters are generated in `lib/models/*.g.dart`

---

**Happy Expense Tracking! 📊**

