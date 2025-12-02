import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/colors/default.dart';

class EmptyAccountState extends StatelessWidget {
  final VoidCallback? onCreateAccount;
  final bool isCreatingAccount;

  const EmptyAccountState({super.key, this.onCreateAccount, this.isCreatingAccount = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: CustomColor.secondaryColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.wallet_add_1_outline,
              size: 48,
              color: CustomColor.secondaryColor,
            ),
          ),

          const SizedBox(height: 22),

          // 📝 Title
          Text(
            "Tidak Ada Akun Trading",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10),

          // 🧾 Subtitle
          Text(
            "Anda belum memiliki akun trading (Demo atau Real).\nBuat akun baru untuk mulai trading.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: theme.colorScheme.onSurface.withOpacity(0.65),
            ),
          ),

          const SizedBox(height: 28),

          // 🚀 Button CTA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isCreatingAccount ? null : onCreateAccount,
              icon: isCreatingAccount ? const SizedBox.shrink() : const Icon(Icons.add_circle_outline_rounded, color: Colors.black),
              label: isCreatingAccount
                ? SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  )
                : Text("Buat Akun Trading",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
