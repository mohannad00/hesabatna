import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../providers/groups_provider.dart';
import '../providers/expenses_provider.dart';
import '../services/database_service.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final String groupId;
  final String? expenseId;

  const AddExpenseScreen({super.key, required this.groupId, this.expenseId});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedPayerId;
  DateTime _selectedDate = DateTime.now();
  SplitMethod _splitMethod = SplitMethod.equal;
  Set<String> _selectedBeneficiaries = {};
  Map<String, TextEditingController> _customShareControllers = {};
  bool _isInitialized = false;
  final FocusNode _descriptionFocusNode = FocusNode();

  /// Built-in suggestions in English
  static const List<String> _defaultSuggestionsEnglish = [
    // Food & Dining
    'Food',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snacks',
    'Restaurant',
    'Fast Food',
    'Shawarma',
    'Pizza',
    'Burger',
    'Sandwich',
    'Falafel',
    'Koshary',
    'Grilled Chicken',
    'Meat',
    'Fish',
    'Eggs',
    'Bread',
    'Vegetables',
    'Fruits',
    'Groceries',
    'Supermarket',
    
    // Drinks
    'Coffee',
    'Tea',
    'Juice',
    'Water',
    'Soft Drinks',
    'Cafe',
    
    // Transportation
    'Uber',
    'Taxi',
    'Careem',
    'Bus',
    'Metro',
    'Fuel',
    'Gas',
    'Petrol',
    'Parking',
    'Car Wash',
    'Car Service',
    
    // Shopping
    'Shopping',
    'Clothes',
    'Shoes',
    'Electronics',
    'Phone',
    'Accessories',
    'Gifts',
    
    // Bills & Utilities
    'Electricity',
    'Water Bill',
    'Gas Bill',
    'Internet',
    'Phone Bill',
    'Rent',
    
    // Entertainment
    'Cinema',
    'Movies',
    'Games',
    'Entertainment',
    'Subscription',
    'Netflix',
    'Spotify',
    
    // Health & Personal
    'Medicine',
    'Pharmacy',
    'Doctor',
    'Gym',
    'Haircut',
    'Personal Care',
    
    // Home
    'Home Supplies',
    'Cleaning',
    'Furniture',
    'Repairs',
    
    // Others
    'Travel',
    'Hotel',
    'Flight',
    'Tickets',
    'Education',
    'Books',
    'Office Supplies',
    'Tips',
    'Charity',
    'Other',
  ];

  /// Built-in suggestions in Arabic
  static const List<String> _defaultSuggestionsArabic = [
    // طعام وشراب
    'أكل',
    'فطار',
    'غداء',
    'عشاء',
    'سناكس',
    'مطعم',
    'وجبات سريعة',
    'شاورما',
    'بيتزا',
    'برجر',
    'ساندويتش',
    'فلافل',
    'كشري',
    'فراخ مشوية',
    'لحمة',
    'سمك',
    'بيض',
    'عيش',
    'خضار',
    'فاكهة',
    'بقالة',
    'سوبر ماركت',
    'خضري',
    
    // مشروبات
    'قهوة',
    'شاي',
    'عصير',
    'مياه',
    'مشروبات غازية',
    'كافيه',
    'نسكافيه',
    
    // مواصلات
    'أوبر',
    'تاكسي',
    'كريم',
    'أتوبيس',
    'مترو',
    'بنزين',
    'وقود',
    'موقف',
    'غسيل عربية',
    'صيانة عربية',
    
    // تسوق
    'تسوق',
    'هدوم',
    'جزم',
    'إلكترونيات',
    'موبايل',
    'إكسسوارات',
    'هدايا',
    
    // فواتير
    'كهرباء',
    'مياه',
    'غاز',
    'نت',
    'إنترنت',
    'فاتورة تليفون',
    'إيجار',
    
    // ترفيه
    'سينما',
    'أفلام',
    'ألعاب',
    'ترفيه',
    'اشتراك',
    'نتفلكس',
    
    // صحة
    'دوا',
    'صيدلية',
    'دكتور',
    'جيم',
    'حلاق',
    
    // منزل
    'مستلزمات منزلية',
    'تنظيف',
    'أثاث',
    'صيانة',
    
    // أخرى
    'سفر',
    'فندق',
    'طيران',
    'تذاكر',
    'تعليم',
    'كتب',
    'مكتبة',
    'بقشيش',
    'صدقة',
    'أخرى',
  ];

  /// Get all unique expense descriptions for autocomplete suggestions
  List<String> _getDescriptionSuggestions() {
    final Set<String> descriptions = {};
    
    // Add built-in suggestions (both languages)
    descriptions.addAll(_defaultSuggestionsEnglish);
    descriptions.addAll(_defaultSuggestionsArabic);
    
    // Add user's actual expense history from all groups
    final allGroups = DatabaseService.getAllGroups();
    for (final group in allGroups) {
      final expenses = DatabaseService.getExpensesByGroupId(group.id);
      for (final expense in expenses) {
        if (expense.description.trim().isNotEmpty) {
          descriptions.add(expense.description.trim());
        }
      }
    }
    
    return descriptions.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  @override
  void dispose() {
    _descriptionFocusNode.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    for (final controller in _customShareControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _loadExistingData() {
    if (_isInitialized || widget.expenseId == null) return;

    final expenses = ref.read(expensesProvider(widget.groupId));
    try {
      final existingExpense = expenses.firstWhere(
        (e) => e.id == widget.expenseId,
      );

      setState(() {
        _descriptionController.text = existingExpense.description;
        _amountController.text = existingExpense.amount.toString();
        _notesController.text = existingExpense.notes ?? '';
        _selectedPayerId = existingExpense.payerId;
        _selectedDate = existingExpense.date;
        _splitMethod = existingExpense.splitMethod;

        // Load beneficiaries from existing expense shares
        final shares = ref.read(expenseSharesProvider(widget.expenseId!));
        _selectedBeneficiaries = shares.map((s) => s.memberId).toSet();

        // Load custom shares if using custom split method
        if (_splitMethod == SplitMethod.custom) {
          for (final share in shares) {
            _customShareControllers[share.memberId] ??= TextEditingController();
            _customShareControllers[share.memberId]!.text = share.shareAmount
                .toString();
          }
        }

        _isInitialized = true;
      });
    } catch (e) {
      // Expense not found yet
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = ref.watch(membersProvider(widget.groupId));
    final group = ref.watch(groupProvider(widget.groupId));
    final expenses = ref.watch(expensesProvider(widget.groupId));
    final isEditing = widget.expenseId != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Load existing data after first frame if editing
    if (isEditing && !_isInitialized && expenses.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingData();
      });
    }

    if (group == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
        body: const Center(child: Text('Group not found')),
      );
    }

    if (!isEditing && _selectedPayerId == null && members.isNotEmpty) {
      _selectedPayerId = members.first.id;
    }

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0E27)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1B263B), const Color(0xFF0D1B2A)]
                  : [const Color(0xFF2196F3), const Color(0xFF1976D2)],
            ),
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(isDark ? 0.1 : 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Expense' : 'Add Expense',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: members.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline_rounded,
                    size: 80,
                    color: isDark
                        ? Colors.white.withOpacity(0.3)
                        : Colors.black.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No members available',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDark
                          ? Colors.white.withOpacity(0.6)
                          : Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Description with Autocomplete
                  _buildDescriptionAutocomplete(isDark),
                  const SizedBox(height: 20),

                  // Amount
                  _buildModernTextField(
                    controller: _amountController,
                    label: 'Amount',
                    hint: '0.00',
                    icon: Icons.payments_rounded,
                    isDark: isDark,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    suffix: Text(
                      group.currency ?? 'USD',
                      style: TextStyle(
                        color: const Color(0xFF2196F3),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter an amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Payer
                  _buildModernDropdown(
                    value: _selectedPayerId,
                    label: 'Paid by',
                    icon: Icons.person_rounded,
                    isDark: isDark,
                    items: members.map((member) {
                      return DropdownMenuItem(
                        value: member.id,
                        child: Text(member.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPayerId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Date
                  _buildDateSelector(context, isDark),
                  const SizedBox(height: 24),

                  // Split Method
                  _buildSectionHeader('Split Method', isDark),
                  const SizedBox(height: 12),
                  _buildSplitMethodSelector(isDark),
                  const SizedBox(height: 24),

                  // Beneficiaries
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionHeader(
                        'Split between',
                        isDark,
                        showMargin: false,
                      ),
                      if (_splitMethod == SplitMethod.equal)
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF2196F3).withOpacity(0.1),
                                const Color(0xFF1976D2).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                if (_selectedBeneficiaries.length ==
                                    members.length) {
                                  _selectedBeneficiaries.clear();
                                } else {
                                  _selectedBeneficiaries = members
                                      .map((m) => m.id)
                                      .toSet();
                                }
                              });
                            },
                            icon: Icon(
                              _selectedBeneficiaries.length == members.length
                                  ? Icons.deselect_rounded
                                  : Icons.select_all_rounded,
                              size: 18,
                              color: const Color(0xFF2196F3),
                            ),
                            label: Text(
                              _selectedBeneficiaries.length == members.length
                                  ? 'Deselect All'
                                  : 'Select All',
                              style: const TextStyle(
                                color: Color(0xFF2196F3),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildBeneficiariesList(members, group, isDark),
                  const SizedBox(height: 24),

                  // Notes
                  _buildModernTextField(
                    controller: _notesController,
                    label: 'Notes (Optional)',
                    hint: 'Add any additional details',
                    icon: Icons.note_rounded,
                    isDark: isDark,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  _buildSubmitButton(isEditing, isDark),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    Widget? suffix,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1B263B).withOpacity(0.6),
                  const Color(0xFF0D1B2A).withOpacity(0.6),
                ]
              : [Colors.white, const Color(0xFFFAFBFF)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2196F3).withOpacity(0.2)
              : const Color(0xFF2196F3).withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : const Color(0xFF2196F3).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1E293B),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          suffix: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          errorStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 12),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDescriptionAutocomplete(bool isDark) {
    final suggestions = _getDescriptionSuggestions();
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1B263B).withOpacity(0.6),
                  const Color(0xFF0D1B2A).withOpacity(0.6),
                ]
              : [Colors.white, const Color(0xFFFAFBFF)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2196F3).withOpacity(0.2)
              : const Color(0xFF2196F3).withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : const Color(0xFF2196F3).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return const Iterable<String>.empty();
          }
          return suggestions.where((String option) {
            return option.toLowerCase().contains(
              textEditingValue.text.toLowerCase(),
            );
          }).take(5); // Limit to 5 suggestions
        },
        onSelected: (String selection) {
          _descriptionController.text = selection;
        },
        fieldViewBuilder: (
          BuildContext context,
          TextEditingController fieldController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted,
        ) {
          // Sync the controllers
          if (_descriptionController.text.isNotEmpty && 
              fieldController.text.isEmpty) {
            fieldController.text = _descriptionController.text;
          }
          
          // Listen to changes and sync back
          fieldController.addListener(() {
            if (_descriptionController.text != fieldController.text) {
              _descriptionController.text = fieldController.text;
            }
          });

          return TextFormField(
            controller: fieldController,
            focusNode: focusNode,
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'e.g., Dinner at restaurant',
              labelStyle: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
              hintStyle: TextStyle(
                color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.description_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              suffixIcon: suggestions.isNotEmpty
                  ? Icon(
                      Icons.auto_awesome_rounded,
                      color: isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
                      size: 18,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              errorStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 12),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
            onFieldSubmitted: (String value) {
              onFieldSubmitted();
            },
          );
        },
        optionsViewBuilder: (
          BuildContext context,
          AutocompleteOnSelected<String> onSelected,
          Iterable<String> options,
        ) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 8,
              shadowColor: const Color(0xFF2196F3).withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 220),
                width: MediaQuery.of(context).size.width - 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xFF1B263B), const Color(0xFF0D1B2A)]
                        : [Colors.white, const Color(0xFFF8FBFF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF2196F3).withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String option = options.elementAt(index);
                      final bool isFirst = index == 0;
                      
                      return InkWell(
                        onTap: () => onSelected(option),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isFirst
                                ? const Color(0xFF2196F3).withOpacity(0.1)
                                : Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isFirst
                                      ? const Color(0xFF2196F3).withOpacity(0.2)
                                      : isDark
                                          ? const Color(0xFF1B263B)
                                          : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.history_rounded,
                                  size: 18,
                                  color: isFirst
                                      ? const Color(0xFF2196F3)
                                      : isDark
                                          ? const Color(0xFF64748B)
                                          : const Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1E293B),
                                    fontSize: 15,
                                    fontWeight: isFirst
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (isFirst)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2196F3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Best',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required bool isDark,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1B263B).withOpacity(0.6),
                  const Color(0xFF0D1B2A).withOpacity(0.6),
                ]
              : [Colors.white, const Color(0xFFFAFBFF)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2196F3).withOpacity(0.2)
              : const Color(0xFF2196F3).withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : const Color(0xFF2196F3).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        onChanged: onChanged,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1E293B),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        dropdownColor: isDark ? const Color(0xFF1B263B) : Colors.white,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context, bool isDark) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          setState(() {
            _selectedDate = date;
          });
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1B263B).withOpacity(0.6),
                    const Color(0xFF0D1B2A).withOpacity(0.6),
                  ]
                : [Colors.white, const Color(0xFFFAFBFF)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? const Color(0xFF2196F3).withOpacity(0.2)
                : const Color(0xFF2196F3).withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : const Color(0xFF2196F3).withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy').format(_selectedDate),
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    bool isDark, {
    bool showMargin = true,
  }) {
    return Padding(
      padding: showMargin ? const EdgeInsets.only(bottom: 0) : EdgeInsets.zero,
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1E293B),
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildSplitMethodSelector(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1B263B).withOpacity(0.3)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2196F3).withOpacity(0.1)
              : Colors.transparent,
        ),
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: _buildSplitMethodButton(
              label: 'Equal Split',
              icon: Icons.people_rounded,
              isSelected: _splitMethod == SplitMethod.equal,
              isDark: isDark,
              onTap: () {
                setState(() {
                  _splitMethod = SplitMethod.equal;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSplitMethodButton(
              label: 'Custom Split',
              icon: Icons.tune_rounded,
              isSelected: _splitMethod == SplitMethod.custom,
              isDark: isDark,
              onTap: () {
                setState(() {
                  _splitMethod = SplitMethod.custom;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitMethodButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                )
              : null,
          color: isSelected
              ? null
              : isDark
              ? Colors.transparent
              : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2196F3).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? Colors.white
                  : isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeneficiariesList(
    List<dynamic> members,
    dynamic group,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1B263B).withOpacity(0.6),
                  const Color(0xFF0D1B2A).withOpacity(0.6),
                ]
              : [Colors.white, const Color(0xFFFAFBFF)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2196F3).withOpacity(0.2)
              : const Color(0xFF2196F3).withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : const Color(0xFF2196F3).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: members.asMap().entries.map((entry) {
          final index = entry.key;
          final member = entry.value;
          final isSelected = _selectedBeneficiaries.contains(member.id);

          if (!_customShareControllers.containsKey(member.id)) {
            _customShareControllers[member.id] = TextEditingController();
          }

          return Column(
            children: [
              if (index > 0)
                Divider(
                  height: 1,
                  color: isDark
                      ? const Color(0xFF2196F3).withOpacity(0.1)
                      : const Color(0xFFE2E8F0),
                ),
              CheckboxListTile(
                title: Text(
                  member.name,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                value: isSelected,
                activeColor: const Color(0xFF2196F3),
                checkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedBeneficiaries.add(member.id);
                    } else {
                      _selectedBeneficiaries.remove(member.id);
                    }
                  });
                },
              ),
              if (isSelected && _splitMethod == SplitMethod.custom)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 16,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0D1B2A).withOpacity(0.5)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2196F3).withOpacity(0.2)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: TextFormField(
                      controller: _customShareControllers[member.id],
                      decoration: InputDecoration(
                        labelText: 'Amount for ${member.name}',
                        labelStyle: TextStyle(
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffix: Text(
                          group.currency ?? 'USD',
                          style: const TextStyle(
                            color: Color(0xFF2196F3),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (_splitMethod == SplitMethod.custom && isSelected) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount < 0) {
                            return 'Invalid amount';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubmitButton(bool isEditing, bool isDark) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _submitExpense,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isEditing
                      ? Icons.check_circle_rounded
                      : Icons.add_circle_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  isEditing ? 'Update Expense' : 'Add Expense',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitExpense() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBeneficiaries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one beneficiary')),
      );
      return;
    }

    final amount = double.parse(_amountController.text);

    // Validate custom split amounts
    Map<String, double>? customShares;
    if (_splitMethod == SplitMethod.custom) {
      customShares = {};
      double total = 0;

      for (final beneficiaryId in _selectedBeneficiaries) {
        final controller = _customShareControllers[beneficiaryId];
        final shareAmount = double.tryParse(controller?.text ?? '0') ?? 0;
        customShares[beneficiaryId] = shareAmount;
        total += shareAmount;
      }

      // Check if total matches expense amount
      if ((total - amount).abs() > 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Custom split total ($total) must equal expense amount ($amount)',
            ),
          ),
        );
        return;
      }
    }

    if (widget.expenseId != null) {
      // Update existing expense
      ref
          .read(expensesProvider(widget.groupId).notifier)
          .updateExpense(
            expenseId: widget.expenseId!,
            description: _descriptionController.text.trim(),
            amount: amount,
            payerId: _selectedPayerId!,
            beneficiaryIds: _selectedBeneficiaries.toList(),
            splitMethod: _splitMethod,
            customShares: customShares,
            date: _selectedDate,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );
    } else {
      // Add new expense
      ref
          .read(expensesProvider(widget.groupId).notifier)
          .addExpense(
            description: _descriptionController.text.trim(),
            amount: amount,
            payerId: _selectedPayerId!,
            beneficiaryIds: _selectedBeneficiaries.toList(),
            splitMethod: _splitMethod,
            customShares: customShares,
            date: _selectedDate,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.expenseId != null ? 'Expense updated' : 'Expense added',
        ),
      ),
    );
  }
}
