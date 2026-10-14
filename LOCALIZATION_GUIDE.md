# Localization Guide for Hesabatna

## Overview
The app supports both English and Arabic languages. Users can switch between languages in the Profile screen.

## How to Use Localization in Your Code

### 1. Import the localization package
```dart
import '../l10n/generated/app_localizations.dart';
```

### 2. Use localized strings
```dart
// Instead of hardcoded strings:
Text('Expenses')

// Use localized strings:
Text(AppLocalizations.of(context)!.expenses)
```

### 3. Common Usage Patterns

#### In StatelessWidget or ConsumerWidget
```dart
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  
  return Text(l10n.expenses);
}
```

#### In StatefulWidget or ConsumerStatefulWidget
```dart
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  
  return Text(l10n.addExpense);
}
```

## Available Translations

### App & Navigation
- `appName` - "Hesabatna" / "حسابتنا"
- `expenses` - "Expenses" / "المصروفات"
- `profile` - "Profile" / "الملف الشخصي"
- `summary` - "Summary" / "الملخص"
- `transactions` - "Transactions" / "المعاملات"
- `members` - "Members" / "الأعضاء"

### Group Management
- `addGroup` - "Add Group" / "إضافة مجموعة"
- `newGroup` - "New Group" / "مجموعة جديدة"
- `editGroup` - "Edit Group" / "تعديل المجموعة"
- `groupName` - "Group Name" / "اسم المجموعة"
- `currency` - "Currency" / "العملة"
- `createGroup` - "Create Group" / "إنشاء مجموعة"
- `deleteGroup` - "Delete Group" / "حذف المجموعة"

### Member Management
- `addMember` - "Add Member" / "إضافة عضو"
- `editMember` - "Edit Member" / "تعديل العضو"
- `memberName` - "Member Name" / "اسم العضو"
- `addFirstMember` - "Add First Member" / "إضافة أول عضو"
- `deleteMember` - "Delete Member" / "حذف العضو"
- `member` - "Member" / "عضو"

### Expense Management
- `addExpense` - "Add Expense" / "إضافة مصروف"
- `editExpense` - "Edit Expense" / "تعديل المصروف"
- `newExpense` - "New Expense" / "مصروف جديد"
- `description` - "Description" / "الوصف"
- `amount` - "Amount" / "المبلغ"
- `paidBy` - "Paid By" / "دفعه"
- `splitBetween` - "Split between" / "تقسيم بين"
- `splitMethod` - "Split Method" / "طريقة التقسيم"
- `equal` - "Equal" / "متساوي"
- `custom` - "Custom" / "مخصص"
- `date` - "Date" / "التاريخ"
- `notes` - "Notes" / "ملاحظات"
- `notesOptional` - "Notes (Optional)" / "ملاحظات (اختياري)"
- `deleteExpense` - "Delete Expense" / "حذف المصروف"

### Payment Management
- `addPayment` - "Add Payment" / "إضافة دفعة"
- `editPayment` - "Edit Payment" / "تعديل الدفعة"
- `newPayment` - "New Payment" / "دفعة جديدة"
- `fromPayer` - "From (Payer)" / "من (الدافع)"
- `toPayer` - "To (Receiver)" / "إلى (المستلم)"
- `whoIsPaying` - "Who is paying?" / "من الدافع؟"
- `whoIsReceiving` - "Who is receiving?" / "من المستلم؟"
- `deletePayment` - "Delete Payment" / "حذف الدفعة"

### Financial Terms
- `totalExpenses` - "Total Expenses" / "إجمالي المصروفات"
- `totalPayments` - "Total Payments" / "إجمالي الدفعات"
- `balance` - "Balance" / "الرصيد"
- `youOwe` - "You Owe" / "أنت مدين بـ"
- `owesYou` - "Owes You" / "مدين لك"
- `settled` - "Settled" / "مسوى"

### Actions
- `delete` - "Delete" / "حذف"
- `edit` - "Edit" / "تعديل"
- `export` - "Export" / "تصدير"
- `save` - "Save" / "حفظ"
- `add` - "Add" / "إضافة"
- `update` - "Update" / "تحديث"
- `cancel` - "Cancel" / "إلغاء"
- `saveChanges` - "Save Changes" / "حفظ التغييرات"
- `selectAll` - "Select All" / "تحديد الكل"
- `deselectAll` - "Deselect All" / "إلغاء تحديد الكل"

### Empty States
- `noMembersYet` - "No Members Yet" / "لا يوجد أعضاء بعد"
- `noExpensesYet` - "No Expenses Yet" / "لا توجد مصروفات بعد"
- `noPaymentsYet` - "No Payments Yet" / "لا توجد دفعات بعد"
- `noGroupsYet` - "No Groups Yet" / "لا توجد مجموعات بعد"

### Dialogs & Confirmations
- `confirmDelete` - "Are you sure you want to delete?" / "هل أنت متأكد من الحذف؟"
- `cannotBeUndone` - "This action cannot be undone." / "لا يمكن التراجع عن هذا الإجراء."

### Settings
- `settings` - "Settings" / "الإعدادات"
- `darkMode` - "Dark Mode" / "الوضع الداكن"
- `language` - "Language" / "اللغة"
- `english` - "English" / "English"
- `arabic` - "Arabic" / "العربية"

## Adding New Translations

### 1. Add to English file (`lib/l10n/app_en.arb`)
```json
{
  "myNewKey": "My English Text",
  "@myNewKey": {
    "description": "Description of what this text is for"
  }
}
```

### 2. Add to Arabic file (`lib/l10n/app_ar.arb`)
```json
{
  "myNewKey": "النص العربي"
}
```

### 3. Regenerate localization files
Run: `flutter pub get` or `flutter gen-l10n`

### 4. Use in code
```dart
Text(AppLocalizations.of(context)!.myNewKey)
```

## RTL (Right-to-Left) Support

The app automatically handles RTL layout for Arabic. Flutter's `Directionality` widget and `MaterialApp`'s locale system handle this automatically.

### Testing RTL
- Change language to Arabic in Profile screen
- The entire UI will flip to RTL layout
- Text alignment, icons, and navigation will reverse

## Best Practices

1. **Always use localized strings** - Never hardcode user-facing text
2. **Use descriptive keys** - `addExpense` is better than `text1`
3. **Add descriptions** - Help other developers understand context
4. **Test both languages** - Ensure UI looks good in English and Arabic
5. **Consider text length** - Arabic text may be longer/shorter than English
6. **Use semantic keys** - Group related translations (e.g., all expense-related keys together)

## Current Implementation Status

✅ **Completed:**
- Localization infrastructure setup
- English and Arabic translation files
- Language switcher in Profile screen
- Locale persistence (remembers user's choice)
- Example implementation in Home screen

⏳ **To Do:**
- Update all screens to use localized strings
- Update all dialogs to use localized strings
- Update all widgets to use localized strings
- Test all screens in both languages
- Verify RTL layout in all screens

## Quick Reference for Common Screens

### Groups List Screen
```dart
final l10n = AppLocalizations.of(context)!;
// Use: l10n.noGroupsYet, l10n.addGroup, l10n.deleteGroup, l10n.editGroup
```

### Add Expense Screen
```dart
final l10n = AppLocalizations.of(context)!;
// Use: l10n.addExpense, l10n.description, l10n.amount, l10n.paidBy, 
//      l10n.splitBetween, l10n.splitMethod, l10n.equal, l10n.custom,
//      l10n.date, l10n.notes, l10n.selectAll, l10n.deselectAll
```

### Add Payment Screen
```dart
final l10n = AppLocalizations.of(context)!;
// Use: l10n.addPayment, l10n.amount, l10n.fromPayer, l10n.toPayer,
//      l10n.date, l10n.notes
```

### Profile Screen
```dart
final l10n = AppLocalizations.of(context)!;
// Use: l10n.profile, l10n.settings, l10n.darkMode, l10n.language
```

## Troubleshooting

### "AppLocalizations not found"
- Run `flutter pub get`
- Check that `generate: true` is in `pubspec.yaml`
- Verify `l10n.yaml` exists in project root

### "Locale not changing"
- Check that `localeProvider` is being watched
- Verify `PreferencesService.setLocale()` is being called
- Restart the app after changing language

### "Text not translating"
- Ensure the key exists in both `.arb` files
- Run `flutter pub get` after adding new keys
- Check for typos in key names

