import 'package:hive/hive.dart';

part 'group.g.dart';

@HiveType(typeId: 0)
class Group extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late DateTime dateCreated;

  @HiveField(3)
  String? currency; // Optional: default currency for the group

  Group({
    required this.id,
    required this.name,
    required this.dateCreated,
    this.currency = 'USD',
  });

  Group copyWith({
    String? id,
    String? name,
    DateTime? dateCreated,
    String? currency,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      dateCreated: dateCreated ?? this.dateCreated,
      currency: currency ?? this.currency,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dateCreated': dateCreated.toIso8601String(),
      'currency': currency,
    };
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      dateCreated: DateTime.parse(json['dateCreated']),
      currency: json['currency'],
    );
  }
}
