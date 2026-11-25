// Imports: Flutter widgets, our texts, our colors
import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';
import '../../services/product_service.dart';
import '../../models/product.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Add product screen (StatefulWidget because the form changes)
class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // Text controllers: they hold what the user types
  final _nameController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _thresholdController = TextEditingController();
  final _newCategoryController = TextEditingController();

  final _productService = ProductService();
  // Categories loaded from Firestore
  List<String> _categories = [];

  // The category chosen in the dropdown (null = nothing chosen yet)
  String? _selectedCategory;

  // True when the admin pressed "add new category"
  bool _isNewCategory = false;

  // Screen state: loading spinner and error message under the buttons
  bool _isLoading = false;
  String? _errorMessage;
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // Loads the categories from Firestore
  Future<void> _loadCategories() async {
    final categories = await _productService.getCategories();
    if (!mounted) return;
    setState(() {
      _categories = categories;
    });
  }

  // Validates the from and saves the product to Firestore
  Future<void> _saveProduct() async {
    final s = AppStrings.of(context);
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = s.enterProductName;
      });
      return;
    }
    final salePrice = double.tryParse(_salePriceController.text.trim());
    if (salePrice == null || salePrice <= 0) {
      setState(() {
        _errorMessage = s.invalidSalePrice;
      });
      return;
    }

    final purchasePrice = double.tryParse(_purchasePriceController.text.trim());
    if (purchasePrice == null || purchasePrice <= 0) {
      setState(() {
        _errorMessage = s.invalidPurchasePrice;
      });
      return;
    }
    final quantity = int.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity < 0) {
      setState(() {
        _errorMessage = s.invalidQuantity;
      });
      return;
    }
    final threshold = int.tryParse(_thresholdController.text.trim());
    if (threshold == null || threshold < 0) {
      setState(() {
        _errorMessage = s.invalidThreshold;
      });
      return;
    }
    String? category =
        _isNewCategory ? _newCategoryController.text.trim() : _selectedCategory;
    if (category == null || category.isEmpty) {
      setState(() {
        _errorMessage = _isNewCategory ? s.enterCategoryName : s.chooseCategory;
      });
      return;
    }
    // Checks if the name is already used
    final nameExists =
        await _productService.productNameExists(_nameController.text.trim());
    if (!mounted) return;
    if (nameExists) {
      setState(() {
        _errorMessage = s.productNameExists;
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      // Build the product object from the validated values
      final product = Product(
          id: '',
          name: _nameController.text.trim(),
          salePrice: salePrice,
          quantity: quantity,
          lowStockThreshold: threshold,
          category: category,
          isActive: true,
          lastModifiedAt: DateTime.now(),
          lastModifiedBy: uid);
      await _productService.addProduct(product, purchasePrice);
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

  // Free the controllers when the screen closes
  @override
  void dispose() {
    _nameController.dispose();
    _salePriceController.dispose();
    _purchasePriceController.dispose();
    _quantityController.dispose();
    _thresholdController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  // Builds a small label above a field (with a red star if required)
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

  // Builds one text field with an icon, same look as Login (rounded 20)
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

  // Builds the screen
  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      // Green top bar with the back arrow (added automatically)
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        title: Text(s.addNewProduct),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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

            // Quantity and low stock threshold in one row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quantity (whole number)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(s.quantity, required: true),
                      _buildField(
                        controller: _quantityController,
                        hint: s.quantity,
                        icon: Icons.inventory_2_outlined,
                        isNumber: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Low stock threshold (whole number)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(s.lowStockThreshold, required: true),
                      _buildField(
                        controller: _thresholdController,
                        hint: s.lowStockThreshold,
                        icon: Icons.notifications_none,
                        isNumber: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Save button (empty for now) and cancel button
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
                // Save button: runs _saveProduct (disabled while loading)
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
                      label: Text(s.saveProduct),
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
          ],
        ),
      ),
    );
  }
}
