import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/groups_provider.dart';
import '../providers/balance_provider.dart';

class GroupSummaryTab extends ConsumerWidget {
  final String groupId;

  const GroupSummaryTab({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(groupProvider(groupId));
    final balances = ref.watch(balanceProvider(groupId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (group == null) {
      return const Center(child: Text('Group not found'));
    }

    final currencyFormat = NumberFormat.currency(
      symbol: group.currency ?? '\$',
    );

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
          // Net Balances Section
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
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Net Balances',
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
                const SizedBox(height: 24),
                if (balances.isEmpty)
                  _buildEmptyState(isDark)
                else
                  ...balances.map((mb) {
                    return _buildBalanceCard(
                      isDark: isDark,
                      memberName: mb.member.name,
                      balance: mb.balance,
                      currency: group.currency ?? '\$',
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Detailed Breakdown per Person
          if (balances.any(
            (mb) => mb.balancesWith.values.any((b) => b.abs() > 0.01),
          )) ...[
            _buildCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.people_alt_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Detailed Breakdown',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? const Color(0xFFE5E7EB)
                                    : const Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              'Who owes whom',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? const Color(0xFF9CA3AF)
                                    : const Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...balances.map((mb) {
                    final owes = <String, double>{};
                    final owedBy = <String, double>{};

                    mb.balancesWith.forEach((otherId, balance) {
                      if (balance > 0.01) {
                        owedBy[otherId] = balance;
                      } else if (balance < -0.01) {
                        owes[otherId] = balance.abs();
                      }
                    });

                    if (owes.isEmpty && owedBy.isEmpty)
                      return const SizedBox.shrink();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1F2937)
                            : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF374151)
                              : const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2196F3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  mb.member.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? const Color(0xFFE5E7EB)
                                        : const Color(0xFF1F2937),
                                  ),
                                ),
                              ),
                              Text(
                                currencyFormat.format(mb.balance.abs()),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: mb.balance > 0.01
                                      ? const Color(0xFF10B981)
                                      : mb.balance < -0.01
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF6B7280),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          if (owedBy.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.arrow_downward_rounded,
                                      color: Color(0xFF10B981),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'To Receive:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF10B981),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ...owedBy.entries.map((entry) {
                                  final otherMember = balances
                                      .firstWhere(
                                        (b) => b.member.id == entry.key,
                                      )
                                      .member;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '• ${otherMember.name} owes',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark
                                                  ? const Color(0xFF9CA3AF)
                                                  : const Color(0xFF6B7280),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          currencyFormat.format(entry.value),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF10B981),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ],
                          if (owes.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.arrow_upward_rounded,
                                      color: Color(0xFFEF4444),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'To Pay:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFEF4444),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ...owes.entries.map((entry) {
                                  final otherMember = balances
                                      .firstWhere(
                                        (b) => b.member.id == entry.key,
                                      )
                                      .member;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '• Owes ${otherMember.name}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark
                                                  ? const Color(0xFF9CA3AF)
                                                  : const Color(0xFF6B7280),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          currencyFormat.format(entry.value),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFEF4444),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2196F3).withOpacity(0.2),
                    const Color(0xFF2196F3).withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 48,
                color: const Color(0xFF2196F3).withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No transactions yet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add expenses to see balances',
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

  Widget _buildBalanceCard({
    required bool isDark,
    required String memberName,
    required double balance,
    required String currency,
  }) {
    final isPositive = balance > 0.01;
    final isNegative = balance < -0.01;

    final color = isPositive
        ? const Color(0xFF10B981)
        : isNegative
        ? const Color(0xFFEF4444)
        : const Color(0xFF6B7280);

    final icon = isPositive
        ? Icons.trending_up_rounded
        : isNegative
        ? Icons.trending_down_rounded
        : Icons.check_circle_rounded;

    final statusText = isPositive
        ? 'To receive'
        : isNegative
        ? 'To pay'
        : 'Settled';

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First row: Icon + Member name
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
                  memberName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFE5E7EB)
                        : const Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Second row: Status + Amount
          Row(
            children: [
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$currency ${balance.abs().toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
