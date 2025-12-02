import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/colors/default.dart';

class PhoneTextField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final bool? readOnly;
  final String? fieldName;
  final TextEditingController? controller;
  final bool? useValidator;
  final bool? requiredField;

  const PhoneTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.readOnly,
    this.fieldName,
    this.useValidator,
    this.requiredField = false,
  });

  @override
  State<PhoneTextField> createState() => _PhoneTextFieldState();
}

class _PhoneTextFieldState extends State<PhoneTextField> {
  RxBool isPhone = false.obs;
  RxBool isLoading = false.obs;

  bool validateIndonesianPhone(String input) {
    if (!RegExp(r'^[0-9]+$').hasMatch(input)) return false;
    if (!input.startsWith("08")) return false;
    if (input.length < 10) return false;
    return true;
  }

  @override
  void initState() {
    super.initState();
    final text = widget.controller?.text ?? "";
    isPhone(validateIndonesianPhone(text));
  }

  @override
  Widget build(BuildContext context) {
    final bool isReadOnly = widget.readOnly ?? false;
    final colorScheme = Theme.of(context).colorScheme;
    final fillColor = isReadOnly ? colorScheme.surfaceVariant.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.25 : 0.5) : Colors.transparent;
    final disabledBorderColor = colorScheme.onSurface.withOpacity(0.12);
    final borderColor = isReadOnly ? disabledBorderColor : CustomColor.textThemeDarkSoftColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Obx(
        () => isLoading.value ? const SizedBox() : TextFormField(
          readOnly: widget.readOnly ?? false,
          controller: widget.controller,
          maxLength: 15,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          autofillHints: const [AutofillHints.telephoneNumber],
          keyboardType: TextInputType.phone,
          cursorColor: CustomColor.secondaryColor,
          style: GoogleFonts.inter(
                  color: isReadOnly
                      ? colorScheme.onSurface.withOpacity(0.3)
                      : colorScheme.onSurface,
                ),

          validator: (value) {
            if (widget.useValidator != true) return null;

            if (widget.requiredField == true) {
              if (value == null || value.isEmpty) {
                return "Mohon isikan ${widget.fieldName}";
              }
            }

            if (!isPhone.value) {
              return "Mohon isikan nomor telepon yang benar";
            }

            return null;
          },

          decoration: InputDecoration(
            counterText: "",
            hintText: widget.hintText,
            prefixIconColor: CustomColor.textThemeDarkSoftColor,
            prefixIcon: const Icon(EvaIcons.phone_outline),

            hintStyle: GoogleFonts.inter(
              color: CustomColor.textThemeDarkSoftColor,
              fontSize: 14,
            ),

            /// 📌 LABEL + TANDA * MERAH
            label: widget.labelText == null
                ? null
                : RichText(
                    text: TextSpan(
                      text: widget.labelText,
                      style: const TextStyle(
                        color: CustomColor.textThemeDarkSoftColor,
                        fontSize: 14,
                      ),
                      children: [
                        if (widget.requiredField == true)
                          const TextSpan(
                            text: ' *',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),

            suffix: widget.useValidator != true
                ? null
                : AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isPhone.value
                          ? CustomColor.secondaryColor
                          : Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPhone.value ? Icons.done : Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: borderColor, width: 1),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: isReadOnly
                    ? disabledBorderColor
                    : CustomColor.secondaryColor,
                width: isReadOnly ? 1 : 1.3,
              ),
            ),

            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide:
                  BorderSide(color: disabledBorderColor, width: 1),
            ),
          ),

          onChanged: (value) {
            isPhone(validateIndonesianPhone(value));
          },
        ),
      ),
    );
  }
}
