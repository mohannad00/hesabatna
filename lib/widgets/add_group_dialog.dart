import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/groups_provider.dart';
import '../services/database_service.dart';

class AddGroupDialog extends ConsumerStatefulWidget {
  final String? groupId;
  final String? initialName;

  const AddGroupDialog({super.key, this.groupId, this.initialName});

  @override
  ConsumerState<AddGroupDialog> createState() => _AddGroupDialogState();
}

class _AddGroupDialogState extends ConsumerState<AddGroupDialog> {
  late TextEditingController _nameController;
  String _selectedCurrency = 'USD';
  final List<String> _currencies = ['EGP', 'USD', 'EUR'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');

    if (widget.groupId != null) {
      final group = DatabaseService.getGroup(widget.groupId!);
      _selectedCurrency = group?.currency ?? 'USD';
      if (!_currencies.contains(_selectedCurrency)) {
        _selectedCurrency = 'USD';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'EGP':
        return 'E£';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      default:
        return currency;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.groupId != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [const Color(0xFF1B263B), const Color(0xFF0D1B2A)]
                    : [Colors.white, const Color(0xFFF8FBFF)],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2196F3).withOpacity(0.2)
                    : const Color(0xFF2196F3).withOpacity(0.1),
                width: 1,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                controller: scrollController,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isEditing
                                  ? Icons.edit_rounded
                                  : Icons.add_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isEditing ? 'Edit Group' : 'New Group',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFFE5E7EB)
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF0D1B2A)
                                  : const Color(0xFFF5F9FF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF2196F3).withOpacity(0.2)
                                    : const Color(0xFF2196F3).withOpacity(0.1),
                                width: 1.5,
                              ),
                            ),
                            child: TextField(
                              controller: _nameController,
                              autofocus: true,
                              textCapitalization: TextCapitalization.words,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? const Color(0xFFE5E7EB)
                                    : const Color(0xFF1E293B),
                              ),
                              decoration: InputDecoration(
                                labelText: 'Group Name',
                                hintText: 'e.g., Trip to Dubai',
                                labelStyle: TextStyle(
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                ),
                                hintStyle: TextStyle(
                                  color: isDark
                                      ? const Color(0xFF475569)
                                      : const Color(0xFFCBD5E1),
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(12),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF2196F3),
                                        Color(0xFF1976D2),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.group_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 4,
                                  bottom: 8,
                                ),
                                child: Text(
                                  'Currency',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              Row(
                                children: _currencies.map((currency) {
                                  final isSelected =
                                      _selectedCurrency == currency;
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _selectedCurrency = currency;
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                            horizontal: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: isSelected
                                                ? const LinearGradient(
                                                    colors: [
                                                      Color(0xFF2196F3),
                                                      Color(0xFF1976D2),
                                                    ],
                                                  )
                                                : null,
                                            color: isSelected
                                                ? null
                                                : isDark
                                                ? const Color(0xFF0D1B2A)
                                                : const Color(0xFFF5F9FF),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFF2196F3)
                                                  : isDark
                                                  ? const Color(
                                                      0xFF2196F3,
                                                    ).withOpacity(0.2)
                                                  : const Color(
                                                      0xFF2196F3,
                                                    ).withOpacity(0.1),
                                              width: isSelected ? 2 : 1.5,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                _getCurrencySymbol(currency),
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : const Color(0xFF2196F3),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                currency,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : isDark
                                                      ? const Color(0xFF94A3B8)
                                                      : const Color(0xFF64748B),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                // Dismiss keyboard first
                                FocusScope.of(context).unfocus();
                                Future.delayed(
                                  const Duration(milliseconds: 100),
                                  () {
                                    if (context.mounted) Navigator.pop(context);
                                  },
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
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
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () async {
                                final name = _nameController.text.trim();

                                if (name.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Please enter a group name',
                                      ),
                                      backgroundColor: const Color(0xFFEF4444),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                // Dismiss keyboard first
                                FocusScope.of(context).unfocus();
                                await Future.delayed(
                                  const Duration(milliseconds: 100),
                                );

                                if (isEditing) {
                                  final group = DatabaseService.getGroup(
                                    widget.groupId!,
                                  );
                                  if (group != null) {
                                    ref
                                        .read(groupsProvider.notifier)
                                        .updateGroup(
                                          group.copyWith(
                                            name: name,
                                            currency: _selectedCurrency,
                                          ),
                                        );
                                  }
                                } else {
                                  ref
                                      .read(groupsProvider.notifier)
                                      .addGroup(
                                        name,
                                        currency: _selectedCurrency,
                                      );
                                }

                                if (context.mounted) Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2196F3),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                isEditing ? 'Save Changes' : 'Create Group',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
