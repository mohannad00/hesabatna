import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/payment.dart';
import '../services/database_service.dart';

final paymentsProvider =
    StateNotifierProvider.family<PaymentsNotifier, List<Payment>, String>(
      (ref, groupId) => PaymentsNotifier(groupId),
    );

class PaymentsNotifier extends StateNotifier<List<Payment>> {
  final String groupId;

  PaymentsNotifier(this.groupId) : super([]) {
    loadPayments();
  }

  void loadPayments() {
    state = DatabaseService.getPaymentsByGroupId(groupId);
  }

  Future<void> addPayment({
    required String fromId,
    required String toId,
    required double amount,
    DateTime? date,
    String? notes,
  }) async {
    final payment = Payment(
      id: const Uuid().v4(),
      fromId: fromId,
      toId: toId,
      amount: amount,
      groupId: groupId,
      date: date ?? DateTime.now(),
      notes: notes,
    );

    await DatabaseService.addPayment(payment);
    loadPayments();
  }

  Future<void> updatePayment(Payment payment) async {
    await DatabaseService.updatePayment(payment);
    loadPayments();
  }

  Future<void> deletePayment(String paymentId) async {
    await DatabaseService.deletePayment(paymentId);
    loadPayments();
  }
}
