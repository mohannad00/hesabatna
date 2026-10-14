import 'package:flutter/material.dart';
import '../widgets/transaction_details_bottom_sheet.dart';

class TransactionDetailsHelper {
  /// Shows the transaction details bottom sheet
  static void showTransactionDetails({
    required BuildContext context,
    required String groupId,
    required String memberId,
    required String otherMemberId,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailsBottomSheet(
        groupId: groupId,
        memberId: memberId,
        otherMemberId: otherMemberId,
      ),
    );
  }
}
