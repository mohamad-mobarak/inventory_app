import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../services/seller_service.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_strings.dart';

class SellerDetailsScreen extends StatefulWidget {
  final AppUser seller;
  const SellerDetailsScreen({super.key, required this.seller});

  @override
  State<SellerDetailsScreen> createState() => _SellerDetailsScreenState();
}

class _SellerDetailsScreenState extends State<SellerDetailsScreen> {
  late final TextEditingController _nameController;

  late bool _isActive;
  bool _isLoading = false;
  String? _errorMessage;
  final SellerService _sellerService = SellerService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.seller.name);
    _isActive = widget.seller.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // Texts in the current app language
    final s = AppStrings.of(context);
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = s.nameRequired;
      });
      return;
    }
    setState(() {
      _isLoading = true;
      // Clear the old error before a new save
      _errorMessage = null;
    });

    try {
      await _sellerService.updateSellerName(
          widget.seller.id, _nameController.text.trim());
      await _sellerService.updateSellerActive(widget.seller.id, _isActive);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      // Show the save failed error
      setState(() {
        _errorMessage = s.saveFailed;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.sellerDetails)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                foregroundColor: AppColors.primary,
                child: Text(widget.seller.name[0],
                    style: const TextStyle(fontSize: 32)),
              ),
              const SizedBox(height: 12),
              Text(widget.seller.email, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  filled: true,
                  fillColor: Colors.white,
                  labelText: s.sellerName,
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: SwitchListTile(
                  title: Text(s.accountActive),
                  value: _isActive,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : Text(s.saveChanges,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppColors.danger),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {},
                  child: Text(s.viewSellerSales),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
