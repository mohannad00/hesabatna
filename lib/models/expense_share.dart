import 'package:hive/hive.dart';

part 'expense_share.g.dart';

@HiveType(typeId: 3)
class ExpenseShare extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String expenseId;

  @HiveField(2)
  late String memberId; // Beneficiary

  @HiveField(3)
  late double shareAmount; // How much this member owes for this expense

  ExpenseShare({
    required this.id,
    required this.expenseId,
    required this.memberId,
    required this.shareAmount,
  });

  ExpenseShare copyWith({
    String? id,
    String? expenseId,
    String? memberId,
    double? shareAmount,
  }) {
    return ExpenseShare(
      id: id ?? this.id,
      expenseId: expenseId ?? this.expenseId,
      memberId: memberId ?? this.memberId,
      shareAmount: shareAmount ?? this.shareAmount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expenseId': expenseId,
      'memberId': memberId,
      'shareAmount': shareAmount,
    };
  }

  factory ExpenseShare.fromJson(Map<String, dynamic> json) {
    return ExpenseShare(
      id: json['id'],
      expenseId: json['expenseId'],
      memberId: json['memberId'],
      shareAmount: json['shareAmount'],
    );
  }
}
