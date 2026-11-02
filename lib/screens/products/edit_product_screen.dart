// Imports: Flutter widgets, our texts, our colors
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:inventory_app/services/product_service.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';
import '../../models/product.dart';

// Edit product screen (receives the product to edit)
class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  // Text controllers: they get their first value in initState
  late final TextEditingController _nameController;
  late final TextEditingController _salePriceController;
  late final TextEditingController _purchasePriceController;
  late final TextEditingController _thresholdController;
  final _newCategoryController = TextEditingController();

  // Categories loaded from Firestore when the screen opens
  List<String> _categories = [];

  // Current quantity (changes only with the two quantity buttons)
  late int _quantity;
  final _quantityDialogController = TextEditingController();
  // The chosen category, and true when adding a new one
  String? _selectedCategory;
  bool _isNewCategory = false;

  // Screen state: loading spinner and error message under the buttons
  bool _isLoading = false;
  String? _errorMessage;
  Future<void> _loadCategories() async {
    final result = await ProductService().getCategories();
    if (!mounted) return;
    setState(() {
      _categories = result;
    });
  }

  // Opens a dialog where the admin types the new full quantity
  Future<void> _showQuantityDialog() async {
    final s = AppStrings.of(context);
    _quantityDialogController.text = _quantity.toString();
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(s.editQuantity),
            content: TextField(
              controller: _quantityDialogController,
              keyboardType: TextInputType.number,
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(s.cancel)),
              TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(s.confirm))
            ],
          );
        });
    if (confirmed != true) return;
    if (!mounted) return;
    final newQuantity = int.tryParse(_quantityDialogController.text.trim());
    if (newQuantity == null || newQuantity < 0) {
      setState(() {
        _errorMessage = s.invalidQuantity;
      });
      return;
    }
    setState(() {
      _quantity = newQuantity;
      _errorMessage = null;
    });
  }

  Future<void> _hideProduct() async {
    final s = AppStrings.of(context);
    final confirmed = await showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(s.hideProduct),
            content: Text(s.hideProductHint),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(s.cancel)),
              TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(s.confirm)),
            ],
          );
        });
    if (confirmed != true) return;
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      await ProductService().setProductActive(widget.product.id, false, uid);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = s.couldNotHide;
      });
    } finally {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  Future<void> _loadPurchasePrice() async {
    final result = await ProductService().getPurchasePrice(widget.product.id);
    if (!mounted) return;
    setState(() {
      if (result != null) {
        _purchasePriceController.text = result.toString();
      }
    });
  }

  Future<void> _saveProduct() async {
    // Localized texts for the error messages
    final s = AppStrings.of(context);

    // Name is required
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = s.nameRequired;
      });
      return;
    }

    // Sale price must be a number greater than 0
    final salePrice = double.tryParse(_salePriceController.text.trim());
    if (salePrice == null || salePrice <= 0) {
      setState(() {
        _errorMessage = s.invalidSalePrice;
      });
      return;
    }

    // Purchase price must be a number greater than 0
    final purchasePrice = double.tryParse(_purchasePriceController.text.trim());
    if (purchasePrice == null || purchasePrice <= 0) {
      setState(() {
        _errorMessage = s.invalidPurchasePrice;
      });
      return;
    }

    // Low stock threshold must be a whole number, 0 or more
    final threshold = int.tryParse(_thresholdController.text.trim());
    if (threshold == null || threshold < 0) {
      setState(() {
        _errorMessage = s.invalidThreshold;
      });
      return;
    }

    // Category is required (the chosen one or the new one)
    final category =
        _isNewCategory ? _newCategoryController.text.trim() : _selectedCategory;
    if (category == null || category.isEmpty) {
      setState(() {
        _errorMessage = s.chooseCategory;
      });
      return;
    }
    // Checks if another product already uses this name
    final nameExists = await ProductService().productNameExists(
      _nameController.text.trim(),
      excludeId: widget.product.id,
    );
    if (!mounted) return;
    if (nameExists) {
      setState(() {
        _errorMessage = s.productNameExists;
      });
      return;
    }
    // Show the loading state and clear any old error
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Current user id, saved as tast editor
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

      // Build the updated product (same id and active state as the old one)
      final product = Product(
          id: widget.product.id,
          name: _nameController.text.trim(),
          salePrice: salePrice,
          quantity: _quantity,
          lowStockThreshold: threshold,
          category: category,
          isActive: widget.product.isActive,
          lastModifiedAt: DateTime.now(),
          lastModifiedBy: uid);
      // Save the product and its purchase price together
      await ProductService().updateProduct(product, purchasePrice);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = s.couldNotSaveProduct;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Fill the controllers from the product we received
  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _loadCategories();
    _nameController = TextEditingController(text: p.name);
    _salePriceController = TextEditingController(text: p.salePrice.toString());
    _purchasePriceController = TextEditingController();
    _thresholdController =
        TextEditingController(text: p.lowStockThreshold.toString());
    _loadPurchasePrice();
    _quantity = p.quantity;
    _selectedCategory = p.category;
  }

  // Free the controllers when the screen closes
  @override
  void dispose() {
    _nameController.dispose();
    _quantityDialogController.dispose();
    _salePriceController.dispose();
    _purchasePriceController.dispose();
    _thresholdController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  // Builds a small label above a field (red star if required, extra widget if given)
  Widget _buildLabel(String text, {bool required = false, Widget? extra}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (required) Text(' *', style: TextStyle(color: AppColors.danger)),
          if (extra != null) ...[const SizedBox(width: 6), extra],
        ],
      ),
    );
  }

  // Builds one text field with an icon, same look as the add screen
  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isNumber = false,
    bool isDecimal = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber
          ? TextInputType.numberWithOptions(decimal: isDecimal)
          : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  // Builds the status badge: in stock (green), low (orange), out (red)
  Widget _buildBadge(AppStrings s) {
    final threshold = widget.product.lowStockThreshold;
    String label = s.available;
    Color color = AppColors.success;

    if (_quantity == 0) {
      label = s.outOfStock;
      color = AppColors.danger;
    } else if (_quantity <= threshold) {
      label = s.lowStock;
      color = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Builds the quantity card: number, badge, and the two quantity buttons
  Widget _buildQuantityCard(AppStrings s, Color primary) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Title and badge on top
            Row(
              children: [
                Text(
                  s.currentQuantity,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                _buildBadge(s),
              ],
            ),
            const SizedBox(height: 8),
            // The big quantity number
            Text(
              '$_quantity',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
            const SizedBox(height: 12),
            // Two buttons: add quantity, correct quantity (empty for now)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showQuantityDialog();
                    },
                    icon: const Icon(Icons.add),
                    label: Text(s.editQuantity),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Builds the screen
  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      // Green top bar with the back arrow (added automatically)
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: Text(s.editProduct),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Quantity card on top
            _buildQuantityCard(s, primary),
            const SizedBox(height: 20),

            // Product name
            _buildLabel(s.productName, required: true),
            _buildField(
              controller: _nameController,
              hint: s.enterProductName,
              icon: Icons.label_outline,
            ),
            const SizedBox(height: 20),

            // Category: dropdown + "add new category" button
            _buildLabel(s.category, required: true),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    hint: Text(s.chooseCategory),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    // Choosing an existing category cancels "new category"
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                        _isNewCategory = false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Button: shows the new category field
                SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isNewCategory = true;
                        _selectedCategory = null;
                      });
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(s.addNewCategory),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // New category name field: shown only after pressing the button
            if (_isNewCategory) ...[
              const SizedBox(height: 12),
              _buildField(
                controller: _newCategoryController,
                hint: s.newCategoryName,
                icon: Icons.category_outlined,
              ),
            ],
            const SizedBox(height: 20),

            // Sale price and purchase price in one row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sale price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(s.salePrice, required: true),
                      _buildField(
                        controller: _salePriceController,
                        hint: s.salePrice,
                        icon: Icons.attach_money,
                        isNumber: true,
                        isDecimal: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Purchase price: lock icon means admin only
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(
                        s.purchasePrice,
                        extra: const Icon(Icons.lock, size: 14),
                      ),
                      _buildField(
                        controller: _purchasePriceController,
                        hint: s.purchasePrice,
                        icon: Icons.attach_money,
                        isNumber: true,
                        isDecimal: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Low stock threshold (whole number)
            _buildLabel(s.lowStockThreshold, required: true),
            _buildField(
              controller: _thresholdController,
              hint: s.lowStockThreshold,
              icon: Icons.notifications_none,
              isNumber: true,
            ),
            const SizedBox(height: 28),

            // Cancel and save buttons
            Row(
              children: [
                // Cancel: goes back to the previous screen
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(s.cancel),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Save changes: empty for now, we connect it later
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () {
                              _saveProduct();
                            },
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(s.saveChanges),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Error message under the buttons (same pattern as Login)
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.danger),
              ),
            ],
            const SizedBox(height: 24),

            // Hide product button (empty for now) with a hint under it
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () {
                        _hideProduct();
                      },
                icon: Icon(Icons.visibility_off_outlined,
                    color: AppColors.danger),
                label: Text(
                  s.hideProduct,
                  style: TextStyle(color: AppColors.danger),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.danger),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.hideProductHint,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
