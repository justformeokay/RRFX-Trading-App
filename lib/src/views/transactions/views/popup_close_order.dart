import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/colors/default.dart';

Future<void> showCloseConfirmationDialog({
  required BuildContext context,
  required String symbol,
  required String lot,
  required String profit,
  required String swap,
  required String commission,
  required VoidCallback onConfirm,
}) async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  final surface = theme.colorScheme.surface;
  final onSurface = theme.colorScheme.onSurface;
  final onSurfaceVariant = onSurface.withOpacity(0.6);

  final sheetColor = theme.bottomSheetTheme.backgroundColor ??
      (isDark ? const Color(0xFF121212) : Colors.white);

  final dividerColor = onSurface.withOpacity(0.15);

  // PROFIT COLOR
  final profitValue = double.tryParse(profit) ?? 0.0;
  final profitColor = profitValue > 0
      ? Colors.greenAccent.shade400
      : profitValue < 0
          ? Colors.redAccent.shade200
          : onSurfaceVariant;

  await showModalBottomSheet(
    context: context,
    backgroundColor: sheetColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    isScrollControlled: true,
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // DRAG HANDLE
            Container(
              width: 45,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: onSurface.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // TITLE
            Text(
              "Close Position?",
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: onSurface,
              ),
            ),

            const SizedBox(height: 8),

            // SUBTITLE
            Text(
              "Pastikan Anda yakin untuk menutup posisi ini.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: onSurfaceVariant,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 20),

            // INFO CARD
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : surface.withOpacity(0.7),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: dividerColor, width: 1),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRow(context, "Market", symbol.replaceAll('.db', '')),
                  const SizedBox(height: 8),
                  _buildInfoRow(context, "Lot", lot),
                  const SizedBox(height: 8),
                  _buildInfoRow(context, "Swap", swap),
                  const SizedBox(height: 8),
                  _buildInfoRow(context, "Commission", commission),

                  const SizedBox(height: 12),

                  // PROFIT BOX
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: profitColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Profit: ${profitValue >= 0 ? '+' : ''}${profitValue.toStringAsFixed(2)} USD",
                      textAlign: TextAlign.center,
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

            const SizedBox(height: 25),

            // BUTTONS
            Row(
              children: [
                // CANCEL
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF2A2A2A)
                          : Colors.grey.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size.fromHeight(48),
                      elevation: 0,
                    ),
                    child: Text(
                      "Batal",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: onSurface.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // CONFIRM
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColor.secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Text(
                      "Close Position",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildInfoRow(BuildContext context, String label, String value) {
  final theme = Theme.of(context);
  final onSurface = theme.colorScheme.onSurface;
  final onSurfaceVariant = onSurface.withOpacity(0.6);

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: GoogleFonts.inter(
          color: onSurfaceVariant,
          fontSize: 12,
        ),
      ),
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
