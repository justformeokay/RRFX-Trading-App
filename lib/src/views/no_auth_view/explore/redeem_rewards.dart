import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/components/alerts/popup.dart';
import 'package:rrfx/src/components/colors/default.dart';

class RedeemRewardsPage extends StatelessWidget {
  final bool isLoggedIn; // jika false → muncul tombol Login & Register

  const RedeemRewardsPage({
    super.key,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text("Redeem Rewards"),
        centerTitle: true,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Title
            Text(
              "Tukar Poin Kamu",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Kumpulkan poin trading dan tukarkan dengan hadiah menarik.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),

            /// Jika belum login → tampilkan CTA
            if (!isLoggedIn) _buildAuthCard(context),

            const SizedBox(height: 20),

            /// List Rewards
            Text(
              "Rewards Tersedia",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),

            _rewardItem(
              context,
              title: "Bonus Trading \$10",
              points: 1500,
              image: Icons.monetization_on,
            ),
            const SizedBox(height: 14),

            _rewardItem(
              context,
              title: "Merchandise RRFX (T-Shirt)",
              points: 2500,
              image: Icons.shopping_bag,
            ),
            const SizedBox(height: 14),

            _rewardItem(
              context,
              title: "Exclusive Cashback",
              points: 5000,
              image: Icons.card_giftcard,
            ),
          ],
        ),
      ),
    );
  }

  /// ==========================
  /// Card untuk Login/Register
  /// ==========================
  Widget _buildAuthCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            blurRadius: 25,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(0.07),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Masuk untuk Redeem Rewards",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Login atau daftar akun RRFX untuk menukar reward dan melihat poinmu.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.65),
            ),
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.toNamed("/login"),
                  style: ElevatedButton.styleFrom(  
                    backgroundColor: CustomColor.secondaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.toNamed("/signup"),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: CustomColor.secondaryColor,
                      width: 1.4,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Register",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: CustomColor.secondaryColor),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  /// ==========================
  /// Card Reward Item
  /// ==========================
  Widget _rewardItem(
    BuildContext context, {
    required String title,
    required int points,
    required IconData image,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 15,
            offset: const Offset(0, 5),
            color: Colors.black.withOpacity(0.06),
          )
        ],
      ),

      child: Row(
        children: [

          /// Icon circle
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CustomColor.secondaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              image,
              size: 30,
              color: CustomColor.secondaryColor,
            ),
          ),

          const SizedBox(width: 16),

          /// Text info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$points poin",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          /// Button Redeem
          ElevatedButton(
            onPressed: () {
              AuthDirectionPopup.show();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomColor.secondaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Redeem",
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
