import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../models/product.dart';
import '../../models/sale.dart';
import '../../services/product_service.dart';
import '../../services/sale_service.dart';
import '../../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Reads the sales from Firestore
  final SaleService _saleService = SaleService();
  // Reads the products and their purchase prices
  final ProductService _productService = ProductService();
  // Stores the purchase prices already loaded, by product id
  final Map<String, double> _costs = {};
  // Streams the sales of this month
  late final Stream<List<Sale>> _salesStream;
  // Streams all the products
  late final Stream<List<Product>> _productsStream;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Starts the sales stream from the first day of this month
    _salesStream = _saleService.getSalesSince(DateTime(now.year, now.month, 1));
    // Starts the products stream
    _productsStream = _productService.getProducts();
  }

  // Loads the purchase prices of the products that are not cached yet
  // هدف حساب الربح
  Future<Map<String, double>> _loadCosts(List<Sale> sales) async {
    for (final sale in sales) {
      for (final item in sale.items) {
        // Skips the products whose price is already loaded
        if (_costs.containsKey(item.productId)) continue;
        final cost = await _productService.getPurchasePrice(item.productId);
        // Stores the price when a cost document exists
        if (cost != null) {
          _costs[item.productId] = cost;
        }
      }
    }
    return _costs;
  }

  // Adds up the totals of the given sales
  double _calculateTotal(List<Sale> sales) {
    double total = 0;
    for (final sale in sales) {
      total += sale.total;
    }
    return total;
  }

  // Calculates the profit of the given sales from the purchase prices
  double _calculateProfit(List<Sale> sales, Map<String, double> costs) {
    double profit = 0;
    for (final sale in sales) {
      for (final item in sale.items) {
        final cost = costs[item.productId];
        // Skips the items without a known purchase price
        if (cost == null) continue;
        profit += (item.unitPrice - cost) * item.quantity;
      }
    }
    return profit;
  }

  // Builds one summary card with an icon, a label, a value and a note
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required String note,
    Color? accent,
  }) {
    final colors = Theme.of(context).colorScheme;
    // Uses the accent color when given, otherwise the normal text color
    final Color textColor = accent ?? colors.onSurface;
    // Tints the card with the accent color, or uses a neutral background
    final Color background = accent == null
        ? colors.surfaceContainerHighest
        : accent.withValues(alpha: 0.12);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: textColor),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 13, color: textColor)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(note, style: TextStyle(fontSize: 12, color: textColor)),
        ],
      ),
    );
  }

  // Builds the today and this month cards from the sales stream
  Widget _buildSalesSection(AppStrings s) {
    return StreamBuilder<List<Sale>>(
      stream: _salesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(s.genericError));
        }

        final sales = snapshot.data ?? [];
        final now = DateTime.now();
        final startOfToday = DateTime(now.year, now.month, now.day);
        // Keeps the sales that are not cancelled
        final monthSales = sales.where((sale) => !sale.isCancelled).toList();
        // Keeps the sales made since the start of today
        final todaySales = monthSales
            .where((sale) => !sale.createdAt.isBefore(startOfToday))
            .toList();

        // Loads the purchase prices, then calculates the profit
        return FutureBuilder<Map<String, double>>(
          future: _loadCosts(monthSales),
          builder: (context, costsSnapshot) {
            final costs = costsSnapshot.data;
            // Shows dots until the purchase prices are loaded
            final String todayProfit = costs == null
                ? '...'
                : _calculateProfit(todaySales, costs).toStringAsFixed(2);
            final String monthProfit = costs == null
                ? '...'
                : _calculateProfit(monthSales, costs).toStringAsFixed(2);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.today,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.receipt_long,
                        label: s.sales,
                        value: _calculateTotal(todaySales).toStringAsFixed(2),
                        note: '${todaySales.length} ${s.salesUnit}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.trending_up,
                        label: s.profit,
                        value: todayProfit,
                        note: s.excludesCancelled,
                        accent: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(s.thisMonth,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.receipt_long,
                        label: s.sales,
                        value: _calculateTotal(monthSales).toStringAsFixed(2),
                        note: '${monthSales.length} ${s.salesUnit}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.trending_up,
                        label: s.profit,
                        value: monthProfit,
                        note: s.excludesCancelled,
                        accent: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Builds the low stock card and the list of products that need restocking
  Widget _buildLowStockSection(AppStrings s) {
    return StreamBuilder<List<Product>>(
      stream: _productsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(s.genericError));
        }

        final products = snapshot.data ?? [];
        // Keeps the active products at or below their low stock threshold
        final lowStock = products
            .where((product) =>
                product.isActive &&
                product.quantity <= product.lowStockThreshold)
            .toList();
        // Puts the products with the lowest quantity first
        lowStock.sort((a, b) => a.quantity.compareTo(b.quantity));

        // Shows a reassuring card when no product is running low
        if (lowStock.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline,
                    color: AppColors.success),
                const SizedBox(width: 10),
                Text(s.noLowStock,
                    style: const TextStyle(color: AppColors.success)),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Shows the title card with the number of products to restock
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.warning),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.lowStockTitle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${lowStock.length} ${s.productsNeedRestock}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Lists the low stock products inside a bordered box
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: lowStock.map((product) {
                  return ListTile(
                    title: Text(product.name),
                    // Shows a red badge when sold out, otherwise the quantity
                    trailing: product.quantity == 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              s.outOfStock,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.danger,
                              ),
                            ),
                          )
                        : Text('${s.available}: ${product.quantity}'),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Gets the texts of the current language
    final s = AppStrings.of(context);

    return Scaffold(
      // Top bar: logo, app name, screen name
      appBar: AppBar(
        toolbarHeight: 72,
        leadingWidth: 72,
        // Logo inside a white rounded box (right side in Arabic)
        leading: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 16,
            top: 12,
            bottom: 12,
          ),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset('assets/images/app_logo.png'),
          ),
        ),
        // App name on top, screen name under it
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.inventorySystem,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(s.dashboard, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSalesSection(s),
          const SizedBox(height: 16),
          _buildLowStockSection(s),
        ],
      ),
    );
  }
}
