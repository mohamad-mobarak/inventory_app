import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/sale_service.dart';
import '../../models/product.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';
import '../../services/product_service.dart';
import '../../services/auth_service.dart';
import 'sales_history_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/format_money.dart';

// Screen where a seller picks products, fills a cart and records a sale.
class SellScreen extends StatefulWidget {
  // Tells whether the current user is an admin
  final bool isAdmin;
  const SellScreen({super.key, required this.isAdmin});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final TextEditingController _searchController = TextEditingController();
  // Service used to read products from Firestore
  final ProductService _productService = ProductService();
  // Stores the current search text.
  String _searchText = '';
  // Keeps the latest products list
  List<Product> _products = [];

  Map<String, int> _cart = {};
  String? _cartError;
  bool _isLoading = false;

  // Total number of  pieces in the cart.
  int get _cartCount => _cart.values.fold(0, (sum, item) => sum + item);

  // Total price of everything in the cart.
  double get _cartTotal {
    var total = 0.0;
    for (final entry in _cart.entries) {
      final matches = _products.where((p) => p.id == entry.key);
      if (matches.isEmpty) {
        continue;
      }
      final product = matches.first;
      total += product.salePrice * entry.value;
    }
    return total;
  }

  // Frees the controller when the screen is closed.
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Opens the cart sheet with the items, the total and the buttons.
  void _showCartSheet() {
    _cartError = null;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        // Theme colors used for the total price.
        final colors = Theme.of(context).colorScheme;
        final currency = context.watch<SettingsProvider>().currency ?? '';

        return StatefulBuilder(builder: (context, setSheetState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.of(context).cartTitle,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(Icons.shopping_cart,
                          color: Theme.of(context).colorScheme.primary),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: _cart.isEmpty
                        ? SizedBox(
                            height: 120,
                            child: Center(
                                child:
                                    Text(AppStrings.of(context).cartEmptyHint)),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: _cart.length,
                            itemBuilder: (context, index) {
                              final productId = _cart.keys.toList()[index];
                              final matches =
                                  _products.where((p) => p.id == productId);
                              if (matches.isEmpty) {
                                const SizedBox.shrink();
                              }
                              final product = matches.first;
                              final quantity = _cart[productId] ?? 0;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                                '${AppStrings.of(context).unitPrice}:  ${formatMoney(product.salePrice, currency)} '),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: colors.outlineVariant),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove),
                                              onPressed: () {
                                                setState(() {
                                                  _cartError = null;
                                                  // Removes the product from the cart when its quantity is 1 or less.
                                                  if (quantity <= 1) {
                                                    _cart.remove(productId);
                                                  } else {
                                                    _cart[productId] =
                                                        quantity - 1;
                                                  }
                                                });
                                                setSheetState(() {});
                                              },
                                            ),
                                            Text('${quantity}'),
                                            IconButton(
                                              icon: const Icon(Icons.add),
                                              onPressed: () {
                                                _addToCart(product);
                                                setSheetState(() {});
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: AppColors.danger,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _cartError = null;
                                            _cart.remove(productId);
                                          });
                                          setSheetState(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  if (_cartError != null) ...[
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      _cartError!,
                      style: TextStyle(color: AppColors.danger),
                    ),
                  ],
                  // Total price in the app color, above the buttons.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.of(context).cartTotalPrice,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${formatMoney(_cartTotal, currency)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Cancel and confirm buttons side by side.
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(sheetContext);
                            },
                            child: Text(AppStrings.of(context).cancel),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              textStyle: TextStyle(fontWeight: FontWeight.bold),
                              backgroundColor: colors.primary,
                              foregroundColor: colors.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: _isLoading
                                ? null
                                : () {
                                    _confirmSale();
                                  },
                            child: Text(AppStrings.of(context).confirmSale),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  // Confirms the sale: validates the cart and saves it through SaleService
  Future<void> _confirmSale() async {
    if (_cart.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    // Stops if no user is signed in
    if (user == null) return;
    // Gets the seller's name from the users colllection
    String? sellerName = await AuthService().getUserName(user.uid);
    if (sellerName == null) return;
    setState(() {
      _isLoading = true;
      _cartError = null;
    });
    try {
      // Creates the sale and updates the stock in one transaction
      await SaleService().createSale(
          quantities: _cart, sellerId: user.uid, sellerName: sellerName);
      // Empties the cart after a successful sale
      setState(() {
        _cart.clear();
      });
      if (!mounted) return;
      Navigator.pop(context);
      // Shows a success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle,
                  color: Theme.of(context).colorScheme.onPrimary),
              SizedBox(width: 10),
              Text(AppStrings.of(context).saleSuccess),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))));
    } catch (e) {
      if (!mounted) return;
      final message = e.toString();
      String text = AppStrings.of(context).genericError;
      if (message.contains('not-enough-stock')) {
        text = AppStrings.of(context).stockChanged;
      }
      if (message.contains('product-inactive') ||
          message.contains('product-not-found')) {
        text = AppStrings.of(context).cartProductUnavailable;
      }
      // Shows the final error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(
              width: 10,
            ),
            Expanded(
                child: Text(
              text,
              style: const TextStyle(color: Colors.white),
            )),
          ],
        ),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ));
    } finally {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  // Adds one piece of the product to the cart
  void _addToCart(Product product) {
    final current = _cart[product.id] ?? 0;
    if (current >= product.quantity) {
      setState(() {
        _cartError =
            '${AppStrings.of(context).availableQuantityOnly(product.quantity)}';
      });

      return;
    }
    setState(() {
      _cart[product.id] = current + 1;
      _cartError = null;
    });
  }

  // Builds the search field, the product list and the floating cart bar.
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final currency = context.watch<SettingsProvider>().currency ?? '';

    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 50,
        title: Text(
          AppStrings.of(context).sellTab,
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SalesHistoryScreen(isAdmin: widget.isAdmin)));
                },
                child: Text(s.salesHistory)),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  // Save the typed text and refreshes the list
                  onChanged: (value) {
                    setState(() {
                      _searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: AppStrings.of(context).searchProductHint,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: StreamBuilder<List<Product>>(
                stream: _productService.getProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text(AppStrings.of(context).errorLabel));
                  }
                  // Takes the product list from the stream.
                  final products = snapshot.data ?? [];
                  _products = products;
                  // Propares the search text
                  final searchQuery = _searchText.trim().toLowerCase();
                  // Keeps only active products with quantity above zero.
                  final availableProducts = products
                      .where((product) =>
                          product.isActive &&
                          product.quantity > 0 &&
                          product.name.toLowerCase().contains(searchQuery))
                      .toList();
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
                    itemCount: availableProducts.length,
                    itemBuilder: (context, index) {
                      final product = availableProducts[index];
                      final isLow =
                          product.quantity <= product.lowStockThreshold;
                      final stockColor =
                          isLow ? AppColors.warning : AppColors.success;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                            onTap: () {
                              _addToCart(product);
                            },
                            title: Row(
                              children: [
                                Text(product.name),
                                if (isLow) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    AppStrings.of(context).lowStock,
                                    style: TextStyle(
                                      color: AppColors.warning,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Text(product.category),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '${AppStrings.of(context).unitPrice}: ${formatMoney(product.salePrice, currency)}'),
                                    Text(
                                      '${AppStrings.of(context).availableLabel}: ${product.quantity}',
                                      style: TextStyle(color: stockColor),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Icon(Icons.add_shopping_cart,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ],
                            )),
                      );
                    },
                  );
                },
              )),
            ],
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart, color: colors.onPrimary),
                      SizedBox(
                        width: 8,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: _showCartSheet,
                        child: Text(AppStrings.of(context).viewCart),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${AppStrings.of(context).itemsLabel}: ${_cartCount} ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colors.onPrimary,
                        ),
                      ),
                      Text(
                        '${AppStrings.of(context).cartTotalPrice}: ${formatMoney(_cartTotal, currency)}',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colors.onPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
