import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/groups_provider.dart';
import '../services/export_service.dart';
import '../widgets/add_member_dialog.dart';
import '../widgets/group_summary_tab.dart';
import '../widgets/group_transactions_tab.dart';
import '../widgets/member_detail_tab.dart';
import '../widgets/members_management_tab.dart';
import 'add_expense_screen.dart';
import 'add_payment_screen.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _toolbarAnimationController;
  late Animation<double> _toolbarAnimation;
  bool _animationInitialized = false;
  int _previousMemberCount = 0;
  bool _isToolbarVisible = true;
  double _lastScrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    final members = ref.read(membersProvider(widget.groupId));
    _previousMemberCount = members.length;
    // Summary + Transactions + Members Management + Individual Member tabs = 3 + member count
    _tabController = TabController(
      length: members.length + 3,
      vsync: this,
      animationDuration: const Duration(milliseconds: 150),
    );

    // Listen to tab changes to ensure proper state updates
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    // Initialize toolbar animation
    _toolbarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _toolbarAnimation = CurvedAnimation(
      parent: _toolbarAnimationController,
      curve: Curves.easeOut,
    );
    _animationInitialized = true;

    // Start with toolbar visible
    _toolbarAnimationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _toolbarAnimationController.dispose();
    super.dispose();
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (!_animationInitialized) return false;

    // Only handle notifications from the main TabBarView content, not from TabBar scrolling
    if (notification is ScrollUpdateNotification &&
        notification.depth == 0 &&
        notification.metrics.axis == Axis.vertical) {
      final difference = notification.metrics.pixels - _lastScrollOffset;

      // Facebook-like behavior: smooth response to scroll direction
      if (difference.abs() > 8) {
        // Slightly increased threshold for better UX
        if (difference > 0 && _isToolbarVisible) {
          // Scrolling down - hide toolbar
          _isToolbarVisible = false;
          _toolbarAnimationController.reverse();
        } else if (difference < 0 && !_isToolbarVisible) {
          // Scrolling up - show toolbar
          _isToolbarVisible = true;
          _toolbarAnimationController.forward();
        }
      }

      _lastScrollOffset = notification.metrics.pixels;
    }
    return false; // Allow the notification to continue
  }

  void _updateTabControllerIfNeeded(int memberCount) {
    if (_previousMemberCount != memberCount) {
      final oldIndex = _tabController.index;
      _tabController.dispose();
      // Summary + Transactions + Members Management + Individual Member tabs = 3 + member count
      _tabController = TabController(
        length: memberCount + 3,
        vsync: this,
        initialIndex: oldIndex < memberCount + 3 ? oldIndex : 0,
        animationDuration: const Duration(milliseconds: 150),
      );

      // Re-add the listener after recreating the controller
      _tabController.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });

      _previousMemberCount = memberCount;

      // Force a rebuild to update the UI
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = ref.watch(membersProvider(widget.groupId));
    final group = ref.watch(groupProvider(widget.groupId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    _updateTabControllerIfNeeded(members.length);

    if (group == null || group.id.isEmpty) {
      return Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF0A1628)
            : const Color(0xFFF5F9FF),
        appBar: AppBar(
          title: const Text('Group Not Found'),
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Group not found')),
      );
    }

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A1628)
          : const Color(0xFFF5F9FF),
      body: Column(
        children: [
          // Compact App Bar
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF1976D2), const Color(0xFF1565C0)]
                    : [const Color(0xFF2196F3), const Color(0xFF1E88E5)],
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.3)
                      : const Color(0xFF2196F3).withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // First Row - Group Name and Back Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              size: 22,
                            ),
                            onPressed: () => Navigator.pop(context),
                            color: Colors.white,
                            padding: const EdgeInsets.all(10),
                            constraints: const BoxConstraints(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                group.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${members.length} member${members.length != 1 ? 's' : ''}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.85),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Collapse/Expand Button
                        if (members.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: AnimatedRotation(
                                turns: _isToolbarVisible ? 0.0 : 0.5,
                                duration: const Duration(milliseconds: 200),
                                child: const Icon(
                                  Icons.keyboard_arrow_up_rounded,
                                  size: 22,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isToolbarVisible = !_isToolbarVisible;
                                  if (_isToolbarVisible) {
                                    _toolbarAnimationController.forward();
                                  } else {
                                    _toolbarAnimationController.reverse();
                                  }
                                });
                              },
                              color: Colors.white,
                              padding: const EdgeInsets.all(10),
                              constraints: const BoxConstraints(),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Second Row - Action Icons (Show/Hide based on scroll)
                  if (members.isNotEmpty && _animationInitialized)
                    SizeTransition(
                      sizeFactor: _toolbarAnimation,
                      axisAlignment: -1.0,
                      child: Container(
                        height: 90,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                              icon: Icons.add_rounded,
                              label: 'Expense',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddExpenseScreen(
                                      groupId: widget.groupId,
                                    ),
                                  ),
                                );
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.payment,
                              label: 'Payment',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddPaymentScreen(
                                      groupId: widget.groupId,
                                    ),
                                  ),
                                );
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.file_download_outlined,
                              label: 'Export',
                              onPressed: () => _exportGroup(context),
                            ),
                            _buildActionButton(
                              icon: Icons.person_add_rounded,
                              label: 'Member',
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) =>
                                      AddMemberDialog(groupId: widget.groupId),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Tab Bar
                  if (members.isNotEmpty)
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          indicatorPadding: const EdgeInsets.all(3),
                          labelPadding: const EdgeInsets.only(
                            left: 0,
                            right: 2,
                          ),
                          dividerColor: Colors.transparent,
                          labelColor: const Color(0xFF1E293B),
                          unselectedLabelColor: Colors.white.withOpacity(0.9),
                          labelStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          tabs: [
                            // Summary Tab
                            _buildTabItem(
                              Icons.dashboard_rounded,
                              'Summary',
                              0,
                            ),
                            // Transactions Tab
                            _buildTabItem(
                              Icons.receipt_long_rounded,
                              'Transactions',
                              1,
                            ),
                            // Members Management Tab
                            _buildTabItem(Icons.people_rounded, 'Members', 2),
                            // Individual Member Tabs
                            ...members.asMap().entries.map(
                              (entry) => _buildTabItem(
                                Icons.person_rounded,
                                entry.value.name,
                                entry.key + 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          // Tab Content
          Expanded(
            child: members.isEmpty
                ? _buildEmptyState(context, isDark)
                : Directionality(
                    textDirection: TextDirection.ltr,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: _onScrollNotification,
                      child: TabBarView(
                        controller: _tabController,
                        physics: const ClampingScrollPhysics(),
                        children: [
                          GroupSummaryTab(groupId: widget.groupId),
                          GroupTransactionsTab(groupId: widget.groupId),
                          MembersManagementTab(groupId: widget.groupId),
                          ...members.map(
                            (member) => MemberDetailTab(
                              groupId: widget.groupId,
                              memberId: member.id,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(IconData icon, String label, int index) {
    return Tab(
      child: Container(
        padding: EdgeInsets.only(
          left: index == 0 ? 4 : 16, // Less left padding for first tab
          right: 16,
          top: 10,
          bottom: 10,
        ),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: const Color(0xFF2196F3)),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.group_rounded,
                size: 64,
                color: isDark
                    ? Colors.white.withOpacity(0.3)
                    : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Members Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? const Color(0xFFE5E7EB)
                    : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add members to start tracking expenses',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) =>
                      AddMemberDialog(groupId: widget.groupId),
                );
              },
              icon: const Icon(Icons.person_add_rounded),
              label: const Text('Add First Member'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exportGroup(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;

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
                ? const Color(0xFF3B82F6).withOpacity(0.2)
                : const Color(0xFF3B82F6).withOpacity(0.1),
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
                          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Export PDF',
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
                          'Choose export option',
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
              // Share Option
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
                  'Share',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFE5E7EB)
                        : const Color(0xFF1E293B),
                  ),
                ),
                subtitle: Text(
                  'Share PDF via apps',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF64748B),
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await ExportService.sharePdf(
                      widget.groupId,
                      locale: locale,
                    );
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Export failed: $e'),
                          backgroundColor: const Color(0xFFEF4444),
                        ),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 8),
              // Print Option
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.print_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                title: Text(
                  'Print',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFE5E7EB)
                        : const Color(0xFF1E293B),
                  ),
                ),
                subtitle: Text(
                  'Print or save as PDF',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF64748B),
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await ExportService.printPdf(
                      widget.groupId,
                      locale: locale,
                    );
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Print failed: $e'),
                          backgroundColor: const Color(0xFFEF4444),
                        ),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: Colors.white),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
