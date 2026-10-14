import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/payment.dart';
import '../providers/groups_provider.dart';
import '../providers/payments_provider.dart';

class AddPaymentScreen extends ConsumerStatefulWidget {
  final String groupId;
  final String? paymentId;

  const AddPaymentScreen({super.key, required this.groupId, this.paymentId});

  @override
  ConsumerState<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends ConsumerState<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String? _fromMemberId;
  String? _toMemberId;
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;
  bool _isInitialized = false;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadExistingData() {
    if (_isInitialized || widget.paymentId == null) return;

    final payments = ref.read(paymentsProvider(widget.groupId));
    try {
      final existingPayment = payments.firstWhere(
        (p) => p.id == widget.paymentId,
      );

      setState(() {
        _fromMemberId = existingPayment.fromId;
        _toMemberId = existingPayment.toId;
        _selectedDate = existingPayment.date;
        _amountController.text = existingPayment.amount.toString();
        _notesController.text = existingPayment.notes ?? '';
        _isInitialized = true;
      });
    } catch (e) {
      // Payment not found yet
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = ref.watch(membersProvider(widget.groupId));
    final group = ref.watch(groupProvider(widget.groupId));
    final payments = ref.watch(paymentsProvider(widget.groupId));
    final isEditing = widget.paymentId != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Load existing data after first frame if editing
    if (isEditing && !_isInitialized && payments.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingData();
      });
    }

    if (group == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Group not found')),
      );
    }

    if (!isEditing) {
      if (_fromMemberId == null && members.isNotEmpty) {
        _fromMemberId = members.first.id;
      }
      if (_toMemberId == null && members.length > 1) {
        _toMemberId = members[1].id;
      }
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
          isEditing ? 'Edit Payment' : 'Add Payment',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: members.length < 2
          ? Center(
              child: Text(
                'At least 2 members are required to add a payment',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF6B7280),
                ),
              ),
            )
          : _buildPaymentForm(members, group, isEditing, isDark),
    );
  }

  Widget _buildPaymentForm(
    List members,
    dynamic group,
    bool isEditing,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF0A0E27), const Color(0xFF1A1F3A)]
              : [const Color(0xFFF5F7FA), const Color(0xFFE8EAF6)],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // From (Payer) - Who is paying
              _buildModernDropdown(
                label: 'From (Payer)',
                hint: 'Who is paying?',
                icon: Icons.person_rounded,
                value: _fromMemberId,
                items: members.map<DropdownMenuItem<String>>((member) {
                  return DropdownMenuItem<String>(
                    value: member.id,
                    child: Text(member.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _fromMemberId = value;
                    // If same person selected for both, clear the other
                    if (_fromMemberId == _toMemberId) {
                      _toMemberId = null;
                    }
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select who is paying';
                  }
                  if (value == _toMemberId) {
                    return 'Payer and receiver cannot be the same person';
                  }
                  return null;
                },
                isDark: isDark,
              ),
              const SizedBox(height: 24),
              // Visual Payment Flow Card
              _buildPaymentFlowCard(isDark),
              const SizedBox(height: 24),
              // To (Receiver) - Who is receiving
              _buildModernDropdown(
                label: 'To (Receiver)',
                hint: 'Who is receiving?',
                icon: Icons.person_outline_rounded,
                value: _toMemberId,
                items: members.map<DropdownMenuItem<String>>((member) {
                  return DropdownMenuItem<String>(
                    value: member.id,
                    child: Text(member.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _toMemberId = value;
                    // If same person selected for both, clear the other
                    if (_fromMemberId == _toMemberId) {
                      _fromMemberId = null;
                    }
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select who is receiving';
                  }
                  if (value == _fromMemberId) {
                    return 'Payer and receiver cannot be the same person';
                  }
                  return null;
                },
                isDark: isDark,
              ),
              const SizedBox(height: 20),
              // Amount
              _buildModernTextField(
                label: 'Amount',
                hint: '0.00',
                icon: Icons.attach_money_rounded,
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
                isDark: isDark,
                suffix: Text(
                  group.currency ?? 'USD',
                  style: TextStyle(
                    color: const Color(0xFF2196F3),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Date
              _buildDateSelector(isDark),
              const SizedBox(height: 20),
              // Notes
              _buildModernTextField(
                label: 'Notes (Optional)',
                hint: 'Add a note...',
                icon: Icons.note_rounded,
                controller: _notesController,
                maxLines: 3,
                isDark: isDark,
              ),
              const SizedBox(height: 32),
              // Submit Button
              _buildSubmitButton(isEditing, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentFlowCard(bool isDark) {
    final fromMember = _fromMemberId != null
        ? ref
              .read(membersProvider(widget.groupId))
              .firstWhere(
                (m) => m.id == _fromMemberId,
                orElse: () => null as dynamic,
              )
        : null;
    final toMember = _toMemberId != null
        ? ref
              .read(membersProvider(widget.groupId))
              .firstWhere(
                (m) => m.id == _toMemberId,
                orElse: () => null as dynamic,
              )
        : null;
    final amount = _amountController.text.isNotEmpty
        ? double.tryParse(_amountController.text)
        : null;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E3A8A).withOpacity(0.2),
                  const Color(0xFF0F172A).withOpacity(0.3),
                ]
              : [
                  const Color(0xFF2196F3).withOpacity(0.05),
                  const Color(0xFF1976D2).withOpacity(0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF2196F3).withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // From Circle
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: fromMember != null
                          ? [const Color(0xFF2196F3), const Color(0xFF1976D2)]
                          : [
                              const Color(0xFF94A3B8).withOpacity(0.3),
                              const Color(0xFF64748B).withOpacity(0.3),
                            ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: fromMember != null
                        ? [
                            BoxShadow(
                              color: const Color(0xFF2196F3).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: fromMember != null
                        ? Colors.white
                        : const Color(0xFF94A3B8),
                    size: 36,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  fromMember?.name ?? 'Select Payer',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: fromMember != null
                        ? (isDark
                              ? const Color(0xFFE5E7EB)
                              : const Color(0xFF1E293B))
                        : const Color(0xFF94A3B8),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Arrow with Amount
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2196F3).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                if (amount != null && amount > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // To Circle
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: toMember != null
                          ? [const Color(0xFF10B981), const Color(0xFF059669)]
                          : [
                              const Color(0xFF94A3B8).withOpacity(0.3),
                              const Color(0xFF64748B).withOpacity(0.3),
                            ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: toMember != null
                        ? [
                            BoxShadow(
                              color: const Color(0xFF10B981).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: toMember != null
                        ? Colors.white
                        : const Color(0xFF94A3B8),
                    size: 36,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  toMember?.name ?? 'Select Receiver',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: toMember != null
                        ? (isDark
                              ? const Color(0xFFE5E7EB)
                              : const Color(0xFF1E293B))
                        : const Color(0xFF94A3B8),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDropdown({
    required String label,
    required String hint,
    required IconData icon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    required String? Function(String?) validator,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E293B).withOpacity(0.6),
                  const Color(0xFF0F172A).withOpacity(0.6),
                ]
              : [
                  Colors.white.withOpacity(0.9),
                  const Color(0xFFF8FAFC).withOpacity(0.9),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2196F3).withOpacity(0.3)
              : const Color(0xFF2196F3).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
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
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFFE5E7EB)
                        : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: DropdownButtonFormField<String>(
              value: value,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? const Color(0xFFE5E7EB)
                    : const Color(0xFF1E293B),
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: const Color(0xFF2196F3),
              ),
              items: items,
              onChanged: onChanged,
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    required bool isDark,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E293B).withOpacity(0.6),
                  const Color(0xFF0F172A).withOpacity(0.6),
                ]
              : [
                  Colors.white.withOpacity(0.9),
                  const Color(0xFFF8FAFC).withOpacity(0.9),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2196F3).withOpacity(0.3)
              : const Color(0xFF2196F3).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
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
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFFE5E7EB)
                        : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? const Color(0xFFE5E7EB)
                    : const Color(0xFF1E293B),
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                suffix: suffix,
              ),
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(bool isDark) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          setState(() {
            _selectedDate = date;
          });
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1E293B).withOpacity(0.6),
                    const Color(0xFF0F172A).withOpacity(0.6),
                  ]
                : [
                    Colors.white.withOpacity(0.9),
                    const Color(0xFFF8FAFC).withOpacity(0.9),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? const Color(0xFF2196F3).withOpacity(0.3)
                : const Color(0xFF2196F3).withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2196F3).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFE5E7EB)
                            : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF2196F3),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isEditing, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isSubmitting ? null : () => _submitPayment(isEditing),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSubmitting)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  const Icon(
                    Icons.payment_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                const SizedBox(width: 12),
                Text(
                  _isSubmitting
                      ? (isEditing ? 'Updating...' : 'Adding...')
                      : (isEditing ? 'Update Payment' : 'Add Payment'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitPayment(bool isEditing) async {
    if (!_formKey.currentState!.validate()) return;
    if (_fromMemberId == null || _toMemberId == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final amount = double.parse(_amountController.text);

      if (isEditing && widget.paymentId != null) {
        final payments = ref.read(paymentsProvider(widget.groupId));
        final existingPayment = payments.firstWhere(
          (p) => p.id == widget.paymentId,
        );

        final updatedPayment = Payment(
          id: existingPayment.id,
          fromId: _fromMemberId!,
          toId: _toMemberId!,
          amount: amount,
          groupId: widget.groupId,
          date: _selectedDate,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );

        await ref
            .read(paymentsProvider(widget.groupId).notifier)
            .updatePayment(updatedPayment);
      } else {
        await ref
            .read(paymentsProvider(widget.groupId).notifier)
            .addPayment(
              fromId: _fromMemberId!,
              toId: _toMemberId!,
              amount: amount,
              date: _selectedDate,
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment ${isEditing ? 'updated' : 'added'} successfully',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error ${isEditing ? 'updating' : 'adding'} payment: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
