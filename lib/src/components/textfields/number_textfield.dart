import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/colors/default.dart';

extension RawValue on TextEditingController {
  String get raw => text.replaceAll(RegExp(r'[^0-9+]'), '');
}

class NumberTextField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final bool? readOnly;
  final String? fieldName;
  final int? maxLength;
  final int? minLength;
  final String? preffix;
  final TextEditingController? controller;
  final bool? useValidator;
  final bool? requiredField; // ⭐ DITAMBAHKAN
  final IconData? iconData;
  final Function(PointerDownEvent)? onTapOutside;
  final Function(String)? onSubmitted;
  final Function()? onEditingComplete;
  final bool? activateOnChange;
  final bool? withCurrencyFormatter;
  final String? currencyType;

  const NumberTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.readOnly,
    this.fieldName,
    this.maxLength,
    this.minLength,
    this.preffix,
    this.controller,
    this.useValidator,
    this.requiredField = false, // ⭐ DEFAULT FALSE
    this.iconData,
    this.onTapOutside,
    this.onSubmitted,
    this.onEditingComplete,
    this.activateOnChange,
    this.withCurrencyFormatter = false,
    this.currencyType,
  });

  @override
  State<NumberTextField> createState() => _NumberTextFieldState();
}

class _NumberTextFieldState extends State<NumberTextField> {
  RxBool isNumber = false.obs;
  RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    if ((widget.controller?.text.length ?? 0) > 0) {
      isNumber(true);
    }
  }

  String _formatCurrency(String raw) {
    if (raw.isEmpty) return '';

    String locale = 'id_ID';
    String symbol = 'Rp ';

    if (widget.currencyType?.toUpperCase() == "US") {
      locale = 'en_US';
      symbol = '\$ ';
    }

    final f = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: 0,
    );

    return f.format(int.parse(raw));
  }

  @override
  Widget build(BuildContext context) {
    final isReadOnly = widget.readOnly ?? false;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Obx(() {
        if (isLoading.value) return const SizedBox();

        return TextFormField(
          readOnly: isReadOnly,
          controller: widget.controller,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          keyboardType: TextInputType.number,
          maxLength: widget.maxLength ?? 100,
          cursorColor: CustomColor.secondaryColor,
          style: GoogleFonts.inter(
            color: isReadOnly
                ? colorScheme.onSurface.withOpacity(0.3)
                : colorScheme.onSurface,
            fontSize: 15,
          ),

          validator: (value) {
            if (widget.useValidator == true) {
              if (widget.requiredField == true &&
                  (value == null || value.isEmpty)) {
                return "Mohon isikan ${widget.fieldName}";
              }

              String raw =
                  value?.replaceAll(RegExp(r'[^0-9+]'), '') ?? '';

              if (raw.isEmpty) {
                return "Mohon isikan ${widget.fieldName} yang benar";
              }
            }
            return null;
          },

          onTapOutside: widget.onTapOutside,
          onFieldSubmitted: widget.onSubmitted,
          onEditingComplete: widget.onEditingComplete,

          decoration: InputDecoration(
            counterText: '',
            prefixIcon: SizedBox(
              width: 30,
              child: Icon(
                widget.iconData ?? Iconsax.d_cube_scan_outline,
                color: isReadOnly
                    ? colorScheme.onSurfaceVariant.withOpacity(0.3)
                    : colorScheme.onSurfaceVariant,
              ),
            ),

            prefix: widget.preffix != null
                ? Text(widget.preffix!, style: GoogleFonts.inter(fontSize: 16))
                : null,

            hintText: widget.hintText,
            hintStyle: GoogleFonts.inter(
              color: CustomColor.textThemeDarkSoftColor.withOpacity(0.7),
              fontSize: 14,
            ),

            label: RichText(
              text: TextSpan(
                text: widget.labelText ?? '',
                style: TextStyle(
                  color: isReadOnly
                            ? colorScheme.onSurface.withOpacity(0.3)
                            : Theme.of(context).textTheme.bodyMedium?.color,
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
            ),

            filled: isReadOnly,
            fillColor: isReadOnly
                ? colorScheme.surfaceVariant.withOpacity(
                    Theme.of(context).brightness == Brightness.dark ? 0.25 : 0.5)
                : Colors.transparent,

            // ⭐ Enabled Border (Normal)
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: isReadOnly
                    ? colorScheme.onSurface.withOpacity(0.12) // disabled color
                    : CustomColor.textThemeDarkSoftColor,
                width: 1.2,
              ),
            ),

            // ⭐ Focused Border
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: isReadOnly
                    ? colorScheme.onSurface.withOpacity(0.12)
                    : CustomColor.secondaryColor,
                width: isReadOnly ? 1.0 : 1.6,
              ),
            ),
          ),


          onChanged: (value) {
            // Allow digits and plus sign only
            String raw = value.replaceAll(RegExp(r'[^0-9+]'), '');

            if (raw.isEmpty) {
              isNumber(false);
              widget.controller?.text = "";
              return;
            }

            if (widget.withCurrencyFormatter == true) {
              // Remove + sign before formatting currency
              final numericOnly = raw.replaceAll(RegExp(r'[^0-9]'), '');
              final formatted = _formatCurrency(numericOnly);

              widget.controller?.value = TextEditingValue(
                text: formatted,
                selection:
                    TextSelection.collapsed(offset: formatted.length),
              );
            } else {
              // Update text with filtered value (keep + and digits)
              widget.controller?.value = TextEditingValue(
                text: raw,
                selection:
                    TextSelection.collapsed(offset: raw.length),
              );
            }

            // Check length without the + symbol for validation
            final numericLength = raw.replaceAll(RegExp(r'[^0-9]'), '').length;
            if (widget.minLength == null ||
                numericLength >= widget.minLength!) {
              isNumber(true);
            } else {
              isNumber(false);
            }
          },
        );
      }),
    );
  }
}
