import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/colors/default.dart';

enum MoneyType { idr, usd }

class TextFormFieldMoney extends StatefulWidget {
  final TextEditingController controller;
  final MoneyType moneyType;
  final String? label;
  final String? hint;
  final String? labelText;
  final bool? useValidator;
  final FormFieldValidator<String>? validator;

  /// Callback untuk mengirimkan nilai mentah (tanpa simbol & decimal)
  final ValueChanged<String>? onRawValueChanged;

  const TextFormFieldMoney({
    super.key,
    required this.controller,
    this.moneyType = MoneyType.idr,
    this.label,
    this.hint,
    this.labelText,
    this.validator,
    this.useValidator,
    this.onRawValueChanged,
  });

  @override
  State<TextFormFieldMoney> createState() => _TextFormFieldMoneyState();
}

class _TextFormFieldMoneyState extends State<TextFormFieldMoney> {
  late NumberFormat _formatter;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _formatter = widget.moneyType == MoneyType.idr
        ? NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        : NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2);

    widget.controller.addListener(() {
      if (_isEditing) return;

      final String text = widget.controller.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (text.isEmpty) {
        widget.controller.value = TextEditingValue(
          text: '',
          selection: const TextSelection.collapsed(offset: 0),
        );
        widget.onRawValueChanged?.call(''); // kirim nilai kosong
        return;
      }

      _isEditing = true;
      final double value = double.parse(text);

      // Format tampilan
      widget.controller.value = TextEditingValue(
        text: _formatter.format(value),
        selection: TextSelection.collapsed(offset: _formatter.format(value).length),
      );

      // Kirim nilai mentah tanpa simbol dan decimal
      widget.onRawValueChanged?.call(value.toStringAsFixed(0));

      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          prefixIconColor: CustomColor.textThemeDarkSoftColor,
          prefixIcon: const SizedBox(width: 30, child: Icon(Icons.attach_money)),
          hintText: widget.hint ?? "Jumlah Uang",
          hintStyle: GoogleFonts.inter(
            color: CustomColor.textThemeDarkSoftColor,
            fontSize: 14,
          ),
          labelText: widget.labelText,
          labelStyle: const TextStyle(
            color: CustomColor.textThemeDarkSoftColor,
          ),
          filled: false,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: CustomColor.secondaryColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide:
                BorderSide(color: CustomColor.textThemeDarkSoftColor),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide:
                BorderSide(color: CustomColor.textThemeDarkSoftColor),
          ),
        ),
        validator: widget.validator,
      ),
    );
  }
}
