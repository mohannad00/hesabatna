import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/groups_provider.dart';
import '../widgets/add_group_dialog.dart';
import '../services/export_service.dart';
import '../services/preferences_service.dart';
import '../models/group.dart';
import 'group_detail_screen.dart';

class GroupsListScreen extends ConsumerStatefulWidget {
  const GroupsListScreen({super.key});

  @override
  ConsumerState<GroupsListScreen> createState() => _GroupsListScreenState();
}

class _GroupsListScreenState extends ConsumerState<GroupsListScreen> {
  List<String> _pinnedGroups = [];
  List<String> _groupsOrder = [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() {
    setState(() {
      _pinnedGroups = PreferencesService.getPinnedGroups();
      _groupsOrder = PreferencesService.getGroupsOrder();
    });
  }

  List<Group> _getSortedGroups(List<Group> groups) {
    // Create a copy to avoid modifying the original list
    final sortedGroups = List<Group>.from(groups);

    // Sort by custom order if available
    if (_groupsOrder.isNotEmpty) {
      sortedGroups.sort((a, b) {
        final indexA = _groupsOrder.indexOf(a.id);
        final indexB = _groupsOrder.indexOf(b.id);
        // If not in order list, put at end
        final orderA = indexA == -1 ? 999 : indexA;
        final orderB = indexB == -1 ? 999 : indexB;
        return orderA.compareTo(orderB);
      });
    }

    // Then separate pinned and unpinned
    final pinned = sortedGroups.where((g) => _pinnedGroups.contains(g.id)).toList();
    final unpinned = sortedGroups.where((g) => !_pinnedGroups.contains(g.id)).toList();

    return [...pinned, ...unpinned];
  }

  void _onReorder(int oldIndex, int newIndex, List<Group> groups) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    setState(() {
      final item = groups.removeAt(oldIndex);
      groups.insert(newIndex, item);
      _groupsOrder = groups.map((g) => g.id).toList();
    });

    PreferencesService.setGroupsOrder(_groupsOrder);
  }

  void _togglePin(String groupId) {
    setState(() {
      if (_pinnedGroups.contains(groupId)) {
        _pinnedGroups.remove(groupId);
      } else {
        _pinnedGroups.add(groupId);
      }
    });
    PreferencesService.setPinnedGroups(_pinnedGroups);
  }

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(groupsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sortedGroups = _getSortedGroups(groups);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A1628) : const Color(0xFFF5F9FF),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0A1628), const Color(0xFF0D1B2A)]
                : [const Color(0xFFF5F9FF), Colors.white],
          ),
        ),
        child: groups.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6C63FF).withOpacity(0.1),
                            const Color(0xFFFF6584).withOpacity(0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.group_add_rounded,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No groups yet',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Create your first group to start\ntracking shared expenses',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF6B7280),
                          ),
                    ),
                  ],
                ),
              )
            : ReorderableListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: sortedGroups.length,
                onReorder: (oldIndex, newIndex) =>
                    _onReorder(oldIndex, newIndex, sortedGroups),
                buildDefaultDragHandles: false,
                physics: const BouncingScrollPhysics(),
                proxyDecorator: (child, index, animation) {
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      final scale = Tween<double>(begin: 1.0, end: 1.02)
                          .animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut,
                      ));
                      return Transform.scale(
                        scale: scale.value,
                        child: Material(
                          elevation: 8,
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          shadowColor: const Color(0xFF2196F3).withOpacity(0.3),
                          child: child,
                        ),
                      );
                    },
                    child: child,
                  );
                },
                itemBuilder: (context, index) {
                  final group = sortedGroups[index];
                  final isPinned = _pinnedGroups.contains(group.id);

                  return ReorderableDelayedDragStartListener(
                    key: ValueKey(group.id),
                    index: index,
                    child: _buildGroupItem(
                      context: context,
                      group: group,
                      isPinned: isPinned,
                      isDark: isDark,
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildGroupItem({
    required BuildContext context,
    required Group group,
    required bool isPinned,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0D1B2A),
                  const Color(0xFF1B263B).withOpacity(0.9),
                ]
              : [Colors.white, const Color(0xFFF8F9FE)],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : const Color(0xFF2196F3).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    GroupDetailScreen(groupId: group.id),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.1, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    ),
                  );
                },
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2196F3).withOpacity(0.2)
                    : Colors.white.withOpacity(0.6),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Group icon
                Hero(
                  tag: 'group_icon_${group.id}',
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2196F3).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.people_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Group info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isPinned) ...[
                            const Icon(
                              Icons.push_pin_rounded,
                              size: 14,
                              color: Color(0xFF2196F3),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              group.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? const Color(0xFFE5E7EB)
                                    : const Color(0xFF1E293B),
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${ref.watch(membersProvider(group.id)).length} members',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF2196F3).withOpacity(0.15),
                              const Color(0xFF1976D2).withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 10,
                              color: Color(0xFF2196F3),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('MMM dd, yyyy')
                                  .format(group.dateCreated),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF2196F3),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Menu button
                IconButton(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                  ),
                  onPressed: () {
                    _showGroupOptions(context, ref, group.id, group.name);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGroupOptions(
    BuildContext context,
    WidgetRef ref,
    String groupId,
    String groupName,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPinned = _pinnedGroups.contains(groupId);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1B263B), const Color(0xFF0D1B2A)]
                : [Colors.white, const Color(0xFFF8FBFF)],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: isDark
                ? const Color(0xFF2196F3).withOpacity(0.2)
                : const Color(0xFF2196F3).withOpacity(0.1),
            width: 1,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF475569)
                      : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Pin/Unpin Option
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPinned
                          ? [const Color(0xFF64748B), const Color(0xFF475569)]
                          : [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                title: Text(
                  isPinned ? 'Unpin Group' : 'Pin to Top',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFE5E7EB)
                        : const Color(0xFF1E293B),
                  ),
                ),
                subtitle: Text(
                  isPinned ? 'Remove from pinned groups' : 'Keep this group at the top',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF64748B),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _togglePin(groupId);
                },
              ),
              const SizedBox(height: 8),
              // Edit Option
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                title: Text(
                  'Edit Group',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFE5E7EB)
                        : const Color(0xFF1E293B),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => AddGroupDialog(
                      groupId: groupId,
                      initialName: groupName,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              // Export Option
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.file_upload_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                title: Text(
                  'Export Group',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFE5E7EB)
                        : const Color(0xFF1E293B),
                  ),
                ),
                subtitle: Text(
                  'Export as JSON file',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF64748B),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _exportGroup(context, groupId, groupName);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                title: const Text(
                  'Delete Group',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEF4444),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteGroup(context, ref, groupId, groupName);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteGroup(
    BuildContext context,
    WidgetRef ref,
    String groupId,
    String groupName,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1B263B) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isDark
                ? const Color(0xFF2196F3).withOpacity(0.2)
                : const Color(0xFF2196F3).withOpacity(0.1),
            width: 1,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Delete Group',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? const Color(0xFFE5E7EB)
                    : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "$groupName"? This will delete all expenses and payments associated with this group.',
          style: TextStyle(
            fontSize: 15,
            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(groupsProvider.notifier).deleteGroup(groupId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  void _exportGroup(
    BuildContext context,
    String groupId,
    String groupName,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1B263B), const Color(0xFF0D1B2A)]
                : [Colors.white, const Color(0xFFF8FBFF)],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: isDark
                ? const Color(0xFF10B981).withOpacity(0.2)
                : const Color(0xFF10B981).withOpacity(0.1),
            width: 1,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF475569)
                      : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.file_upload_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Export "$groupName"',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFFE5E7EB)
                                : const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Choose export method',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Copy to Clipboard Option
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.copy_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                title: Text(
                  'Copy to Clipboard',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFE5E7EB)
                        : const Color(0xFF1E293B),
                  ),
                ),
                subtitle: Text(
                  'Copy JSON data to paste elsewhere',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF64748B),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _copyToClipboard(context, groupId, groupName);
                },
              ),
              const SizedBox(height: 8),
              // Share as File Option
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.share_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                title: Text(
                  'Share as File',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFE5E7EB)
                        : const Color(0xFF1E293B),
                  ),
                ),
                subtitle: Text(
                  'Share or save as JSON file',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF64748B),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _shareAsFile(context, groupId, groupName);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _copyToClipboard(
    BuildContext context,
    String groupId,
    String groupName,
  ) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
      ),
    );

    try {
      final file = await ExportService.exportToJson(groupId);
      final jsonString = await file.readAsString();
      
      await Clipboard.setData(ClipboardData(text: jsonString));

      // Close loading
      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text('JSON copied to clipboard!'),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF3B82F6),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _shareAsFile(
    BuildContext context,
    String groupId,
    String groupName,
  ) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF10B981)),
      ),
    );

    try {
      await ExportService.shareJson(groupId);

      // Close loading
      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Group "$groupName" exported successfully'),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error exporting: $e')),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}
