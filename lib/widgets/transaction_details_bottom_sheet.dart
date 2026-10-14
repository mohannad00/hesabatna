import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/groups_provider.dart';
import '../providers/expenses_provider.dart';
import '../providers/payments_provider.dart';
import '../services/database_service.dart';
import '../models/expense.dart';
import '../models/payment.dart';
import '../models/expense_share.dart';
import '../models/member.dart';

class TransactionDetailsBottomSheet extends ConsumerStatefulWidget {
  final String groupId;
  final String memberId;
  final String otherMemberId; // The other person in the transaction

  const TransactionDetailsBottomSheet({
    super.key,
    required this.groupId,
    required this.memberId,
    required this.otherMemberId,
  });

  @override
  ConsumerState<TransactionDetailsBottomSheet> createState() =>
      _TransactionDetailsBottomSheetState();
}

class _TransactionDetailsBottomSheetState
    extends ConsumerState<TransactionDetailsBottomSheet> {
  final Set<String> _expandedExpenses = {};
  final Set<String> _expandedPayments = {};

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(groupProvider(widget.groupId));
    final members = ref.watch(membersProvider(widget.groupId));
    final expenses = ref.watch(expensesProvider(widget.groupId));
    final payments = ref.watch(paymentsProvider(widget.groupId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (group == null) {
      return const SizedBox();
    }

    final member = members.firstWhere((m) => m.id == widget.memberId);
    final otherMember = members.firstWhere((m) => m.id == widget.otherMemberId);

    final currencyFormat = NumberFormat.currency(
      symbol: group.currency ?? '\$',
    );
    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm');

    // Calculate transaction details
    final transactionData = _calculateTransactionDetails(
      widget.memberId,
      widget.otherMemberId,
      expenses,
      payments,
      members,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0D1B2A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF374151)
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFF2196F3),
                          child: Text(
                            member.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.compare_arrows,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 12),
                        CircleAvatar(
                          backgroundColor: const Color(0xFF10B981),
                          child: Text(
                            otherMember.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Transaction Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFE5E7EB)
                            : const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      '${member.name} ⟷ ${otherMember.name}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF6B7280),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),

              // Net Balance Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildNetBalanceCard(
                  isDark: isDark,
                  currencyFormat: currencyFormat,
                  netBalance: transactionData['netBalance'] as double,
                  memberName: member.name,
                  otherMemberName: otherMember.name,
                ),
              ),

              const SizedBox(height: 20),

              // Scrollable Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Summary Section
                    _buildSummarySection(
                      isDark: isDark,
                      currencyFormat: currencyFormat,
                      transactionData: transactionData,
                      memberName: member.name,
                      otherMemberName: otherMember.name,
                    ),

                    const SizedBox(height: 24),

                    // Expenses Paid by Member
                    if ((transactionData['expensesPaidByMember'] as List)
                        .isNotEmpty)
                      _buildExpensesSection(
                        isDark: isDark,
                        title: 'Expenses Paid by ${member.name}',
                        icon: Icons.payment_rounded,
                        color: const Color(0xFF2196F3),
                        expenses:
                            transactionData['expensesPaidByMember']
                                as List<Map<String, dynamic>>,
                        currencyFormat: currencyFormat,
                        dateFormat: dateFormat,
                        members: members,
                        expandedExpenses: _expandedExpenses,
                        onToggleExpand: (expenseId) {
                          setState(() {
                            if (_expandedExpenses.contains(expenseId)) {
                              _expandedExpenses.remove(expenseId);
                            } else {
                              _expandedExpenses.add(expenseId);
                            }
                          });
                        },
                      ),

                    const SizedBox(height: 20),

                    // Expenses Paid by Other Member
                    if ((transactionData['expensesPaidByOther'] as List)
                        .isNotEmpty)
                      _buildExpensesSection(
                        isDark: isDark,
                        title: 'Expenses Paid by ${otherMember.name}',
                        icon: Icons.receipt_long_rounded,
                        color: const Color(0xFF10B981),
                        expenses:
                            transactionData['expensesPaidByOther']
                                as List<Map<String, dynamic>>,
                        currencyFormat: currencyFormat,
                        dateFormat: dateFormat,
                        members: members,
                        expandedExpenses: _expandedExpenses,
                        onToggleExpand: (expenseId) {
                          setState(() {
                            if (_expandedExpenses.contains(expenseId)) {
                              _expandedExpenses.remove(expenseId);
                            } else {
                              _expandedExpenses.add(expenseId);
                            }
                          });
                        },
                      ),

                    const SizedBox(height: 20),

                    // Payments Section
                    if ((transactionData['payments'] as List).isNotEmpty)
                      _buildPaymentsSection(
                        isDark: isDark,
                        payments:
                            transactionData['payments']
                                as List<Map<String, dynamic>>,
                        currencyFormat: currencyFormat,
                        dateFormat: dateFormat,
                        memberName: member.name,
                        otherMemberName: otherMember.name,
                        expandedPayments: _expandedPayments,
                        onToggleExpand: (paymentId) {
                          setState(() {
                            if (_expandedPayments.contains(paymentId)) {
                              _expandedPayments.remove(paymentId);
                            } else {
                              _expandedPayments.add(paymentId);
                            }
                          });
                        },
                      ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, dynamic> _calculateTransactionDetails(
    String memberId,
    String otherMemberId,
    List<Expense> expenses,
    List<Payment> payments,
    List<Member> members,
  ) {
    double memberOwesOther = 0.0;
    double otherOwesMember = 0.0;

    final List<Map<String, dynamic>> expensesPaidByMember = [];
    final List<Map<String, dynamic>> expensesPaidByOther = [];
    final List<Map<String, dynamic>> paymentsData = [];

    // Process expenses
    for (final expense in expenses) {
      final shares = DatabaseService.getExpenseSharesByExpenseId(expense.id);

      if (expense.payerId == memberId) {
        // Member paid the expense, check if other member benefited
        final otherShare = shares.firstWhere(
          (share) => share.memberId == otherMemberId,
          orElse: () =>
              ExpenseShare(id: '', expenseId: '', memberId: '', shareAmount: 0),
        );

        if (otherShare.shareAmount > 0) {
          otherOwesMember += otherShare.shareAmount;
          expensesPaidByMember.add({
            'expense': expense,
            'shareAmount': otherShare.shareAmount,
            'totalAmount': expense.amount,
            'allShares': shares,
          });
        }
      } else if (expense.payerId == otherMemberId) {
        // Other member paid the expense, check if member benefited
        final memberShare = shares.firstWhere(
          (share) => share.memberId == memberId,
          orElse: () =>
              ExpenseShare(id: '', expenseId: '', memberId: '', shareAmount: 0),
        );

        if (memberShare.shareAmount > 0) {
          memberOwesOther += memberShare.shareAmount;
          expensesPaidByOther.add({
            'expense': expense,
            'shareAmount': memberShare.shareAmount,
            'totalAmount': expense.amount,
            'allShares': shares,
          });
        }
      }
    }

    // Process payments
    for (final payment in payments) {
      if ((payment.fromId == memberId && payment.toId == otherMemberId) ||
          (payment.fromId == otherMemberId && payment.toId == memberId)) {
        paymentsData.add({
          'payment': payment,
          'direction': payment.fromId == memberId
              ? 'memberToOther'
              : 'otherToMember',
        });

        if (payment.fromId == memberId) {
          // Member paid other member
          memberOwesOther -= payment.amount;
        } else {
          // Other member paid member
          otherOwesMember -= payment.amount;
        }
      }
    }

    final double netBalance = otherOwesMember - memberOwesOther;

    return {
      'memberOwesOther': memberOwesOther,
      'otherOwesMember': otherOwesMember,
      'netBalance': netBalance,
      'expensesPaidByMember': expensesPaidByMember,
      'expensesPaidByOther': expensesPaidByOther,
      'payments': paymentsData,
    };
  }

  Widget _buildNetBalanceCard({
    required bool isDark,
    required NumberFormat currencyFormat,
    required double netBalance,
    required String memberName,
    required String otherMemberName,
  }) {
    final isPositive = netBalance > 0.01;
    final isNegative = netBalance < -0.01;
    final color = isPositive
        ? const Color(0xFF10B981)
        : isNegative
        ? const Color(0xFFEF4444)
        : const Color(0xFF6B7280);

    String statusText;
    if (isPositive) {
      statusText = '$otherMemberName owes $memberName';
    } else if (isNegative) {
      statusText = '$memberName owes $otherMemberName';
    } else {
      statusText = 'All settled up!';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Icon(
            isPositive
                ? Icons.trending_up_rounded
                : isNegative
                ? Icons.trending_down_rounded
                : Icons.check_circle_rounded,
            size: 32,
            color: color,
          ),
          const SizedBox(height: 12),
          Text(
            currencyFormat.format(netBalance.abs()),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection({
    required bool isDark,
    required NumberFormat currencyFormat,
    required Map<String, dynamic> transactionData,
    required String memberName,
    required String otherMemberName,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calculation Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),

          _buildSummaryRow(
            isDark: isDark,
            label: '$otherMemberName owes $memberName',
            amount: currencyFormat.format(transactionData['otherOwesMember']),
            color: const Color(0xFF10B981),
          ),

          const SizedBox(height: 8),

          _buildSummaryRow(
            isDark: isDark,
            label: '$memberName owes $otherMemberName',
            amount: currencyFormat.format(transactionData['memberOwesOther']),
            color: const Color(0xFFEF4444),
          ),

          const Divider(height: 24),

          _buildSummaryRow(
            isDark: isDark,
            label: 'Net Balance',
            amount: currencyFormat.format(
              (transactionData['netBalance'] as double).abs(),
            ),
            color: (transactionData['netBalance'] as double) > 0.01
                ? const Color(0xFF10B981)
                : (transactionData['netBalance'] as double) < -0.01
                ? const Color(0xFFEF4444)
                : const Color(0xFF6B7280),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required bool isDark,
    required String label,
    required String amount,
    required Color color,
    bool isTotal = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF374151),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildExpensesSection({
    required bool isDark,
    required String title,
    required IconData icon,
    required Color color,
    required List<Map<String, dynamic>> expenses,
    required NumberFormat currencyFormat,
    required DateFormat dateFormat,
    required List<Member> members,
    required Set<String> expandedExpenses,
    required Function(String) onToggleExpand,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? const Color(0xFFE5E7EB)
                      : const Color(0xFF1E293B),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ...expenses.map((expenseData) {
          final expense = expenseData['expense'] as Expense;
          final shareAmount = expenseData['shareAmount'] as double;
          final allShares = expenseData['allShares'] as List<ExpenseShare>;

          final beneficiaries = allShares
              .map((share) {
                final member = members.firstWhere(
                  (m) => m.id == share.memberId,
                );
                return '${member.name} (${currencyFormat.format(share.shareAmount)})';
              })
              .join(', ');

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        expense.description,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFFE5E7EB)
                              : const Color(0xFF1E293B),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        currencyFormat.format(shareAmount),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: ${currencyFormat.format(expense.amount)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280),
                  ),
                ),
                Text(
                  dateFormat.format(expense.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Split: $beneficiaries',
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                if (expense.notes?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => onToggleExpand(expense.id),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: color.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            expandedExpenses.contains(expense.id)
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            size: 16,
                            color: color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            expandedExpenses.contains(expense.id)
                                ? 'Hide Note'
                                : 'Show Note',
                            style: TextStyle(
                              fontSize: 11,
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (expense.notes?.isNotEmpty == true &&
                    expandedExpenses.contains(expense.id)) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.note_rounded, size: 14, color: color),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            expense.notes!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xFFE5E7EB)
                                  : const Color(0xFF1E293B),
                              fontStyle: FontStyle.italic,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPaymentsSection({
    required bool isDark,
    required List<Map<String, dynamic>> payments,
    required NumberFormat currencyFormat,
    required DateFormat dateFormat,
    required String memberName,
    required String otherMemberName,
    required Set<String> expandedPayments,
    required Function(String) onToggleExpand,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.swap_horiz_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Direct Payments',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? const Color(0xFFE5E7EB)
                    : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ...payments.map((paymentData) {
          final payment = paymentData['payment'] as Payment;
          final direction = paymentData['direction'] as String;
          final isFromMember = direction == 'memberToOther';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8B5CF6).withOpacity(0.1),
                  const Color(0xFF8B5CF6).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isFromMember ? Icons.arrow_forward : Icons.arrow_back,
                      color: const Color(0xFF8B5CF6),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isFromMember
                            ? '$memberName paid $otherMemberName'
                            : '$otherMemberName paid $memberName',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFFE5E7EB)
                              : const Color(0xFF1E293B),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        currencyFormat.format(payment.amount),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  dateFormat.format(payment.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280),
                  ),
                ),
                if (payment.notes?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => onToggleExpand(payment.id),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF8B5CF6).withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            expandedPayments.contains(payment.id)
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            size: 16,
                            color: const Color(0xFF8B5CF6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            expandedPayments.contains(payment.id)
                                ? 'Hide Note'
                                : 'Show Note',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF8B5CF6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (payment.notes?.isNotEmpty == true &&
                    expandedPayments.contains(payment.id)) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF8B5CF6).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.note_rounded,
                          size: 14,
                          color: Color(0xFF8B5CF6),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            payment.notes!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xFFE5E7EB)
                                  : const Color(0xFF1E293B),
                              fontStyle: FontStyle.italic,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}
