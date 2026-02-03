import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/colors/default.dart';

class EmailTextField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final String? fieldName;
  final bool? readOnly;
  final bool? useCustomOnchange;
  final bool? useValidator;
  final bool? requiredField;
  final Function(String value)? onChange;
  final TextEditingController? controller;

  const EmailTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.readOnly,
    this.fieldName,
    this.useValidator,
    this.useCustomOnchange,
    this.onChange,
    this.requiredField = false,
  });

  @override
  State<EmailTextField> createState() => _EmailTextFieldState();
}

class _EmailTextFieldState extends State<EmailTextField> {
  RxBool isEmailValid = false.obs;
  RxBool isLoading = false.obs;

  bool _validateEmail(String value) {
    final regex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$');
    return regex.hasMatch(value.trim());
  }

  @override
  Widget build(BuildContext context) {
    final bool isReadOnly = widget.readOnly ?? false;
    final colorScheme = Theme.of(context).colorScheme;

    final fillColor = isReadOnly
        ? colorScheme.surfaceVariant.withOpacity(
            Theme.of(context).brightness == Brightness.dark ? 0.25 : 0.5)
        : Colors.transparent;

    final disabledBorderColor = colorScheme.onSurface.withOpacity(0.12);
    final borderColor = isReadOnly
        ? disabledBorderColor
        : CustomColor.textThemeDarkSoftColor;
        
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Obx(() {
        if (isLoading.value) return const SizedBox();
        return TextFormField(
          readOnly: isReadOnly,
          controller: widget.controller,
          keyboardType: TextInputType.emailAddress,
          cursorColor: CustomColor.secondaryColor,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          autofillHints: const [AutofillHints.email],

          style: GoogleFonts.inter(
            color: isReadOnly
                ? colorScheme.onSurface.withOpacity(0.3)
                : colorScheme.onSurface,
            fontSize: 15,
          ),

          validator: (value) {
            if (widget.useValidator == true) {
              if (value == null || value.trim().isEmpty) {
                return "Mohon isikan ${widget.fieldName}";
              }
              if (!_validateEmail(value)) {
                return "Format email tidak valid";
              }
            }
            return null;
          },

          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: GoogleFonts.inter(
              color: Theme.of(context).textTheme.bodyMedium?.color
                  ?.withOpacity(0.6),
              fontSize: 14,
            ),

            /// ------------------------------------------
            /// LABEL + REQUIRED FIELD (*)
            /// ------------------------------------------
            label: RichText(
              text: TextSpan(
                text: widget.labelText,
                style: TextStyle(
                  color: isReadOnly
                      ? colorScheme.onSurface.withOpacity(0.3)
                      : CustomColor.textThemeDarkSoftColor,
                  fontSize: 14,
                ),
                children: [
                  if (widget.requiredField == true)
                    const TextSpan(
                      text: '',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),

            prefixIcon: SizedBox(
              width: 30,
              child: Icon(
                EvaIcons.email_outline,
                color: CustomColor.textThemeDarkSoftColor,
              ),
            ),

            filled: isReadOnly,
            fillColor: fillColor,

            suffix: widget.useValidator == true && !isReadOnly
                ? AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isEmailValid.value
                          ? CustomColor.secondaryColor
                          : Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isEmailValid.value ? Icons.done : Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  )
                : null,

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: borderColor,
                width: isReadOnly ? 0.8 : 1.1,
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
              borderSide: BorderSide(
                color: borderColor,
                width: 0.8,
              ),
            ),
          ),

          onChanged: widget.useCustomOnchange == true
              ? widget.onChange
              : (value) {
                  isEmailValid(_validateEmail(value));
                },
        );
      }),
    );
  }
}
