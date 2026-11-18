// Imports: Flutter widgets, our texts, our colors
import 'package:flutter/material.dart';
import 'add_product_screen.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';
import '../../services/product_service.dart';
import '../../models/product.dart';
import 'edit_product_screen.dart';

// Products list screen (isAdmin: true = admin, false = seller)
class ProductsScreen extends StatefulWidget {
  final bool isAdmin;

  const ProductsScreen({super.key, required this.isAdmin});

  // Creates the state object that keeps the search text
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  // Service used to read products from Firestore
  final _productService = ProductService();

  // Controls the text inside the search box
  final TextEditingController _searchController = TextEditingController();

  // Holds the text the user typed in the search box
  String _searchQuery = '';

  // Holds the products stream so it is created only once
  late final Stream<List<Product>> _productsStream;

  // Creates the products stream one time when the screen opens
  @override
  void initState() {
    super.initState();
    _productsStream = _productService.getProducts();
  }

  // Frees the search controller when the screen closes
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Returns a rounded status badge: in stock (green), low (orange), out (red)
  Widget _buildBadge(AppStrings s, int quantity, int threshold) {
    String label = s.available;
    Color color = AppColors.success;
    IconData icon = Icons.check_circle;

    if (quantity == 0) {
      label = s.outOfStock;
      color = AppColors.danger;
      icon = Icons.cancel;
    } else if (quantity <= threshold) {
      label = s.lowStock;
      color = AppColors.warning;
      icon = Icons.warning_amber_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Builds one product card: image placeholder, name, price, quantity, badge
  Widget _buildProductCard(BuildContext context, AppStrings s, Product p) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        // Tap to edit: admin only
        onTap: widget.isAdmin
            ? () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditProductScreen(product: p)));
              }
            : null,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Box icon placeholder (a real image comes in phase 2)
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              // Name, price, and quantity
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${s.salePrice}: ${p.salePrice}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 16),
                        const SizedBox(width: 4),
                        Text('${s.quantity}:  ${p.quantity}'),
                      ],
                    ),
                  ],
                ),
              ),
              // Status badge
              _buildBadge(s, p.quantity, p.lowStockThreshold),
              // Arrow: admin only (means the card opens the edit screen)
              if (widget.isAdmin) const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  // Builds the search box that filters the products by name
  Widget _buildSearchField(AppStrings s) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: TextField(
        controller: _searchController,
        // Saves the typed text and rebuilds the list
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: s.searchProductHint,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  // Builds the screen
  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    return Scaffold(
      // Top bar: logo, app name, screen name, and a menu icon
      appBar: AppBar(
        toolbarHeight: 72,
        leadingWidth: 72,
        // Logo inside a white rounded box (right side in Arabic)
        leading: Padding(
          padding:
              const EdgeInsetsDirectional.only(start: 16, top: 12, bottom: 12),
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
            SizedBox(
              height: 5,
            ),
            Text(s.products, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
      // + button: admin only
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddProductScreen()));
              },
              child: const Icon(Icons.add),
            )
          : null,
      // Search box on top, then the list of products under it
      body: Column(
        children: [
          _buildSearchField(s),
          // Empty message, or the filtered list of products
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: _productsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(s.loasFailed),
                  );
                }
                final query = _searchQuery.trim().toLowerCase();
                final products = (snapshot.data ?? [])
                    .where((p) =>
                        p.isActive && p.name.toLowerCase().contains(query))
                    .toList();
                // Sorts products with the newest first and old products without a date last
                products.sort((a, b) {
                  if (a.createdAt == null && b.createdAt == null) return 0;
                  if (a.createdAt == null) return 1;
                  if (b.createdAt == null) return -1;
                  // Compares two dates so the newest product comes first
                  return b.createdAt!.compareTo(a.createdAt!);
                });
                if (products.isEmpty) {
                  return Center(
                    child:
                        Text(query.isEmpty ? s.noProducts : s.noSearchResults),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(context, s, products[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
