import 'package:hive/hive.dart';

part 'expense.g.dart';

enum SplitMethod { equal, custom }

@HiveType(typeId: 2)
class Expense extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String description;

  @HiveField(2)
  late double amount;

  @HiveField(3)
  late String payerId; // Member who paid

  @HiveField(4)
  late String groupId;

  @HiveField(5)
  late DateTime date;

  @HiveField(6)
  String? notes;

  @HiveField(7)
  late int splitMethodIndex; // 0 = equal, 1 = custom

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.payerId,
    required this.groupId,
    required this.date,
    this.notes,
    SplitMethod splitMethod = SplitMethod.equal,
  }) : splitMethodIndex = splitMethod.index;

  SplitMethod get splitMethod => SplitMethod.values[splitMethodIndex];

  set splitMethod(SplitMethod method) {
    splitMethodIndex = method.index;
  }

  Expense copyWith({
    String? id,
    String? description,
    double? amount,
    String? payerId,
    String? groupId,
    DateTime? date,
    String? notes,
    SplitMethod? splitMethod,
  }) {
    return Expense(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      payerId: payerId ?? this.payerId,
      groupId: groupId ?? this.groupId,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      splitMethod: splitMethod ?? this.splitMethod,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'payerId': payerId,
      'groupId': groupId,
      'date': date.toIso8601String(),
      'notes': notes,
      'splitMethod': splitMethod.name,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      description: json['description'],
      amount: json['amount'],
      payerId: json['payerId'],
      groupId: json['groupId'],
      date: DateTime.parse(json['date']),
      notes: json['notes'],
      splitMethod: SplitMethod.values.firstWhere(
        (e) => e.name == json['splitMethod'],
        orElse: () => SplitMethod.equal,
      ),
    );
  }
}
