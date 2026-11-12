import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../l10n/app_strings.dart';
import '../../models/sale.dart';
import 'sale_details_screen.dart';
import '../../services/sale_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/format_date.dart';

// Screen that lists the recent sales, newest first.
class SalesHistoryScreen extends StatefulWidget {
  // Tells whether the current user is an admin.
  final bool isAdmin;
  final String? sellerId;
  const SalesHistoryScreen({super.key, required this.isAdmin, this.sellerId});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  // Service used to read sales from Firestore.
  final SaleService _saleService = SaleService();

  // Holds the sales stream that matches the user role.
  late final Stream<List<Sale>> _salesStream;

  // Picks all sales for an admin or only own sales for a seller.
  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (widget.sellerId != null) {
      _salesStream = _saleService.getSellerSales(widget.sellerId!);
      return;
    }
    _salesStream = widget.isAdmin
        ? _saleService.getAllSales()
        : _saleService.getSellerSales(uid);
  }

  // Builds one card that summarizes a sale.
  Widget _buildSaleCard(BuildContext context, Sale sale) {
    final s = AppStrings.of(context);
    final statusColor = sale.isCancelled ? AppColors.danger : AppColors.success;
    final names = sale.items.map((item) => item.productName).join(', ');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    names,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    sale.isCancelled ? s.saleCancelled : s.saleCompleted,
                    style: TextStyle(color: statusColor, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(formatDate(sale.createdAt, s.amLabel, s.pmLabel)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${sale.itemCount} ${s.piecesLabel}'),
                Text(
                  '${s.totalLabel}: ${sale.total}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: sale.isCancelled ? AppColors.danger : null,
                  ),
                ),
              ],
            ),
            if (widget.isAdmin) ...[
              const SizedBox(height: 4),
              Text('${s.sellerLabel}: ${sale.sellerName}'),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SaleDetailsScreen(
                              sale: sale, isAdmin: widget.isAdmin)));
                },
                child: Text(s.viewDetails),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds the app bar and the sales list.
  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.salesHistory)),
      body: StreamBuilder<List<Sale>>(
        stream: _salesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(s.genericError));
          }
          final sales = List<Sale>.from(snapshot.data ?? []);
          sales.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          if (sales.isEmpty) {
            return Center(child: Text(s.noSalesYet));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: sales.length,
            itemBuilder: (context, index) {
              return _buildSaleCard(context, sales[index]);
            },
          );
        },
      ),
    );
  }
}
