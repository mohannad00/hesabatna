import 'package:hive/hive.dart';

part 'payment.g.dart';

@HiveType(typeId: 4)
class Payment extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String fromId; // Member who is paying (settling debt)

  @HiveField(2)
  late String toId; // Member who is receiving

  @HiveField(3)
  late double amount;

  @HiveField(4)
  late String groupId;

  @HiveField(5)
  late DateTime date;

  @HiveField(6)
  String? notes;

  Payment({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.amount,
    required this.groupId,
    required this.date,
    this.notes,
  });

  Payment copyWith({
    String? id,
    String? fromId,
    String? toId,
    double? amount,
    String? groupId,
    DateTime? date,
    String? notes,
  }) {
    return Payment(
      id: id ?? this.id,
      fromId: fromId ?? this.fromId,
      toId: toId ?? this.toId,
      amount: amount ?? this.amount,
      groupId: groupId ?? this.groupId,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromId': fromId,
      'toId': toId,
      'amount': amount,
      'groupId': groupId,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      fromId: json['fromId'],
      toId: json['toId'],
      amount: json['amount'],
      groupId: json['groupId'],
      date: DateTime.parse(json['date']),
      notes: json['notes'],
    );
  }
}
