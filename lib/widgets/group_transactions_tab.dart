import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/groups_provider.dart';
import '../providers/expenses_provider.dart';
import '../providers/payments_provider.dart';
import '../models/expense.dart';
import '../models/payment.dart';
import '../models/group.dart';
import '../models/member.dart';
import '../screens/add_expense_screen.dart';
import '../screens/add_payment_screen.dart';

// Transaction model to combine expenses and payments
class Transaction {
  final String id;
  final String groupId;
  final String type; // 'expense' or 'payment'
  final String description;
  final double amount;
  final DateTime date;
  final String? payerId;
  final String? fromId;
  final String? toId;
  final String? notes;
  final Expense? expense;
  final Payment? payment;

  Transaction({
    required this.id,
    required this.groupId,
    required this.type,
    required this.description,
    required this.amount,
    required this.date,
    this.payerId,
    this.fromId,
    this.toId,
    this.notes,
    this.expense,
    this.payment,
  });

  factory Transaction.fromExpense(Expense expense) {
    return Transaction(
      id: expense.id,
      groupId: expense.groupId,
      type: 'expense',
      description: expense.description,
      amount: expense.amount,
      date: expense.date,
      payerId: expense.payerId,
      notes: expense.notes,
      expense: expense,
    );
  }

  factory Transaction.fromPayment(Payment payment) {
    return Transaction(
      id: payment.id,
      groupId: payment.groupId,
      type: 'payment',
      description: payment.notes ?? 'Payment',
      amount: payment.amount,
      date: payment.date,
      fromId: payment.fromId,
      toId: payment.toId,
      notes: payment.notes,
      payment: payment,
    );
  }
}

class GroupTransactionsTab extends ConsumerStatefulWidget {
  final String groupId;

  const GroupTransactionsTab({super.key, required this.groupId});

  @override
  ConsumerState<GroupTransactionsTab> createState() =>
      _GroupTransactionsTabState();
}

class _GroupTransactionsTabState extends ConsumerState<GroupTransactionsTab> {
  final Set<String> _expandedTransactions = {};

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(groupProvider(widget.groupId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (group == null) {
      return const Center(child: Text('Group not found'));
    }

    // Get transactions for this specific group
    final transactions = _getGroupTransactions(ref, widget.groupId);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF0A1628), const Color(0xFF0D1B2A)]
              : [const Color(0xFFF5F9FF), Colors.white],
        ),
      ),
      child: transactions.isEmpty
          ? _buildEmptyState(isDark)
          : _buildTransactionsList(transactions, group, isDark, ref),
    );
  }

  List<Transaction> _getGroupTransactions(WidgetRef ref, String groupId) {
    final List<Transaction> transactions = [];

    // Get expenses for this group
    final expenses = ref.watch(expensesProvider(groupId));
    for (final expense in expenses) {
      transactions.add(Transaction.fromExpense(expense));
    }

    // Get payments for this group
    final payments = ref.watch(paymentsProvider(groupId));
    for (final payment in payments) {
      transactions.add(Transaction.fromPayment(payment));
    }

    // Sort by date (newest first)
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2196F3).withOpacity(0.1),
                    const Color(0xFF1976D2).withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 64,
                color: Color(0xFF2196F3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Transactions Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? const Color(0xFFE5E7EB)
                    : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start by adding expenses or payments\nto see transaction history here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(
    List<Transaction> transactions,
    Group group,
    bool isDark,
    WidgetRef ref,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];

        return _buildTransactionCard(transaction, group, isDark, ref, context);
      },
    );
  }

  Widget _buildTransactionCard(
    Transaction transaction,
    Group group,
    bool isDark,
    WidgetRef ref,
    BuildContext context,
  ) {
    final members = ref.watch(membersProvider(group.id));
    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm');
    final currencyFormat = NumberFormat.currency(
      symbol: group.currency ?? '\$',
    );

    final isExpense = transaction.type == 'expense';
    final color = isExpense ? const Color(0xFF2196F3) : const Color(0xFF10B981);
    final icon = isExpense ? Icons.receipt_rounded : Icons.swap_horiz_rounded;

    String subtitle = '';
    if (isExpense && transaction.payerId != null) {
      final payer = members.firstWhere(
        (m) => m.id == transaction.payerId,
        orElse: () => Member(id: '', name: 'Unknown', groupId: group.id),
      );
      subtitle = 'Paid by ${payer.name}';
    } else if (!isExpense &&
        transaction.fromId != null &&
        transaction.toId != null) {
      final from = members.firstWhere(
        (m) => m.id == transaction.fromId,
        orElse: () => Member(id: '', name: 'Unknown', groupId: group.id),
      );
      final to = members.firstWhere(
        (m) => m.id == transaction.toId,
        orElse: () => Member(id: '', name: 'Unknown', groupId: group.id),
      );
      subtitle = '${from.name} → ${to.name}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFFE5E7EB)
                            : const Color(0xFF1F2937),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(transaction.amount),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isExpense ? 'Expense' : 'Payment',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: isDark
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF6B7280),
                  size: 20,
                ),
                onPressed: () {
                  _showTransactionOptions(context, transaction, ref, isDark);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (transaction.notes?.isNotEmpty == true)
                InkWell(
                  onTap: () {
                    setState(() {
                      if (_expandedTransactions.contains(transaction.id)) {
                        _expandedTransactions.remove(transaction.id);
                      } else {
                        _expandedTransactions.add(transaction.id);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF2196F3).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _expandedTransactions.contains(transaction.id)
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          size: 18,
                          color: const Color(0xFF2196F3),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _expandedTransactions.contains(transaction.id)
                              ? 'Hide Note'
                              : 'Show Note',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2196F3),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const Spacer(),
              Text(
                dateFormat.format(transaction.date),
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          if (transaction.notes?.isNotEmpty == true &&
              _expandedTransactions.contains(transaction.id)) ...[
            const SizedBox(height: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2196F3).withOpacity(0.1),
                    const Color(0xFF1976D2).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF2196F3).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.note_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      transaction.notes!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? const Color(0xFFE5E7EB)
                            : const Color(0xFF1E293B),
                        fontStyle: FontStyle.italic,
                        height: 1.4,
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
  }

  void _showTransactionOptions(
    BuildContext context,
    Transaction transaction,
    WidgetRef ref,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [const Color(0xFF1B263B), const Color(0xFF0D1B2A)]
                  : [Colors.white, const Color(0xFFF8FBFF)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF2196F3).withOpacity(0.2)
                  : const Color(0xFF2196F3).withOpacity(0.1),
              width: 1,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF475569)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          transaction.type == 'expense'
                              ? Icons.receipt_long_rounded
                              : Icons.payment_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          transaction.description,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFFE5E7EB)
                                : const Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2196F3).withOpacity(0.2),
                          const Color(0xFF1976D2).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF2196F3).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Color(0xFF2196F3),
                      size: 22,
                    ),
                  ),
                  title: Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFFE5E7EB)
                          : const Color(0xFF1E293B),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _editTransaction(transaction, ref, context);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFEF4444).withOpacity(0.2),
                          const Color(0xFFDC2626).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFEF4444).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.delete_rounded,
                      color: Color(0xFFEF4444),
                      size: 22,
                    ),
                  ),
                  title: const Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(transaction, ref, context);
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editTransaction(
    Transaction transaction,
    WidgetRef ref,
    BuildContext context,
  ) {
    if (transaction.type == 'expense') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddExpenseScreen(
            groupId: transaction.groupId,
            expenseId: transaction.id,
          ),
        ),
      );
    } else if (transaction.type == 'payment') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPaymentScreen(
            groupId: transaction.groupId,
            paymentId: transaction.id,
          ),
        ),
      );
    }
  }

  void _showDeleteConfirmation(
    Transaction transaction,
    WidgetRef ref,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete ${transaction.type == 'expense' ? 'Expense' : 'Payment'}',
          style: TextStyle(
            color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF1F2937),
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${transaction.description}"? This action cannot be undone.',
          style: TextStyle(
            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF6B7280),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTransaction(transaction, ref, context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteTransaction(
    Transaction transaction,
    WidgetRef ref,
    BuildContext context,
  ) {
    try {
      if (transaction.type == 'expense') {
        ref
            .read(expensesProvider(transaction.groupId).notifier)
            .deleteExpense(transaction.id);
      } else {
        ref
            .read(paymentsProvider(transaction.groupId).notifier)
            .deletePayment(transaction.id);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${transaction.type == 'expense' ? 'Expense' : 'Payment'} deleted successfully',
          ),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting ${transaction.type}: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }
}
