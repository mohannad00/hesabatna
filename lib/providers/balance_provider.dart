import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/balance_service.dart';
import 'expenses_provider.dart';
import 'payments_provider.dart';

final balanceProvider = Provider.family<List<MemberBalance>, String>((
  ref,
  groupId,
) {
  // Watch expenses and payments to trigger recalculation when they change
  ref.watch(expensesProvider(groupId));
  ref.watch(paymentsProvider(groupId));

  return BalanceService.calculateGroupBalances(groupId);
});

final settlementsProvider = Provider.family<List<Settlement>, String>((
  ref,
  groupId,
) {
  // Watch expenses and payments to trigger recalculation when they change
  ref.watch(expensesProvider(groupId));
  ref.watch(paymentsProvider(groupId));

  return BalanceService.getSimplifiedSettlements(groupId);
});
