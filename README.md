# Hesabatna v2 - Expense Tracking Application

A Flutter-based offline-first expense tracking and settlement application for managing shared expenses among groups.

## Features

✅ **Group Management**
- Create multiple groups with custom names and currencies
- Add/edit/delete members within each group
- Automatic tracking of creation dates

✅ **Expense Tracking**
- Record expenses with detailed information (description, amount, payer, date, notes)
- Two split methods:
  - **Equal Split**: Automatically divides expense equally among beneficiaries
  - **Custom Split**: Define specific amounts or percentages for each member
- View all expenses organized by group and member

✅ **Settlement Management**
- Record payments between members to settle debts
- Track all settlements with dates and notes
- View payment history for each member

✅ **Smart Balance Calculations**
- Real-time net balance calculation for each member
- Detailed breakdown of balances between individual members
- Suggested settlements showing minimum transactions needed to settle all debts

✅ **Export Capabilities**
- Export group data to PDF (beautifully formatted reports)
- Export to JSON (for backup and data portability)
- Share PDF reports directly from the app

✅ **100% Offline**
- No internet connection required
- All data stored locally using Hive database
- Fast and reliable performance

✅ **Localization**
- Full support for English and Arabic languages
- RTL (Right-to-Left) layout for Arabic
- Language switcher in Profile screen
- Persistent language preference

## Technology Stack

- **Framework**: Flutter
- **State Management**: Riverpod
- **Local Database**: Hive
- **PDF Generation**: pdf & printing packages
- **Date/Time Formatting**: intl
- **Localization**: flutter_localizations & intl

## Installation

1. Ensure you have Flutter installed and set up
2. Clone this repository
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Generate Hive type adapters:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
5. Run the app:
   ```bash
   flutter run
   ```

## Usage Guide

### Creating a Group
1. Launch the app and tap the **+ New Group** button
2. Enter a group name (e.g., "Trip to Dubai")
3. Optionally set a currency (default: USD)
4. Tap **Create**

### Adding Members
1. Open a group
2. Tap the menu (three dots) in the app bar
3. Select **Add Member**
4. Enter the member's name and tap **Add**

### Recording an Expense
1. Inside a group, tap the **+** floating action button
2. Fill in the expense details:
   - Description (e.g., "Dinner at Restaurant")
   - Amount
   - Who paid (select from members)
   - Date
   - Split method (Equal or Custom)
   - Select beneficiaries
   - Add optional notes
3. Tap **Add Expense**

### Recording a Settlement
1. Inside a group, tap the **Settle** button
2. Select:
   - From: Member who is paying
   - To: Member who is receiving
   - Amount
   - Date
3. Add optional notes (e.g., "Bank transfer")
4. Tap **Record Settlement**

### Viewing Balances
- **Summary Tab**: Shows net balance for all members and suggested settlements
- **Member Tabs**: Each member has a dedicated tab showing:
  - Their net balance
  - Balances with other members
  - Expenses they paid
  - Settlements they were involved in

### Exporting Data
1. Open a group
2. Tap the menu (three dots)
3. Choose:
   - **Export PDF**: Creates a formatted report you can share
   - **Export JSON**: Creates a backup file

## Data Structure

The app uses the following data models:

- **Group**: Contains group information (name, currency, creation date)
- **Member**: Represents a person in a group
- **Expense**: Records a payment made by one member
- **ExpenseShare**: Tracks how much each beneficiary owes for an expense
- **Payment**: Records settlements between members

## Balance Calculation Logic

The app calculates balances by:
1. Processing all expenses: Each beneficiary owes the payer their share
2. Processing all settlements: Reducing debt when payments are made
3. Computing net balances: Sum of all amounts owed to/from each member
4. Generating simplified settlements: Minimum transactions to settle all debts

**Example**:
- Ahmed paid $100 for dinner, split equally among Ahmed, Sara, and Ali
  - Sara owes Ahmed: $33.33
  - Ali owes Ahmed: $33.33
- Later, Sara pays Ahmed $30
  - Sara now owes Ahmed: $3.33
- Net balances:
  - Ahmed: +$36.66 (to receive)
  - Sara: -$3.33 (to pay)
  - Ali: -$33.33 (to pay)

## Future Enhancements (Not in Current Version)

The following features are planned for future versions:
- Voice input for quick expense entry (using Gemini API)
- Multi-currency support with conversion
- Cloud synchronization
- Advanced analytics and charts
- Automated settlement suggestions via messaging

## Requirements Met

This application fulfills all requirements specified in the SRS:

### Functional Requirements
- ✅ FR1.0: Group Management (create, edit, delete groups and members)
- ✅ FR2.0: Expense Management (record, edit, delete expenses with split methods)
- ✅ FR3.0: Payment Tracking (record settlements between members)
- ✅ FR4.0: Balances and Reporting (summary screen, member tabs, export)

### Non-Functional Requirements
- ✅ NFR1.0: Performance (fast load times, instant updates)
- ✅ NFR2.0: Security (100% offline, no external data transmission)
- ✅ NFR3.0: Technical (Flutter, Hive, Riverpod, TabBarView)

## License

This is a private project for expense tracking among friends and groups.

## Support

For issues or questions about the application, please refer to the code documentation or create an issue in the repository.

---

**Built with ❤️ using Flutter**
