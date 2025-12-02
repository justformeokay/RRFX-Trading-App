import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/colors/default.dart';

class NumberTextfieldNew extends StatefulWidget {
  final TextEditingController controller;
  final String fieldName;
  final String hintText;
  final String labelText;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool readOnly;

  /// 🔥 Tambahan baru
  final bool requiredField;

  const NumberTextfieldNew({
    super.key,
    required this.controller,
    required this.fieldName,
    required this.hintText,
    required this.labelText,
    this.keyboardType,
    this.onChanged,
    this.validator,
    this.readOnly = false,
    this.requiredField = false, // default false
  });

  @override
  State<NumberTextfieldNew> createState() => _NumberTextfieldNewState();
}

class _NumberTextfieldNewState extends State<NumberTextfieldNew> {
  String previousValue = "";

  @override
  Widget build(BuildContext context) {
    final bool isReadOnly = widget.readOnly ?? false;
    final colorScheme = Theme.of(context).colorScheme;
    final disabledBorderColor = colorScheme.onSurface.withOpacity(0.12);
    final borderColor = isReadOnly ? disabledBorderColor : CustomColor.textThemeDarkSoftColor;
    // 🔥 Label dengan tanda * merah
    final Widget labelWidget = RichText(
      text: TextSpan(
        text: widget.labelText,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        children: [
          if (widget.requiredField)
            const TextSpan(
              text: " *",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: widget.controller,
        readOnly: widget.readOnly,
        keyboardType: widget.keyboardType ?? TextInputType.number,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: widget.readOnly
              ? CustomColor.textThemeDarkSoftColor
              : Theme.of(context).textTheme.bodyLarge?.color,
        ),

        decoration: InputDecoration(
          label: labelWidget, // 🔥 gunakan label baru di sini
          prefixIcon: Icon(
            Icons.numbers,
            size: 16,
            color: isReadOnly ? null : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),

          hintText: widget.hintText,
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),

          hintStyle: GoogleFonts.inter(color: Colors.grey),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: borderColor),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: borderColor),
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: borderColor),
          ),
        ),

        validator: widget.validator,

        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9\.\,]')),
        ],

        onChanged: (value) {
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
          previousValue = value;
        },
      ),
    );
  }
}

// =============================
// Number Formatter Service
// =============================
class NumberFormattersService {
  static String formatRupiah(int value) {
    if (value == 0) return "Rp 0";
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(value);
  }

  static int parseRupiahToInt(String text) {
    if (text.isEmpty) return 0;
    final cleaned = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return 0;
    return int.tryParse(cleaned) ?? 0;
  }

  static String formatUSD(double value) {
    final formatter =
        NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2);
    return formatter.format(value);
  }

  static double parseUSDToDouble(String text) {
    if (text.isEmpty) return 0.0;
    final cleaned = text.replaceAll(RegExp(r'[^0-9\.]'), '');
    if (cleaned.isEmpty) return 0.0;
    return double.tryParse(cleaned) ?? 0.0;
  }
}
