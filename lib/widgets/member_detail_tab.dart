import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/groups_provider.dart';
import '../providers/expenses_provider.dart';
import '../providers/balance_provider.dart';
import '../services/database_service.dart';
import 'transaction_details_bottom_sheet.dart';

class MemberDetailTab extends ConsumerWidget {
  final String groupId;
  final String memberId;

  const MemberDetailTab({
    super.key,
    required this.groupId,
    required this.memberId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(groupProvider(groupId));
    final members = ref.watch(membersProvider(groupId));

    if (group == null) {
      return const Center(child: Text('Group not found'));
    }

    final member = members.firstWhere((m) => m.id == memberId);
    final expenses = ref.watch(expensesProvider(groupId));
    final balances = ref.watch(balanceProvider(groupId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Try to find member balance, or return null if not found (e.g., no expenses yet)
    final memberBalance = balances.cast<dynamic>().firstWhere(
      (mb) => mb.member.id == memberId,
      orElse: () => null,
    );

    final memberExpenses = expenses
        .where((e) => e.payerId == memberId)
        .toList();

    final currencyFormat = NumberFormat.currency(
      symbol: group.currency ?? '\$',
    );
    final dateFormat = DateFormat('MMM dd, yyyy');

    // Separate debts and receivables
    final owesToMe = <String, double>{};
    final iOwe = <String, double>{};

    // Only process balances if memberBalance exists (i.e., there are expenses)
    if (memberBalance != null) {
      memberBalance.balancesWith.forEach((otherId, balance) {
        if (balance > 0.01) {
          owesToMe[otherId] = balance;
        } else if (balance < -0.01) {
          iOwe[otherId] = balance.abs();
        }
      });
    }

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
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Money to Receive Section
          if (owesToMe.isNotEmpty) ...[
            _buildCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_downward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'To Receive',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? const Color(0xFFE5E7EB)
                                    : const Color(0xFF1E293B),
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              '${owesToMe.length} person${owesToMe.length > 1 ? 's' : ''} owe you',
                              style: TextStyle(
                                fontSize: 13,
                                color: const Color(0xFF10B981),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...owesToMe.entries.map((entry) {
                    final otherMember = members.firstWhere(
                      (m) => m.id == entry.key,
                      orElse: () => member,
                    );
                    return _buildBalanceItem(
                      isDark: isDark,
                      name: otherMember.name,
                      amount: currencyFormat.format(entry.value),
                      color: const Color(0xFF10B981),
                      isPositive: true,
                      onTap: () => _showTransactionDetails(context, entry.key),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Money to Pay Section
          if (iOwe.isNotEmpty) ...[
            _buildCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEF4444).withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'To Pay',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? const Color(0xFFE5E7EB)
                                    : const Color(0xFF1E293B),
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              'You owe ${iOwe.length} person${iOwe.length > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 13,
                                color: const Color(0xFFEF4444),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...iOwe.entries.map((entry) {
                    final otherMember = members.firstWhere(
                      (m) => m.id == entry.key,
                      orElse: () => member,
                    );
                    return _buildBalanceItem(
                      isDark: isDark,
                      name: otherMember.name,
                      amount: currencyFormat.format(entry.value),
                      color: const Color(0xFFEF4444),
                      isPositive: false,
                      onTap: () => _showTransactionDetails(context, entry.key),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Expenses History
          _buildCard(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2196F3).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Expenses Paid (${memberExpenses.length})',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFE5E7EB)
                            : const Color(0xFF1E293B),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (memberExpenses.isEmpty)
                  _buildEmptyState(isDark, 'No expenses paid yet')
                else
                  ...memberExpenses.map((expense) {
                    final shares = DatabaseService.getExpenseSharesByExpenseId(
                      expense.id,
                    );
                    final beneficiaries = shares
                        .map((s) {
                          final m = members.firstWhere(
                            (mem) => mem.id == s.memberId,
                            orElse: () => member,
                          );
                          return m.name;
                        })
                        .join(', ');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF2196F3).withOpacity(0.15),
                                  const Color(0xFF2196F3).withOpacity(0.05),
                                ]
                              : [
                                  const Color(0xFF2196F3).withOpacity(0.1),
                                  const Color(0xFF2196F3).withOpacity(0.05),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF2196F3).withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
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
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2196F3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  currencyFormat.format(expense.amount),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            dateFormat.format(expense.date),
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'For: $beneficiaries',
                            style: TextStyle(
                              fontSize: 13,
                              color: const Color(0xFF2196F3),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, String otherMemberId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailsBottomSheet(
        groupId: groupId,
        memberId: memberId,
        otherMemberId: otherMemberId,
      ),
    );
  }

  Widget _buildCard({required bool isDark, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark ? const Color(0xFF0D1B2A) : Colors.white,
        border: Border.all(
          color: isDark
              ? const Color(0xFF2196F3).withOpacity(0.1)
              : const Color(0xFF2196F3).withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: child,
    );
  }

  Widget _buildBalanceItem({
    required bool isDark,
    required String name,
    required String amount,
    required Color color,
    required bool isPositive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [color.withOpacity(0.15), color.withOpacity(0.05)]
                : [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.person_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? const Color(0xFFE5E7EB)
                      : const Color(0xFF1E293B),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                amount,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 48,
              color: isDark ? const Color(0xFF4B5563) : const Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? const Color(0xFF6B7280)
                    : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
