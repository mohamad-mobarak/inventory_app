import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/sale.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';
import '../../utils/format_date.dart';
import '../../services/auth_service.dart';
import '../../services/sale_service.dart';

// Shows the full details of one sale.
class SaleDetailsScreen extends StatefulWidget {
  final Sale sale;
  final bool isAdmin;

  const SaleDetailsScreen({
    super.key,
    required this.sale,
    required this.isAdmin,
  });

  @override
  State<SaleDetailsScreen> createState() => _SaleDetailsScreenState();
}

class _SaleDetailsScreenState extends State<SaleDetailsScreen> {
  // Holds the error text shown under the cancel button.
  String? _errorMessage;

  // Disables the cancel button while the request is running.
  bool _isLoading = false;

  // Cancels the sale after the user confirms
  Future<void> _cancelSale() async {
    // Holds the localized strings for this screen
    final s = AppStrings.of(context);

    // Asks the user to confirm before cancelling
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(s.cancelSaleDialogTitle),
          content: Text(s.cancelSaleDialogMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(s.keepSaleButton),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(
                s.cancelSaleButton,
                style: TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        );
      },
    );

    // Stops if the user did not confirm
    if (confirmed != true) return;
    if (!mounted) return;

    // Shows the loading state and clears the old error
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Gets the current user who is cancelling the sale
      final user = FirebaseAuth.instance.currentUser!;
      final name = await AuthService().getUserName(user.uid);

      // Restores the stock and marks the sale as cancelled
      await SaleService().cancelSale(
        saleId: widget.sale.id,
        cancelledBy: user.uid,
        cancelledByName: name ?? '',
      );

      if (!mounted) return;

      // Shows a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.saleCancelledSuccess)),
      );

      // Returns to the previous screen
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      // Holds the error text, starting with the generic one
      String message = s.genericError;
      // Uses the specific message when the sale is missing
      if (e.toString().contains('sale-not-found')) {
        message = s.saleNotFoundError;
      }
      // Uses the specific message when the sale is already cancelled
      if (e.toString().contains('already-cancelled')) {
        message = s.alreadyCancelledError;
      }

      // Shows the error under the button
      setState(() {
        _errorMessage = message;
      });
    } finally {
      // Hides the loading state
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Builds one label and value row inside the info card.
  Widget _buildInfoRow(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          value,
        ],
      ),
    );
  }

  // Builds the card with status, date and seller name.
  Widget _buildInfoCard(AppStrings s) {
    final sale = widget.sale;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              s.statusLabel,
              Text(
                sale.isCancelled ? s.saleCancelled : s.saleCompleted,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:
                      sale.isCancelled ? AppColors.danger : AppColors.success,
                ),
              ),
            ),
            _buildInfoRow(s.dateLabel,
                Text(formatDate(sale.createdAt, s.amLabel, s.pmLabel))),
            if (widget.isAdmin)
              _buildInfoRow(s.sellerLabel, Text(sale.sellerName)),
          ],
        ),
      ),
    );
  }

  // Builds a small rounded box with a label above a value.
  Widget _buildStatBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // Builds the card of one product with its three boxes.
  Widget _buildItemCard(SaleItem item, AppStrings s) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.productName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatBox(s.quantityLabel, item.quantity.toString()),
                const SizedBox(width: 8),
                _buildStatBox(s.pricePerPiece, item.unitPrice.toString()),
                const SizedBox(width: 8),
                _buildStatBox(s.lineTotalLabel, item.lineTotal.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Builds the row that shows the total of the whole sale.
  Widget _buildTotalRow(AppStrings s) {
    final sale = widget.sale;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            s.totalLabel,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            sale.total.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: sale.isCancelled ? AppColors.danger : null,
            ),
          ),
        ],
      ),
    );
  }

  // Builds the box that shows who cancelled the sale and when.
  Widget _buildCancelledBox(AppStrings s) {
    final sale = widget.sale;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.cancelledByLabel,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(sale.cancelledByName ?? ''),
          if (sale.cancelledAt != null) ...[
            const SizedBox(height: 4),
            Text(formatDate(sale.cancelledAt!, s.amLabel, s.pmLabel)),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final sale = widget.sale;

    // Allows cancelling only for an admin or the owner of the sale.
    final canCancel = !sale.isCancelled &&
        (widget.isAdmin ||
            sale.sellerId == FirebaseAuth.instance.currentUser!.uid);

    return Scaffold(
      appBar: AppBar(title: Text(s.saleDetailsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(s),
          const SizedBox(height: 8),
          ...sale.items.map((item) => _buildItemCard(item, s)),
          _buildTotalRow(s),
          const SizedBox(height: 8),
          if (canCancel) ...[
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: _isLoading
                    ? null
                    : () {
                        _cancelSale();
                      },
                child: Text(s.cancelSaleButton),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.danger),
              ),
            ],
          ],
          if (sale.isCancelled) _buildCancelledBox(s),
        ],
      ),
    );
  }
}
