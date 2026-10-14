import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../models/expense_share.dart';
import '../services/database_service.dart';

final expensesProvider =
    StateNotifierProvider.family<ExpensesNotifier, List<Expense>, String>(
      (ref, groupId) => ExpensesNotifier(groupId),
    );

class ExpensesNotifier extends StateNotifier<List<Expense>> {
  final String groupId;

  ExpensesNotifier(this.groupId) : super([]) {
    loadExpenses();
  }

  void loadExpenses() {
    state = DatabaseService.getExpensesByGroupId(groupId);
  }

  Future<void> addExpense({
    required String description,
    required double amount,
    required String payerId,
    required List<String> beneficiaryIds,
    required SplitMethod splitMethod,
    Map<String, double>? customShares, // For custom split
    DateTime? date,
    String? notes,
  }) async {
    final expense = Expense(
      id: const Uuid().v4(),
      description: description,
      amount: amount,
      payerId: payerId,
      groupId: groupId,
      date: date ?? DateTime.now(),
      notes: notes,
      splitMethod: splitMethod,
    );

    await DatabaseService.addExpense(expense);

    // Create expense shares
    if (splitMethod == SplitMethod.equal) {
      // Equal split
      final shareAmount = amount / beneficiaryIds.length;
      for (final beneficiaryId in beneficiaryIds) {
        final share = ExpenseShare(
          id: const Uuid().v4(),
          expenseId: expense.id,
          memberId: beneficiaryId,
          shareAmount: shareAmount,
        );
        await DatabaseService.addExpenseShare(share);
      }
    } else {
      // Custom split
      if (customShares != null) {
        for (final entry in customShares.entries) {
          if (entry.value > 0) {
            final share = ExpenseShare(
              id: const Uuid().v4(),
              expenseId: expense.id,
              memberId: entry.key,
              shareAmount: entry.value,
            );
            await DatabaseService.addExpenseShare(share);
          }
        }
      }
    }

    loadExpenses();
  }

  Future<void> updateExpense({
    required String expenseId,
    required String description,
    required double amount,
    required String payerId,
    required List<String> beneficiaryIds,
    required SplitMethod splitMethod,
    Map<String, double>? customShares,
    DateTime? date,
    String? notes,
  }) async {
    final existingExpense = DatabaseService.getExpense(expenseId);
    if (existingExpense == null) return;

    final updatedExpense = existingExpense.copyWith(
      description: description,
      amount: amount,
      payerId: payerId,
      date: date,
      notes: notes,
      splitMethod: splitMethod,
    );

    await DatabaseService.updateExpense(updatedExpense);

    // Delete old shares and create new ones
    await DatabaseService.deleteExpenseSharesByExpenseId(expenseId);

    if (splitMethod == SplitMethod.equal) {
      final shareAmount = amount / beneficiaryIds.length;
      for (final beneficiaryId in beneficiaryIds) {
        final share = ExpenseShare(
          id: const Uuid().v4(),
          expenseId: expenseId,
          memberId: beneficiaryId,
          shareAmount: shareAmount,
        );
        await DatabaseService.addExpenseShare(share);
      }
    } else {
      if (customShares != null) {
        for (final entry in customShares.entries) {
          if (entry.value > 0) {
            final share = ExpenseShare(
              id: const Uuid().v4(),
              expenseId: expenseId,
              memberId: entry.key,
              shareAmount: entry.value,
            );
            await DatabaseService.addExpenseShare(share);
          }
        }
      }
    }

    loadExpenses();
  }

  Future<void> deleteExpense(String expenseId) async {
    await DatabaseService.deleteExpense(expenseId);
    loadExpenses();
  }
}

// Provider for expense shares
final expenseSharesProvider = Provider.family<List<ExpenseShare>, String>((
  ref,
  expenseId,
) {
  return DatabaseService.getExpenseSharesByExpenseId(expenseId);
});
