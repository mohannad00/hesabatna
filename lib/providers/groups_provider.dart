import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/group.dart';
import '../models/member.dart';
import '../services/database_service.dart';

final groupsProvider = StateNotifierProvider<GroupsNotifier, List<Group>>((
  ref,
) {
  return GroupsNotifier();
});

class GroupsNotifier extends StateNotifier<List<Group>> {
  GroupsNotifier() : super([]) {
    loadGroups();
  }

  void loadGroups() {
    state = DatabaseService.getAllGroups();
  }

  Future<void> addGroup(String name, {String? currency}) async {
    final group = Group(
      id: const Uuid().v4(),
      name: name,
      dateCreated: DateTime.now(),
      currency: currency ?? 'USD',
    );
    await DatabaseService.addGroup(group);
    loadGroups();
  }

  Future<void> updateGroup(Group group) async {
    await DatabaseService.updateGroup(group);
    loadGroups();
  }

  Future<void> deleteGroup(String groupId) async {
    await DatabaseService.deleteGroup(groupId);
    loadGroups();
  }
}

// Provider for a specific group
final groupProvider = Provider.family<Group?, String>((ref, groupId) {
  final groups = ref.watch(groupsProvider);
  try {
    return groups.firstWhere((g) => g.id == groupId);
  } catch (e) {
    return null;
  }
});

// Provider for members of a specific group
final membersProvider =
    StateNotifierProvider.family<MembersNotifier, List<Member>, String>(
      (ref, groupId) => MembersNotifier(groupId),
    );

class MembersNotifier extends StateNotifier<List<Member>> {
  final String groupId;

  MembersNotifier(this.groupId) : super([]) {
    loadMembers();
  }

  void loadMembers() {
    state = DatabaseService.getMembersByGroupId(groupId);
  }

  Future<void> addMember(String name) async {
    try {
      final member = Member(
        id: const Uuid().v4(),
        name: name,
        groupId: groupId,
      );
      await DatabaseService.addMember(member);
      loadMembers();
    } catch (e) {
      // In a production app, you might want to show an error to the user
      print('Error adding member: $e');
      rethrow;
    }
  }

  Future<void> updateMember(Member member) async {
    try {
      await DatabaseService.updateMember(member);
      loadMembers();
    } catch (e) {
      print('Error updating member: $e');
      rethrow;
    }
  }

  Future<void> deleteMember(String memberId) async {
    try {
      await DatabaseService.deleteMember(memberId);
      loadMembers();
    } catch (e) {
      print('Error deleting member: $e');
      rethrow;
    }
  }
}
