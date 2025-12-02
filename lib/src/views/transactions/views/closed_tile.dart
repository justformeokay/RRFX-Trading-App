import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/views/chart/components/flag_pair.dart';

class ClosedTile extends StatelessWidget {
  final String ticket;
  final String profit;
  final String closePrice;
  final String closeTime;
  final String openPrice;
  final String openTime;
  final String lot;
  final String orderType;
  final String symbol;
  final String stopLoss;
  final String takeProfit;
  final String digits;

  const ClosedTile({
    super.key,
    required this.ticket,
    required this.profit,
    required this.closePrice,
    required this.closeTime,
    required this.openPrice,
    required this.openTime,
    required this.lot,
    required this.orderType,
    required this.symbol,
    required this.stopLoss,
    required this.takeProfit,
    required this.digits,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final onSurface = theme.colorScheme.onSurface;
    final onSurfaceVariant = onSurface.withOpacity(0.55);
    final dividerColor = onSurface.withOpacity(0.15);

    final isBuy = orderType.toLowerCase() == "buy";
    final profitValue = double.tryParse(profit) ?? 0.0;

    final profitColor = profitValue > 0
        ? Colors.greenAccent.shade400
        : profitValue < 0
            ? Colors.redAccent.shade200
            : onSurface.withOpacity(0.5);

    final openTimeFormatted =
        DateFormat('dd MMM yyyy • HH:mm').format(DateTime.parse(openTime));

    final closeTimeFormatted =
        DateFormat('dd MMM yyyy • HH:mm').format(DateTime.parse(closeTime));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121212) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.4)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    FlagPair(marketName: symbol, size: 35),
                    const SizedBox(width: 10),
                    Text(
                      symbol.replaceAll('.db', ''),
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: CustomColor.secondaryColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isBuy
                        ? Colors.greenAccent.withOpacity(0.15)
                        : Colors.redAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    orderType.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isBuy
                          ? Colors.greenAccent.shade400
                          : Colors.redAccent.shade200,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // SUBTITLE
            Text(
              "Ticket #$ticket",
              style: GoogleFonts.inter(
                color: onSurfaceVariant,
                fontSize: 11,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Open: $openTimeFormatted\nClose: $closeTimeFormatted',
              style: GoogleFonts.inter(
                color: onSurfaceVariant,
                fontSize: 11,
              ),
            ),

            const SizedBox(height: 12),

            Divider(color: dividerColor, height: 1),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabelValue("Open Price", openPrice, onSurface, onSurfaceVariant),
                _buildLabelValue("Close Price", closePrice, onSurface, onSurfaceVariant),
                _buildLabelValue("Lot", lot, onSurface, onSurfaceVariant),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabelValue("S/L", stopLoss, onSurface, onSurfaceVariant),
                _buildLabelValue("T/P", takeProfit, onSurface, onSurfaceVariant),
                _buildLabelValue("Digits", digits, onSurface, onSurfaceVariant),
              ],
            ),

            const SizedBox(height: 15),

            // PROFIT BOX
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: profitColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                "${profitValue >= 0 ? '+' : ''}${profitValue.toStringAsFixed(2)} USD",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: profitColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelValue(
    String label,
    String value,
    Color onSurface,
    Color onSurfaceVariant,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: onSurfaceVariant,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            color: onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
