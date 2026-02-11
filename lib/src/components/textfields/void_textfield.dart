import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/helpers/validator/email_validator.dart';

class VoidTextField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final String? fieldName;
  final bool? readOnly;
  final IconData? iconData;
  final bool? useValidator;
  final Function()? onPressed;
  final bool? requiredField;
  final String? preffix;
  final TextEditingController? controller;

  const VoidTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.readOnly,
    this.fieldName,
    this.onPressed,
    this.iconData,
    this.preffix,
    this.requiredField,
    this.useValidator,
  });

  @override
  State<VoidTextField> createState() => _VoidTextFieldState();
}

class _VoidTextFieldState extends State<VoidTextField> {
  RxBool isEmail = false.obs;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isReadOnly = widget.readOnly ?? true;
    final disabledBorderColor = isDark ? colorScheme.onSurface.withOpacity(0.25) : colorScheme.onSurface.withOpacity(0.12);
    final borderColor = isReadOnly ? disabledBorderColor : CustomColor.textThemeDarkSoftColor;
    final fillColor = isReadOnly ? colorScheme.surfaceVariant.withOpacity(isDark ? 0.25 : 0.5) : Colors.transparent;
    final Widget? labelWidget = widget.labelText != null
      ? RichText(
          text: TextSpan(
            text: widget.labelText,
            style: TextStyle(
              color: isReadOnly ? colorScheme.onSurface.withOpacity(0.3) : Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
            children: [
              if (widget.requiredField == true)
                const TextSpan(
                  text: " *",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        )
      : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: MouseRegion(
        cursor: isReadOnly ? SystemMouseCursors.click : SystemMouseCursors.text,
        child: GestureDetector(
          onTap: widget.onPressed,
          behavior: HitTestBehavior.opaque,
          child: AbsorbPointer(
            absorbing: true,
            child: TextFormField(
              readOnly: true,
              controller: widget.controller,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              cursorColor: CustomColor.secondaryColor,
              validator: (value) {
                if (widget.useValidator == true) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon isikan ${widget.fieldName}';
                  }
                }
                return null;
              },

              style: GoogleFonts.inter(
                color: isReadOnly ? colorScheme.onSurface.withOpacity(0.3) : colorScheme.onSurface,
              ),

              decoration: InputDecoration(
                hintText: widget.hintText,
                label: labelWidget, // <- ⬅ memakai RichText untuk tanda *
                prefixIcon: SizedBox(
                  width: 30,
                  child: Icon(
                    widget.iconData ?? Iconsax.d_cube_scan_outline,
                    color: isReadOnly
                        ? colorScheme.onSurfaceVariant.withOpacity(0.3)
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                hintStyle: GoogleFonts.inter(
                  color: CustomColor.textThemeDarkSoftColor.withOpacity(0.3),
                  fontSize: 14,
                ),

                filled: isReadOnly,
                fillColor: fillColor,

                prefix: widget.preffix != null
                  ? Text(
                      widget.preffix!,
                      style: GoogleFonts.inter(
                        color: colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    )
                  : null,

                suffixIcon: isReadOnly ? null : Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isReadOnly ? null : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: borderColor,
                    width: isReadOnly ? 0.8 : 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: isReadOnly
                        ? borderColor
                        : CustomColor.secondaryColor,
                    width: isReadOnly ? 0.8 : 1.6,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide:
                      BorderSide(color: borderColor, width: 0.8),
                ),
              ),

              onChanged: (value) {
                isEmail(validateEmailBool(value) == true);
              },
            ),
          ),
        ),
      ),
    );
  }
}
