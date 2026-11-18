import 'package:flutter/material.dart';
import 'package:inventory_app/screens/sellers/add_seller_screen.dart';
import 'package:inventory_app/screens/sellers/seller_details_screen.dart';
import '../../l10n/app_strings.dart';
import 'package:inventory_app/theme/app_theme.dart';
import '../../services/seller_service.dart';
import '../../models/app_user.dart';

class SellersScreen extends StatelessWidget {
  const SellersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    // Our service object, used to resd the sellers from Firestore
    final service = SellerService();

    return Scaffold(
        appBar: AppBar(centerTitle: true, title: Text(s.sellers)),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // Open the add seller screen on top of this one
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddSellerScreen()));
          },
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.person_add),
          label: Text(s.addSeller),
        ),
        body: StreamBuilder<List<AppUser>>(
          stream: service.getSellers(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(s.loasFailed),
              );
            }
            // While waiting for the first data, show a loading circle
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            // Use the received sellers , or an empty list if thers is no data
            final sellers = [...(snapshot.data ?? [])];
            sellers.sort((a, b) =>
                b.isActive.toString().compareTo(a.isActive.toString()));
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sellers.length,
              itemBuilder: (context, index) {
                final seller = sellers[index];
                final name = seller.name;
                final email = seller.email;
                final isActive = seller.isActive;

                return Opacity(
                  opacity: isActive ? 1 : 0.5,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      onTap: () {
                        // Open the seller details screen on top of this one
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SellerDetailsScreen(
                                      seller: seller,
                                    )));
                      },
                      leading: CircleAvatar(
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.15),
                          foregroundColor: AppColors.primary,
                          child: Text(name[0])),
                      title: Text(name),
                      subtitle: Text(email),
                      trailing: Text(
                        isActive ? s.sellerActive : s.sellerDisabled,
                        style: TextStyle(
                          color: isActive ? Colors.green : AppColors.danger,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ));
  }
}
