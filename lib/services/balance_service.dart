import '../models/member.dart';
import 'database_service.dart';

class MemberBalance {
  final Member member;
  final double
  balance; // Positive = others owe them, Negative = they owe others
  final Map<String, double> balancesWith; // memberId -> amount

  MemberBalance({
    required this.member,
    required this.balance,
    required this.balancesWith,
  });
}

class BalanceService {
  /// Calculate net balance for all members in a group
  static List<MemberBalance> calculateGroupBalances(String groupId) {
    final members = DatabaseService.getMembersByGroupId(groupId);
    final expenses = DatabaseService.getExpensesByGroupId(groupId);
    final payments = DatabaseService.getPaymentsByGroupId(groupId);

    // Initialize balances map: memberId -> Map<otherMemberId, amount>
    final Map<String, Map<String, double>> balances = {};
    for (final member in members) {
      balances[member.id] = {};
      for (final otherMember in members) {
        if (member.id != otherMember.id) {
          balances[member.id]![otherMember.id] = 0.0;
        }
      }
    }

    // Process expenses
    for (final expense in expenses) {
      final shares = DatabaseService.getExpenseSharesByExpenseId(expense.id);
      final payerId = expense.payerId;

      for (final share in shares) {
        final beneficiaryId = share.memberId;
        if (payerId != beneficiaryId) {
          // Beneficiary owes the payer
          // This means: payer's balance with beneficiary increases
          balances[payerId]![beneficiaryId] =
              (balances[payerId]![beneficiaryId] ?? 0.0) + share.shareAmount;
          // And beneficiary's balance with payer decreases
          balances[beneficiaryId]![payerId] =
              (balances[beneficiaryId]![payerId] ?? 0.0) - share.shareAmount;
        }
      }
    }

    // Process payments (direct transfers)
    for (final payment in payments) {
      final fromId = payment.fromId; // Person paying
      final toId = payment.toId; // Person receiving
      final amount = payment.amount;

      // From person's balance with To person increases (they paid them, reducing debt)
      balances[fromId]![toId] = (balances[fromId]![toId] ?? 0.0) + amount;
      // To person's balance with From person decreases (they received payment)
      balances[toId]![fromId] = (balances[toId]![fromId] ?? 0.0) - amount;
    }

    // Calculate total balance for each member
    final List<MemberBalance> memberBalances = [];
    for (final member in members) {
      final memberBalanceMap = balances[member.id] ?? {};
      final totalBalance = memberBalanceMap.values.fold<double>(
        0.0,
        (sum, value) => sum + value,
      );

      memberBalances.add(
        MemberBalance(
          member: member,
          balance: totalBalance,
          balancesWith: memberBalanceMap,
        ),
      );
    }

    return memberBalances;
  }

  /// Calculate balance between two specific members
  static double calculateBalanceBetween(
    String memberId1,
    String memberId2,
    String groupId,
  ) {
    final balances = calculateGroupBalances(groupId);
    final member1Balance = balances.firstWhere(
      (mb) => mb.member.id == memberId1,
      orElse: () => MemberBalance(
        member: Member(id: memberId1, name: '', groupId: groupId),
        balance: 0.0,
        balancesWith: {},
      ),
    );

    return member1Balance.balancesWith[memberId2] ?? 0.0;
  }

  /// Get simplified settlements (who should pay whom to settle all debts)
  static List<Settlement> getSimplifiedSettlements(String groupId) {
    final balances = calculateGroupBalances(groupId);

    // Create lists of creditors (positive balance) and debtors (negative balance)
    final creditors =
        balances
            .where((mb) => mb.balance > 0.01)
            .map((mb) => _BalanceItem(mb.member, mb.balance))
            .toList()
          ..sort((a, b) => b.amount.compareTo(a.amount));

    final debtors =
        balances
            .where((mb) => mb.balance < -0.01)
            .map((mb) => _BalanceItem(mb.member, -mb.balance))
            .toList()
          ..sort((a, b) => b.amount.compareTo(a.amount));

    final settlements = <Settlement>[];

    // Match creditors and debtors
    int i = 0, j = 0;
    while (i < creditors.length && j < debtors.length) {
      final creditor = creditors[i];
      final debtor = debtors[j];

      final amount = creditor.amount < debtor.amount
          ? creditor.amount
          : debtor.amount;

      if (amount > 0.01) {
        settlements.add(
          Settlement(from: debtor.member, to: creditor.member, amount: amount),
        );
      }

      creditor.amount -= amount;
      debtor.amount -= amount;

      if (creditor.amount < 0.01) i++;
      if (debtor.amount < 0.01) j++;
    }

    return settlements;
  }
}

class _BalanceItem {
  final Member member;
  double amount;

  _BalanceItem(this.member, this.amount);
}

class Settlement {
  final Member from;
  final Member to;
  final double amount;

  Settlement({required this.from, required this.to, required this.amount});
}
