import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/colors/default.dart';

class SettingComponents {
  static Widget storageCard(
    BuildContext context,
    String title,
    IconData icon, {
    Function()? onTap,
    bool enabled = true, // 👈 parameter baru
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Warna ketika disabled
    final disabledColor = colorScheme.onSurface.withOpacity(0.12);
    final disabledTextColor = colorScheme.onSurface.withOpacity(0.38);

    return GestureDetector(
      onTap: enabled ? onTap : null, // 👈 otomatis nonaktif
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1 : 0.5, // 👈 fade saat disable
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              width: 0.3,
              color: enabled
                  ? colorScheme.onSurface.withOpacity(0.2)
                  : disabledColor,
            ),
            color: enabled
                ? colorScheme.surfaceVariant
                : colorScheme.surfaceVariant.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: enabled
                    ? CustomColor.secondaryColor
                    : disabledTextColor, // 👈 icon ikut disable
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: enabled
                      ? theme.textTheme.bodyLarge?.color
                      : disabledTextColor, // 👈 text disable
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget listTileItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    Function()? onTap,
    bool enabled = true, // 👈 parameter baru
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Warna ketika disabled
    final disabledTextColor = colorScheme.onSurface.withOpacity(0.38);

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        size: 28,
        color: enabled
            ? colorScheme.onSurface
            : disabledTextColor, // 👈 disabled
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: enabled
              ? theme.textTheme.bodyLarge?.color
              : disabledTextColor, // 👈 disabled
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          color: enabled
              ? theme.textTheme.bodyMedium?.color?.withOpacity(0.7)
              : disabledTextColor.withOpacity(0.6), // 👈 disabled
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: enabled ? colorScheme.onSurface : disabledTextColor, // 👈 disabled
      ),
      onTap: enabled ? onTap : null, // 👈 nonaktifkan tap
    );
  }

}
