import 'dart:ui';
import 'package:flutter/material.dart';

class TradingAccountCard extends StatelessWidget {
  final String type; 
  final String login;
  final String namaTipeAkun;
  final String balance;
  final String currency;
  final String leverage;
  final String pnl;

  final VoidCallback? onDocuments;
  final VoidCallback? onDeposit;
  final VoidCallback? onWithdraw;
  final VoidCallback? onMore;

  const TradingAccountCard({
    super.key,
    required this.type,
    required this.login,
    required this.namaTipeAkun,
    required this.balance,
    required this.currency,
    required this.leverage,
    required this.pnl,
    this.onDocuments,
    this.onDeposit,
    this.onWithdraw,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),

        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),

          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.08)        // ✔ Glass effect for dark mode
                  : Colors.white.withOpacity(0.90),        // ✔ Solid white for light mode
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.15)
                    : Colors.black.withOpacity(0.05),       // ✔ Proper border for light mode
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.black.withOpacity(0.08),    // ✔ Softer shadow in light mode
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _typeChip(type, isDark),
                    Text(
                      "Login: $login",
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                Text(
                  namaTipeAkun,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "USD $balance",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoTile("Leverage", "1:${cleanLeverage(leverage)}", isDark),
                    _infoTile("PNL", pnl, isDark),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _shortcutButton(
                      icon: Icons.file_copy_rounded,
                      label: "Documents",
                      onTap: onDocuments,
                      isDark: isDark,
                    ),
                    _shortcutButton(
                      icon: Icons.savings_rounded,
                      label: "Deposit",
                      onTap: onDeposit,
                      isDark: isDark,
                    ),
                    _shortcutButton(
                      icon: Icons.wallet_rounded,
                      label: "Withdraw",
                      onTap: onWithdraw,
                      isDark: isDark,
                    ),
                    _shortcutButton(
                      icon: Icons.more_horiz,
                      label: "More",
                      onTap: onMore,
                      isDark: isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String cleanLeverage(String? value) {
    print("value leverage: $value");

    if (value == null || value.isEmpty) return "-";

    // Jika format mengandung "1:400.00"
    if (value.contains(":")) {
      value = value.split(":")[1]; // ambil bagian setelah ":"
    }

    final double? parsed = double.tryParse(value);
    if (parsed == null) return value;

    if (parsed == parsed.roundToDouble()) {
      return parsed.toInt().toString(); // contoh: 400.00 -> 400
    }

    return parsed.toString();
  }



  /// CHIP TYPE
  Widget _typeChip(String type, bool isDark) {
    final bool isReal = type.toLowerCase() == "real";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (isReal ? Colors.green : Colors.blue).withOpacity(0.15),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
        ),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          color: isReal ? Colors.green : Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// INFO TILE
  Widget _infoTile(String title, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.black54,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// SHORTCUT BUTTON
  Widget _shortcutButton({
    required IconData icon,
    required String label,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.2)
                    : Colors.black.withOpacity(0.1),
              ),
            ),
            child: Icon(
              icon,
              size: 22,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
