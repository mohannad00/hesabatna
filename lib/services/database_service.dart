import 'package:hive_flutter/hive_flutter.dart';
import '../models/group.dart';
import '../models/member.dart';
import '../models/expense.dart';
import '../models/expense_share.dart';
import '../models/payment.dart';

class DatabaseService {
  static const String groupsBox = 'groups';
  static const String membersBox = 'members';
  static const String expensesBox = 'expenses';
  static const String expenseSharesBox = 'expense_shares';
  static const String paymentsBox = 'payments';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(GroupAdapter());
    Hive.registerAdapter(MemberAdapter());
    Hive.registerAdapter(ExpenseAdapter());
    Hive.registerAdapter(ExpenseShareAdapter());
    Hive.registerAdapter(PaymentAdapter());

    // Open boxes
    await Hive.openBox<Group>(groupsBox);
    await Hive.openBox<Member>(membersBox);
    await Hive.openBox<Expense>(expensesBox);
    await Hive.openBox<ExpenseShare>(expenseSharesBox);
    await Hive.openBox<Payment>(paymentsBox);
  }

  // Groups
  static Box<Group> get groupsBoxInstance => Hive.box<Group>(groupsBox);

  static Future<void> addGroup(Group group) async {
    await groupsBoxInstance.put(group.id, group);
  }

  static Future<void> updateGroup(Group group) async {
    await groupsBoxInstance.put(group.id, group);
  }

  static Future<void> deleteGroup(String groupId) async {
    // Delete all related data
    await deleteMembersByGroupId(groupId);
    await deleteExpensesByGroupId(groupId);
    await deletePaymentsByGroupId(groupId);
    await groupsBoxInstance.delete(groupId);
  }

  static List<Group> getAllGroups() {
    return groupsBoxInstance.values.toList()
      ..sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
  }

  static Group? getGroup(String id) {
    return groupsBoxInstance.get(id);
  }

  // Members
  static Box<Member> get membersBoxInstance => Hive.box<Member>(membersBox);

  static Future<void> addMember(Member member) async {
    await membersBoxInstance.put(member.id, member);
  }

  static Future<void> updateMember(Member member) async {
    await membersBoxInstance.put(member.id, member);
  }

  static Future<void> deleteMember(String memberId) async {
    // Note: In a production app, you might want to check if member has transactions
    await membersBoxInstance.delete(memberId);
  }

  static Future<void> deleteMembersByGroupId(String groupId) async {
    final members = getMembersByGroupId(groupId);
    for (final member in members) {
      await membersBoxInstance.delete(member.id);
    }
  }

  static List<Member> getMembersByGroupId(String groupId) {
    return membersBoxInstance.values
        .where((member) => member.groupId == groupId)
        .toList();
  }

  static Member? getMember(String id) {
    return membersBoxInstance.get(id);
  }

  // Expenses
  static Box<Expense> get expensesBoxInstance => Hive.box<Expense>(expensesBox);

  static Future<void> addExpense(Expense expense) async {
    await expensesBoxInstance.put(expense.id, expense);
  }

  static Future<void> updateExpense(Expense expense) async {
    await expensesBoxInstance.put(expense.id, expense);
  }

  static Future<void> deleteExpense(String expenseId) async {
    // Delete related expense shares
    await deleteExpenseSharesByExpenseId(expenseId);
    await expensesBoxInstance.delete(expenseId);
  }

  static Future<void> deleteExpensesByGroupId(String groupId) async {
    final expenses = getExpensesByGroupId(groupId);
    for (final expense in expenses) {
      await deleteExpense(expense.id);
    }
  }

  static List<Expense> getExpensesByGroupId(String groupId) {
    return expensesBoxInstance.values
        .where((expense) => expense.groupId == groupId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static List<Expense> getExpensesByPayerId(String payerId) {
    return expensesBoxInstance.values
        .where((expense) => expense.payerId == payerId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static Expense? getExpense(String id) {
    return expensesBoxInstance.get(id);
  }

  // Expense Shares
  static Box<ExpenseShare> get expenseSharesBoxInstance =>
      Hive.box<ExpenseShare>(expenseSharesBox);

  static Future<void> addExpenseShare(ExpenseShare share) async {
    await expenseSharesBoxInstance.put(share.id, share);
  }

  static Future<void> updateExpenseShare(ExpenseShare share) async {
    await expenseSharesBoxInstance.put(share.id, share);
  }

  static Future<void> deleteExpenseShare(String shareId) async {
    await expenseSharesBoxInstance.delete(shareId);
  }

  static Future<void> deleteExpenseSharesByExpenseId(String expenseId) async {
    final shares = getExpenseSharesByExpenseId(expenseId);
    for (final share in shares) {
      await expenseSharesBoxInstance.delete(share.id);
    }
  }

  static List<ExpenseShare> getExpenseSharesByExpenseId(String expenseId) {
    return expenseSharesBoxInstance.values
        .where((share) => share.expenseId == expenseId)
        .toList();
  }

  static List<ExpenseShare> getExpenseSharesByMemberId(String memberId) {
    return expenseSharesBoxInstance.values
        .where((share) => share.memberId == memberId)
        .toList();
  }

  // Payments
  static Box<Payment> get paymentsBoxInstance => Hive.box<Payment>(paymentsBox);

  static Future<void> addPayment(Payment payment) async {
    await paymentsBoxInstance.put(payment.id, payment);
  }

  static Future<void> updatePayment(Payment payment) async {
    await paymentsBoxInstance.put(payment.id, payment);
  }

  static Future<void> deletePayment(String paymentId) async {
    await paymentsBoxInstance.delete(paymentId);
  }

  static Future<void> deletePaymentsByGroupId(String groupId) async {
    final payments = getPaymentsByGroupId(groupId);
    for (final payment in payments) {
      await paymentsBoxInstance.delete(payment.id);
    }
  }

  static List<Payment> getPaymentsByGroupId(String groupId) {
    return paymentsBoxInstance.values
        .where((payment) => payment.groupId == groupId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static List<Payment> getPaymentsByMemberId(String memberId) {
    return paymentsBoxInstance.values
        .where(
          (payment) => payment.fromId == memberId || payment.toId == memberId,
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
