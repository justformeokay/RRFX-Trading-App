import 'package:flutter/material.dart';
import 'package:rrfx/src/components/colors/default.dart';

class AgreementCheckTile extends StatelessWidget {
  final bool value;
  final String text;
  final bool enabled;
  final Function(bool)? onChanged;

  const AgreementCheckTile({
    super.key,
    required this.value,
    required this.text,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: InkWell(
        onTap: enabled ? () => onChanged?.call(!value) : null,
        borderRadius: BorderRadius.circular(6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === CUSTOM CHECKBOX ===
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: value
                    ? CustomColor.secondaryColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: enabled
                      ? (value
                          ? CustomColor.secondaryColor
                          : theme.colorScheme.onSurface.withOpacity(0.6))
                      : Colors.grey.withOpacity(0.5),
                  width: 1.6,
                ),
              ),
              child: value
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: isDark ? Colors.black : Colors.black,
                    )
                  : null,
            ),

            const SizedBox(width: 10),

            // === LABEL TEKS ===
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(
                    enabled ? 0.85 : 0.45,
                  ),
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
