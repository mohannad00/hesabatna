import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('ar', 'EG'),
    Locale('en'),
    Locale('en', 'US'),
  ];

  /// The application name
  ///
  /// In en, this message translates to:
  /// **'Hesabatna'**
  String get appName;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @addGroup.
  ///
  /// In en, this message translates to:
  /// **'Add Group'**
  String get addGroup;

  /// No description provided for @newGroup.
  ///
  /// In en, this message translates to:
  /// **'New Group'**
  String get newGroup;

  /// No description provided for @editGroup.
  ///
  /// In en, this message translates to:
  /// **'Edit Group'**
  String get editGroup;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get groupName;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get createGroup;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @addMember.
  ///
  /// In en, this message translates to:
  /// **'Add Member'**
  String get addMember;

  /// No description provided for @editMember.
  ///
  /// In en, this message translates to:
  /// **'Edit Member'**
  String get editMember;

  /// No description provided for @memberName.
  ///
  /// In en, this message translates to:
  /// **'Member Name'**
  String get memberName;

  /// No description provided for @addFirstMember.
  ///
  /// In en, this message translates to:
  /// **'Add First Member'**
  String get addFirstMember;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @editExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpense;

  /// No description provided for @newExpense.
  ///
  /// In en, this message translates to:
  /// **'New Expense'**
  String get newExpense;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @paidBy.
  ///
  /// In en, this message translates to:
  /// **'Paid By'**
  String get paidBy;

  /// No description provided for @splitBetween.
  ///
  /// In en, this message translates to:
  /// **'Split between'**
  String get splitBetween;

  /// No description provided for @splitMethod.
  ///
  /// In en, this message translates to:
  /// **'Split Method'**
  String get splitMethod;

  /// No description provided for @equal.
  ///
  /// In en, this message translates to:
  /// **'Equal'**
  String get equal;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get notesOptional;

  /// No description provided for @addPayment.
  ///
  /// In en, this message translates to:
  /// **'Add Payment'**
  String get addPayment;

  /// No description provided for @editPayment.
  ///
  /// In en, this message translates to:
  /// **'Edit Payment'**
  String get editPayment;

  /// No description provided for @newPayment.
  ///
  /// In en, this message translates to:
  /// **'New Payment'**
  String get newPayment;

  /// No description provided for @fromPayer.
  ///
  /// In en, this message translates to:
  /// **'From (Payer)'**
  String get fromPayer;

  /// No description provided for @toPayer.
  ///
  /// In en, this message translates to:
  /// **'To (Receiver)'**
  String get toPayer;

  /// No description provided for @whoIsPaying.
  ///
  /// In en, this message translates to:
  /// **'Who is paying?'**
  String get whoIsPaying;

  /// No description provided for @whoIsReceiving.
  ///
  /// In en, this message translates to:
  /// **'Who is receiving?'**
  String get whoIsReceiving;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpenses;

  /// No description provided for @totalPayments.
  ///
  /// In en, this message translates to:
  /// **'Total Payments'**
  String get totalPayments;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @youOwe.
  ///
  /// In en, this message translates to:
  /// **'You Owe'**
  String get youOwe;

  /// No description provided for @owesYou.
  ///
  /// In en, this message translates to:
  /// **'Owes You'**
  String get owesYou;

  /// No description provided for @settled.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get settled;

  /// No description provided for @noMembersYet.
  ///
  /// In en, this message translates to:
  /// **'No Members Yet'**
  String get noMembersYet;

  /// No description provided for @noExpensesYet.
  ///
  /// In en, this message translates to:
  /// **'No Expenses Yet'**
  String get noExpensesYet;

  /// No description provided for @noPaymentsYet.
  ///
  /// In en, this message translates to:
  /// **'No Payments Yet'**
  String get noPaymentsYet;

  /// No description provided for @noGroupsYet.
  ///
  /// In en, this message translates to:
  /// **'No Groups Yet'**
  String get noGroupsYet;

  /// No description provided for @deleteGroup.
  ///
  /// In en, this message translates to:
  /// **'Delete Group'**
  String get deleteGroup;

  /// No description provided for @deleteMember.
  ///
  /// In en, this message translates to:
  /// **'Delete Member'**
  String get deleteMember;

  /// No description provided for @deleteExpense.
  ///
  /// In en, this message translates to:
  /// **'Delete Expense'**
  String get deleteExpense;

  /// No description provided for @deletePayment.
  ///
  /// In en, this message translates to:
  /// **'Delete Payment'**
  String get deletePayment;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete?'**
  String get confirmDelete;

  /// No description provided for @cannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get cannotBeUndone;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @showNote.
  ///
  /// In en, this message translates to:
  /// **'Show Note'**
  String get showNote;

  /// No description provided for @hideNote.
  ///
  /// In en, this message translates to:
  /// **'Hide Note'**
  String get hideNote;

  /// No description provided for @enterGroupName.
  ///
  /// In en, this message translates to:
  /// **'Enter group name'**
  String get enterGroupName;

  /// No description provided for @enterMemberName.
  ///
  /// In en, this message translates to:
  /// **'Enter member name'**
  String get enterMemberName;

  /// No description provided for @enterDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter description'**
  String get enterDescription;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmount;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @selectMember.
  ///
  /// In en, this message translates to:
  /// **'Select a member'**
  String get selectMember;

  /// No description provided for @selectPayer.
  ///
  /// In en, this message translates to:
  /// **'Select who paid'**
  String get selectPayer;

  /// No description provided for @selectBeneficiaries.
  ///
  /// In en, this message translates to:
  /// **'Select beneficiaries'**
  String get selectBeneficiaries;

  /// No description provided for @customAmount.
  ///
  /// In en, this message translates to:
  /// **'Custom amount'**
  String get customAmount;

  /// No description provided for @enterCustomAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter custom amount'**
  String get enterCustomAmount;

  /// No description provided for @totalMustMatch.
  ///
  /// In en, this message translates to:
  /// **'Total must match expense amount'**
  String get totalMustMatch;

  /// No description provided for @pleaseSelectPayer.
  ///
  /// In en, this message translates to:
  /// **'Please select who paid'**
  String get pleaseSelectPayer;

  /// No description provided for @pleaseSelectBeneficiaries.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one beneficiary'**
  String get pleaseSelectBeneficiaries;

  /// No description provided for @pleaseEnterDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description'**
  String get pleaseEnterDescription;

  /// No description provided for @pleaseEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get pleaseEnterAmount;

  /// No description provided for @pleaseEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get pleaseEnterValidAmount;

  /// No description provided for @pleaseSelectFromMember.
  ///
  /// In en, this message translates to:
  /// **'Please select who is paying'**
  String get pleaseSelectFromMember;

  /// No description provided for @pleaseSelectToMember.
  ///
  /// In en, this message translates to:
  /// **'Please select who is receiving'**
  String get pleaseSelectToMember;

  /// No description provided for @cannotPaySelf.
  ///
  /// In en, this message translates to:
  /// **'A member cannot pay themselves'**
  String get cannotPaySelf;

  /// No description provided for @memberNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Member name is required'**
  String get memberNameRequired;

  /// No description provided for @groupNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Group name is required'**
  String get groupNameRequired;

  /// No description provided for @memberAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'A member with this name already exists'**
  String get memberAlreadyExists;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get enterUsername;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @systemAuto.
  ///
  /// In en, this message translates to:
  /// **'System (Auto)'**
  String get systemAuto;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @debugTesting.
  ///
  /// In en, this message translates to:
  /// **'Debug & Testing'**
  String get debugTesting;

  /// No description provided for @addSampleData.
  ///
  /// In en, this message translates to:
  /// **'Add sample data for testing'**
  String get addSampleData;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @owes.
  ///
  /// In en, this message translates to:
  /// **'Owes'**
  String get owes;

  /// No description provided for @receives.
  ///
  /// In en, this message translates to:
  /// **'Receives'**
  String get receives;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'on'**
  String get on;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get to;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'from'**
  String get from;

  /// No description provided for @forPreposition.
  ///
  /// In en, this message translates to:
  /// **'for'**
  String get forPreposition;

  /// No description provided for @suggestedSettlements.
  ///
  /// In en, this message translates to:
  /// **'Suggested Settlements'**
  String get suggestedSettlements;

  /// No description provided for @noSettlementsNeeded.
  ///
  /// In en, this message translates to:
  /// **'All settled up!'**
  String get noSettlementsNeeded;

  /// No description provided for @should.
  ///
  /// In en, this message translates to:
  /// **'should'**
  String get should;

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'pay'**
  String get pay;

  /// No description provided for @expensesPaid.
  ///
  /// In en, this message translates to:
  /// **'Expenses Paid'**
  String get expensesPaid;

  /// No description provided for @moneyOwed.
  ///
  /// In en, this message translates to:
  /// **'Money Owed'**
  String get moneyOwed;

  /// No description provided for @moneyToReceive.
  ///
  /// In en, this message translates to:
  /// **'Money to Receive'**
  String get moneyToReceive;

  /// No description provided for @balancesWith.
  ///
  /// In en, this message translates to:
  /// **'Balances With'**
  String get balancesWith;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @detailsFor.
  ///
  /// In en, this message translates to:
  /// **'Details for'**
  String get detailsFor;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @expensesInvolved.
  ///
  /// In en, this message translates to:
  /// **'Expenses Involved'**
  String get expensesInvolved;

  /// No description provided for @paymentsInvolved.
  ///
  /// In en, this message translates to:
  /// **'Payments Involved'**
  String get paymentsInvolved;

  /// No description provided for @noExpensesInvolved.
  ///
  /// In en, this message translates to:
  /// **'No expenses involved'**
  String get noExpensesInvolved;

  /// No description provided for @noPaymentsInvolved.
  ///
  /// In en, this message translates to:
  /// **'No payments involved'**
  String get noPaymentsInvolved;

  /// No description provided for @areYouSureDeleteMember.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this member?'**
  String get areYouSureDeleteMember;

  /// No description provided for @memberDeleteWarning.
  ///
  /// In en, this message translates to:
  /// **'This will also delete all expenses and payments involving this member.'**
  String get memberDeleteWarning;

  /// No description provided for @exportPDF.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPDF;

  /// No description provided for @exportJSON.
  ///
  /// In en, this message translates to:
  /// **'Export JSON'**
  String get exportJSON;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'ar':
      {
        switch (locale.countryCode) {
          case 'EG':
            return AppLocalizationsArEg();
        }
        break;
      }
    case 'en':
      {
        switch (locale.countryCode) {
          case 'US':
            return AppLocalizationsEnUs();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
