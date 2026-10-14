import 'dart:convert';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/member.dart';
import '../models/group.dart';
import '../models/expense.dart';
import '../models/expense_share.dart';
import '../models/payment.dart';
import 'database_service.dart';
import 'balance_service.dart';

class ExportService {
  static pw.Font? _arabicFont;
  static pw.Font? _arabicFontBold;

  /// Check if text contains Arabic characters
  static bool _containsArabic(String text) {
    return RegExp(
      r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
    ).hasMatch(text);
  }

  /// Load Arabic font (Amiri from Google Fonts)
  static Future<void> _loadArabicFont() async {
    if (_arabicFont == null) {
      _arabicFont = await PdfGoogleFonts.amiriRegular();
      _arabicFontBold = await PdfGoogleFonts.amiriBold();
    }
  }

  /// Get text style with Arabic support
  static pw.TextStyle _getTextStyle({
    double fontSize = 12,
    bool bold = false,
    PdfColor? color,
    bool forceArabic = false,
  }) {
    final font = bold ? _arabicFontBold : _arabicFont;
    return pw.TextStyle(
      font: font,
      fontBold: _arabicFontBold,
      fontSize: fontSize,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      color: color,
    );
  }

  /// Create text widget with RTL support for Arabic
  static pw.Widget _buildText(
    String text, {
    double fontSize = 12,
    bool bold = false,
    PdfColor? color,
    pw.TextAlign? textAlign,
    int? maxLines,
    bool softWrap = false,
  }) {
    final isArabic = _containsArabic(text);
    final style = _getTextStyle(
      fontSize: fontSize,
      bold: bold,
      color: color,
      forceArabic: isArabic,
    );

    return pw.Directionality(
      textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      child: pw.Text(
        text,
        style: style,
        textAlign:
            textAlign ?? (isArabic ? pw.TextAlign.right : pw.TextAlign.left),
        maxLines: maxLines,
        softWrap: softWrap,
        overflow: pw.TextOverflow.clip,
      ),
    );
  }

  /// Export group data to JSON
  static Future<File> exportToJson(String groupId) async {
    final group = DatabaseService.getGroup(groupId);
    if (group == null) throw Exception('Group not found');

    final members = DatabaseService.getMembersByGroupId(groupId);
    final expenses = DatabaseService.getExpensesByGroupId(groupId);
    final payments = DatabaseService.getPaymentsByGroupId(groupId);

    // Get all expense shares for this group's expenses
    final expenseShares = expenses
        .expand(
          (expense) => DatabaseService.getExpenseSharesByExpenseId(expense.id),
        )
        .toList();

    final data = {
      'group': group.toJson(),
      'members': members.map((m) => m.toJson()).toList(),
      'expenses': expenses.map((e) => e.toJson()).toList(),
      'expenseShares': expenseShares.map((es) => es.toJson()).toList(),
      'payments': payments.map((p) => p.toJson()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/hesabatna_${group.name}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json',
    );
    await file.writeAsString(jsonString);

    return file;
  }

  /// Share JSON file using printing package
  static Future<void> shareJson(String groupId) async {
    final file = await exportToJson(groupId);
    final bytes = await file.readAsBytes();
    await Printing.sharePdf(
      bytes: bytes,
      filename: file.path.split(Platform.pathSeparator).last,
    );
  }

  /// Get the export directory path for the user
  static Future<String> getExportPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// Import group from JSON file path
  static Future<ImportResult> importFromJsonPath(String filePath) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        return ImportResult(
          success: false,
          message: 'File not found: $filePath',
        );
      }

      final jsonString = await file.readAsString();
      final data = json.decode(jsonString) as Map<String, dynamic>;

      // Validate JSON structure
      if (!data.containsKey('group') || !data.containsKey('members')) {
        return ImportResult(
          success: false,
          message: 'Invalid file format. Missing required data.',
        );
      }

      // Import the group
      final importedGroup = await _importGroupData(data);

      return ImportResult(
        success: true,
        message: 'Group "${importedGroup.name}" imported successfully!',
        groupId: importedGroup.id,
        groupName: importedGroup.name,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        message: 'Error importing file: ${e.toString()}',
      );
    }
  }

  /// Import group from JSON string (for clipboard paste)
  static Future<ImportResult> importFromJsonString(String jsonString) async {
    try {
      final data = json.decode(jsonString) as Map<String, dynamic>;

      // Validate JSON structure
      if (!data.containsKey('group') || !data.containsKey('members')) {
        return ImportResult(
          success: false,
          message: 'Invalid file format. Missing required data.',
        );
      }

      // Import the group
      final importedGroup = await _importGroupData(data);

      return ImportResult(
        success: true,
        message: 'Group "${importedGroup.name}" imported successfully!',
        groupId: importedGroup.id,
        groupName: importedGroup.name,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        message: 'Error importing: ${e.toString()}',
      );
    }
  }

  /// Import group data from parsed JSON
  static Future<Group> _importGroupData(Map<String, dynamic> data) async {
    final groupData = data['group'] as Map<String, dynamic>;
    final membersData = data['members'] as List<dynamic>;
    final expensesData = data['expenses'] as List<dynamic>? ?? [];
    final expenseSharesData = data['expenseShares'] as List<dynamic>? ?? [];
    final paymentsData = data['payments'] as List<dynamic>? ?? [];

    // Create ID mapping for new IDs
    final Map<String, String> idMapping = {};

    // Generate new group ID
    final newGroupId = DateTime.now().millisecondsSinceEpoch.toString();
    idMapping[groupData['id']] = newGroupId;

    // Create the group with new ID
    final group = Group(
      id: newGroupId,
      name: groupData['name'] ?? 'Imported Group',
      currency: groupData['currency'] ?? 'USD',
      dateCreated: groupData['dateCreated'] != null
          ? DateTime.parse(groupData['dateCreated'])
          : DateTime.now(),
    );

    await DatabaseService.addGroup(group);

    // Create members with new IDs
    for (final memberData in membersData) {
      final oldId = memberData['id'] as String;
      final newMemberId =
          '${newGroupId}_${DateTime.now().microsecondsSinceEpoch}';
      idMapping[oldId] = newMemberId;

      final member = Member(
        id: newMemberId,
        name: memberData['name'] ?? 'Unknown',
        groupId: newGroupId,
      );
      await DatabaseService.addMember(member);

      // Small delay to ensure unique timestamps
      await Future.delayed(const Duration(milliseconds: 1));
    }

    // Create expenses with new IDs
    for (final expenseData in expensesData) {
      final oldExpenseId = expenseData['id'] as String;
      final newExpenseId =
          '${newGroupId}_exp_${DateTime.now().microsecondsSinceEpoch}';
      idMapping[oldExpenseId] = newExpenseId;

      final expense = Expense(
        id: newExpenseId,
        groupId: newGroupId,
        description: expenseData['description'] ?? '',
        amount: (expenseData['amount'] as num).toDouble(),
        payerId: idMapping[expenseData['payerId']] ?? expenseData['payerId'],
        splitMethod: _parseSplitMethod(expenseData['splitMethod']),
        date: expenseData['date'] != null
            ? DateTime.parse(expenseData['date'])
            : DateTime.now(),
        notes: expenseData['notes'],
      );
      await DatabaseService.addExpense(expense);

      await Future.delayed(const Duration(milliseconds: 1));
    }

    // Create expense shares with mapped IDs
    for (final shareData in expenseSharesData) {
      final share = ExpenseShare(
        id: '${newGroupId}_share_${DateTime.now().microsecondsSinceEpoch}',
        expenseId: idMapping[shareData['expenseId']] ?? shareData['expenseId'],
        memberId: idMapping[shareData['memberId']] ?? shareData['memberId'],
        shareAmount: (shareData['shareAmount'] as num).toDouble(),
      );
      await DatabaseService.addExpenseShare(share);

      await Future.delayed(const Duration(milliseconds: 1));
    }

    // Create payments with mapped IDs
    for (final paymentData in paymentsData) {
      final payment = Payment(
        id: '${newGroupId}_pay_${DateTime.now().microsecondsSinceEpoch}',
        groupId: newGroupId,
        fromId: idMapping[paymentData['fromId']] ?? paymentData['fromId'],
        toId: idMapping[paymentData['toId']] ?? paymentData['toId'],
        amount: (paymentData['amount'] as num).toDouble(),
        date: paymentData['date'] != null
            ? DateTime.parse(paymentData['date'])
            : DateTime.now(),
        notes: paymentData['notes'],
      );
      await DatabaseService.addPayment(payment);

      await Future.delayed(const Duration(milliseconds: 1));
    }

    return group;
  }

  /// Parse split method from string
  static SplitMethod _parseSplitMethod(String? method) {
    switch (method) {
      case 'custom':
        return SplitMethod.custom;
      case 'equal':
      default:
        return SplitMethod.equal;
    }
  }

  /// Export group data to PDF
  static Future<File> exportToPdf(
    String groupId, {
    String locale = 'en',
  }) async {
    // Load Arabic font for proper text rendering
    await _loadArabicFont();

    final group = DatabaseService.getGroup(groupId);
    if (group == null) throw Exception('Group not found');

    final members = DatabaseService.getMembersByGroupId(groupId);
    final expenses = DatabaseService.getExpensesByGroupId(groupId);
    final payments = DatabaseService.getPaymentsByGroupId(groupId);
    final balances = BalanceService.calculateGroupBalances(groupId);
    final settlements = BalanceService.getSimplifiedSettlements(groupId);

    final isArabic = locale == 'ar';
    final pdf = pw.Document();
    final dateFormat = DateFormat('MMM dd, yyyy', locale);
    final currencyFormat = NumberFormat.currency(
      symbol: group.currency ?? '\$',
    );

    // Localized strings
    final strings = isArabic ? _arabicStrings : _englishStrings;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        theme: pw.ThemeData.withFont(base: _arabicFont, bold: _arabicFontBold),
        build: (context) => [
          // Title
          pw.Container(
            width: double.infinity,
            child: _buildText(
              group.name,
              fontSize: 24,
              bold: true,
              textAlign: isArabic ? pw.TextAlign.right : pw.TextAlign.left,
            ),
          ),
          pw.SizedBox(height: 8),
          _buildText(
            '${strings['created']}: ${dateFormat.format(group.dateCreated)}',
            fontSize: 12,
          ),
          pw.SizedBox(height: 20),

          // Summary Section
          pw.Container(
            width: double.infinity,
            child: _buildText(
              strings['balanceSummary']!,
              fontSize: 18,
              bold: true,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildBalanceTable(balances, currencyFormat, strings, isArabic),
          pw.SizedBox(height: 20),

          // Suggested Settlements
          if (settlements.isNotEmpty) ...[
            pw.Container(
              width: double.infinity,
              child: _buildText(
                strings['suggestedSettlements']!,
                fontSize: 18,
                bold: true,
              ),
            ),
            pw.SizedBox(height: 10),
            _buildSettlementsTable(
              settlements,
              currencyFormat,
              strings,
              isArabic,
            ),
            pw.SizedBox(height: 20),
          ],

          // All Transactions Section
          pw.Container(
            width: double.infinity,
            child: _buildText(
              strings['allTransactions']!,
              fontSize: 18,
              bold: true,
            ),
          ),
          pw.SizedBox(height: 5),
          _buildText(
            '${strings['total']}: ${expenses.length + payments.length} ${strings['transactions']} (${expenses.length} ${strings['expenses']}, ${payments.length} ${strings['payments']})',
            fontSize: 12,
            color: PdfColors.grey700,
          ),
          pw.SizedBox(height: 10),

          // Build transactions table
          _buildTransactionsTable(
            expenses,
            payments,
            members,
            groupId,
            dateFormat,
            currencyFormat,
            strings,
            isArabic,
          ),

          pw.SizedBox(height: 10),

          // Summary Statistics
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
            ),
            child: pw.Column(
              crossAxisAlignment: isArabic
                  ? pw.CrossAxisAlignment.end
                  : pw.CrossAxisAlignment.start,
              children: [
                _buildText(
                  strings['summaryStatistics']!,
                  fontSize: 12,
                  bold: true,
                ),
                pw.SizedBox(height: 5),
                _buildText(
                  '${strings['totalExpenses']}: ${currencyFormat.format(expenses.fold<double>(0, (sum, e) => sum + e.amount))}',
                  fontSize: 10,
                ),
                _buildText(
                  '${strings['totalPayments']}: ${currencyFormat.format(payments.fold<double>(0, (sum, p) => sum + p.amount))}',
                  fontSize: 10,
                ),
                _buildText(
                  '${strings['numberOfMembers']}: ${members.length}',
                  fontSize: 10,
                ),
              ],
            ),
          ),

          // Footer
          pw.SizedBox(height: 30),
          _buildText(
            '${strings['generatedBy']} ${dateFormat.format(DateTime.now())}',
            fontSize: 10,
            color: PdfColors.grey,
          ),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/hesabatna_${group.name}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf',
    );
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  /// Build balance summary table with Arabic support
  static pw.Widget _buildBalanceTable(
    List<dynamic> balances,
    NumberFormat currencyFormat,
    Map<String, String> strings,
    bool isArabic,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: _buildText(strings['member']!, fontSize: 11, bold: true),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: _buildText(
                strings['netBalance']!,
                fontSize: 11,
                bold: true,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: _buildText(strings['status']!, fontSize: 11, bold: true),
            ),
          ],
        ),
        // Data rows
        ...balances.map((mb) {
          final status = mb.balance > 0.01
              ? strings['owed']!
              : mb.balance < -0.01
              ? strings['owes']!
              : strings['settled']!;
          return pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: _buildText(mb.member.name, fontSize: 10),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: _buildText(
                  currencyFormat.format(mb.balance.abs()),
                  fontSize: 10,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: _buildText(status, fontSize: 10),
              ),
            ],
          );
        }),
      ],
    );
  }

  /// Build settlements table with Arabic support
  static pw.Widget _buildSettlementsTable(
    List<dynamic> settlements,
    NumberFormat currencyFormat,
    Map<String, String> strings,
    bool isArabic,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.5),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: _buildText(strings['from']!, fontSize: 11, bold: true),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: _buildText(strings['to']!, fontSize: 11, bold: true),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: _buildText(strings['amount']!, fontSize: 11, bold: true),
            ),
          ],
        ),
        // Data rows
        ...settlements.map((s) {
          return pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: _buildText(s.from.name, fontSize: 10),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: _buildText(s.to.name, fontSize: 10),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: _buildText(
                  currencyFormat.format(s.amount),
                  fontSize: 10,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  /// Build transactions table with Arabic support
  static pw.Widget _buildTransactionsTable(
    List<dynamic> expenses,
    List<dynamic> payments,
    List<Member> members,
    String groupId,
    DateFormat dateFormat,
    NumberFormat currencyFormat,
    Map<String, String> strings,
    bool isArabic,
  ) {
    // Combine expenses and payments
    final allTransactions = <Map<String, dynamic>>[];

    for (final expense in expenses) {
      final payer = members.firstWhere(
        (m) => m.id == expense.payerId,
        orElse: () =>
            Member(id: '', name: strings['unknown']!, groupId: groupId),
      );
      final shares = DatabaseService.getExpenseSharesByExpenseId(expense.id);
      final beneficiaries = shares
          .map((s) {
            final member = members.firstWhere(
              (m) => m.id == s.memberId,
              orElse: () =>
                  Member(id: '', name: strings['unknown']!, groupId: groupId),
            );
            return member.name;
          })
          .join(', ');

      allTransactions.add({
        'date': expense.date,
        'type': strings['expense']!,
        'description': expense.description,
        'from': payer.name,
        'to': beneficiaries,
        'amount': expense.amount,
      });
    }

    for (final payment in payments) {
      final from = members.firstWhere(
        (m) => m.id == payment.fromId,
        orElse: () =>
            Member(id: '', name: strings['unknown']!, groupId: groupId),
      );
      final to = members.firstWhere(
        (m) => m.id == payment.toId,
        orElse: () =>
            Member(id: '', name: strings['unknown']!, groupId: groupId),
      );

      allTransactions.add({
        'date': payment.date,
        'type': strings['payment']!,
        'description': strings['settlement']!,
        'from': from.name,
        'to': to.name,
        'amount': payment.amount,
      });
    }

    allTransactions.sort(
      (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
    );

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: {
        0: const pw.FixedColumnWidth(60),
        1: const pw.FixedColumnWidth(50),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1.5),
        5: const pw.FixedColumnWidth(70),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: _buildText(strings['date']!, fontSize: 10, bold: true),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: _buildText(strings['type']!, fontSize: 10, bold: true),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: _buildText(
                strings['description']!,
                fontSize: 10,
                bold: true,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: _buildText(strings['from']!, fontSize: 10, bold: true),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: _buildText(strings['to']!, fontSize: 10, bold: true),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: _buildText(strings['amount']!, fontSize: 10, bold: true),
            ),
          ],
        ),
        // Data rows
        ...allTransactions.map((t) {
          return pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: _buildText(
                  dateFormat.format(t['date'] as DateTime),
                  fontSize: 9,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: _buildText(t['type'] as String, fontSize: 9),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: _buildText(
                  t['description'] as String,
                  fontSize: 9,
                  softWrap: true,
                  maxLines: 2,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: _buildText(
                  t['from'] as String,
                  fontSize: 9,
                  softWrap: true,
                  maxLines: 2,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: _buildText(
                  t['to'] as String,
                  fontSize: 9,
                  softWrap: true,
                  maxLines: 2,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: _buildText(
                  currencyFormat.format(t['amount']),
                  fontSize: 9,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  // English strings
  static const Map<String, String> _englishStrings = {
    'created': 'Created',
    'balanceSummary': 'Balance Summary',
    'suggestedSettlements': 'Suggested Settlements',
    'allTransactions': 'All Transactions',
    'total': 'Total',
    'transactions': 'transactions',
    'expenses': 'expenses',
    'payments': 'payments',
    'summaryStatistics': 'Summary Statistics',
    'totalExpenses': 'Total Expenses',
    'totalPayments': 'Total Payments',
    'numberOfMembers': 'Number of Members',
    'generatedBy': 'Generated by Hesabatna on',
    'member': 'Member',
    'netBalance': 'Net Balance',
    'status': 'Status',
    'owed': 'Owed',
    'owes': 'Owes',
    'settled': 'Settled',
    'from': 'From',
    'to': 'To',
    'amount': 'Amount',
    'date': 'Date',
    'type': 'Type',
    'description': 'Description',
    'expense': 'Expense',
    'payment': 'Payment',
    'settlement': 'Settlement',
    'unknown': 'Unknown',
  };

  // Arabic strings
  static const Map<String, String> _arabicStrings = {
    'created': 'تاريخ الإنشاء',
    'balanceSummary': 'ملخص الأرصدة',
    'suggestedSettlements': 'التسويات المقترحة',
    'allTransactions': 'جميع المعاملات',
    'total': 'الإجمالي',
    'transactions': 'معاملة',
    'expenses': 'مصروفات',
    'payments': 'مدفوعات',
    'summaryStatistics': 'إحصائيات ملخصة',
    'totalExpenses': 'إجمالي المصروفات',
    'totalPayments': 'إجمالي المدفوعات',
    'numberOfMembers': 'عدد الأعضاء',
    'generatedBy': 'تم الإنشاء بواسطة حساباتنا في',
    'member': 'العضو',
    'netBalance': 'صافي الرصيد',
    'status': 'الحالة',
    'owed': 'مستحق له',
    'owes': 'مدين',
    'settled': 'مسدد',
    'from': 'من',
    'to': 'إلى',
    'amount': 'المبلغ',
    'date': 'التاريخ',
    'type': 'النوع',
    'description': 'الوصف',
    'expense': 'مصروف',
    'payment': 'دفعة',
    'settlement': 'تسوية',
    'unknown': 'غير معروف',
  };

  /// Share PDF directly without preview (Export option)
  static Future<void> sharePdf(String groupId, {String locale = 'en'}) async {
    final file = await exportToPdf(groupId, locale: locale);
    await Printing.sharePdf(
      bytes: await file.readAsBytes(),
      filename: file.path.split('/').last,
    );
  }

  /// Print PDF directly (opens print dialog)
  static Future<void> printPdf(String groupId, {String locale = 'en'}) async {
    final group = DatabaseService.getGroup(groupId);
    final groupName = group?.name ?? 'export';
    final filename =
        'hesabatna_${groupName}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';

    final file = await exportToPdf(groupId, locale: locale);
    final bytes = await file.readAsBytes();

    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
      name: filename,
      format: PdfPageFormat.a4,
    );
  }
}

/// Result class for import operation
class ImportResult {
  final bool success;
  final String message;
  final String? groupId;
  final String? groupName;

  ImportResult({
    required this.success,
    required this.message,
    this.groupId,
    this.groupName,
  });
}
