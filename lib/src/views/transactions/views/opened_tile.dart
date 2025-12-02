import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/views/chart/components/flag_pair.dart';

class OpenedTile extends StatelessWidget {
  final String ticket;
  final String symbol;
  final String lot;
  final String openPrice;
  final String currentPrice;
  final String openTime;
  final String stopLoss;
  final String takeProfit;
  final String swap;
  final String profit;
  final String orderType;
  final String digits;
  final VoidCallback onEndPosition;

  const OpenedTile({
    super.key,
    required this.ticket,
    required this.symbol,
    required this.lot,
    required this.openPrice,
    required this.currentPrice,
    required this.openTime,
    required this.stopLoss,
    required this.takeProfit,
    required this.swap,
    required this.profit,
    required this.orderType,
    required this.digits,
    required this.onEndPosition,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isBuy = orderType.toLowerCase() == "buy";

    final doubleProfit = double.tryParse(profit) ?? 0.0;
    final profitColor = doubleProfit > 0
        ? Colors.greenAccent.shade400
        : doubleProfit < 0
            ? Colors.redAccent.shade200
            : Colors.grey.shade400;

    // Format tanggal
    String formattedDate = openTime;
    try {
      formattedDate =
          DateFormat('dd MMM yyyy • HH:mm').format(DateTime.parse(openTime));
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Slidable(
        key: ValueKey(ticket),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.3,
          children: [
            SlidableAction(
              onPressed: (_) => onEndPosition(),
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              icon: Icons.close_rounded,
              label: 'Close',
              borderRadius: BorderRadius.circular(15),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111111) : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.15)
                  : Colors.black.withOpacity(0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.45)
                    : Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
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

                  /// BUY / SELL TAG
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
                        color: isBuy
                            ? Colors.greenAccent.shade400
                            : Colors.redAccent.shade200,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              /// SUBTITLE
              Text(
                'Ticket #$ticket • $formattedDate',
                style: GoogleFonts.inter(
                  color: theme.colorScheme.onSurface.withOpacity(0.55),
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 12),

              Divider(
                color: theme.colorScheme.onSurface.withOpacity(0.15),
                height: 1,
              ),

              const SizedBox(height: 12),

              /// ROW 1
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabelValue(theme, "Open Price", openPrice),
                  _buildLabelValue(theme, "Current", currentPrice),
                  _buildLabelValue(theme, "Lot", lot),
                ],
              ),

              const SizedBox(height: 12),

              /// ROW 2
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabelValue(theme, "Swap", swap),
                  _buildLabelValue(theme, "S/L", stopLoss),
                  _buildLabelValue(theme, "T/P", takeProfit),
                ],
              ),

              const SizedBox(height: 15),

              /// PROFIT BOX
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: profitColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  "${doubleProfit >= 0 ? '+' : ''}${doubleProfit.toStringAsFixed(2)} USD",
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
      ),
    );
  }

  /// LABEL + VALUE ADAPTIF
  Widget _buildLabelValue(
      ThemeData theme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// LABEL
        Text(
          label,
          style: GoogleFonts.inter(
            color: theme.colorScheme.onSurface.withOpacity(0.55),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),

        /// VALUE
        Text(
          value,
          style: GoogleFonts.inter(
            color: theme.colorScheme.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
