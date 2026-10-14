import 'package:hive/hive.dart';

part 'member.g.dart';

@HiveType(typeId: 1)
class Member extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String groupId;

  Member({required this.id, required this.name, required this.groupId});

  Member copyWith({String? id, String? name, String? groupId}) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      groupId: groupId ?? this.groupId,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'groupId': groupId};
  }

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(id: json['id'], name: json['name'], groupId: json['groupId']);
  }
}
