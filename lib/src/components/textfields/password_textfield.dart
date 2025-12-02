import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/colors/default.dart';

class PasswordTextField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final String? fieldName;
  final bool? readOnly;
  final bool? notUseValidator; // true = validator dimatikan
  final bool? requiredField;   // ← NEW
  final TextEditingController? controller;

  const PasswordTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.readOnly,
    this.fieldName,
    this.notUseValidator,
    this.requiredField = false,   // default false
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  RxBool show = true.obs;

  final allowedSymbols = "!@#\$&*~/";

  bool _containsInvalidSymbols(String value) {
    final invalid = value
        .split("")
        .where((char) =>
            !RegExp(r'[A-Za-z0-9]').hasMatch(char) &&
            !allowedSymbols.contains(char))
        .toList();
    return invalid.isNotEmpty;
  }

  String? _passwordValidator(String? value) {
    if (widget.notUseValidator == true) return null;

    final pass = value ?? "";

    if (pass.isEmpty) {
      return "Mohon inputkan ${widget.fieldName ?? 'kata sandi'}";
    }

    if (pass.length < 8) {
      return "Kata sandi harus minimal 8 karakter";
    }

    if (_containsInvalidSymbols(pass)) {
      return "Terdapat simbol yang tidak diperbolehkan.\n"
          "Simbol yang didukung: $allowedSymbols";
    }

    // Regex lengkap
    RegExp regex = RegExp(
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~/]).{8,}$',
    );

    if (!regex.hasMatch(pass)) {
      return "Harus ada huruf besar, huruf kecil, angka, dan simbol ($allowedSymbols)";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isReadOnly = widget.readOnly ?? false;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Obx(
        () => TextFormField(
          readOnly: widget.readOnly ?? false,
          controller: widget.controller,
          obscureText: show.value,
          cursorColor: CustomColor.secondaryColor,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          autofillHints: const [AutofillHints.password],
          keyboardAppearance: Brightness.dark,
          validator: _passwordValidator,

          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: GoogleFonts.inter(
              color: CustomColor.textThemeDarkSoftColor.withOpacity(0.3),
              fontSize: 12,
            ),

            /// --------------------------------------------------
            /// LABEL + REQUIRED FIELD ("*")
            /// --------------------------------------------------
            label: RichText(
              text: TextSpan(
                text: widget.labelText,
                style: TextStyle(
                  color: isReadOnly
                      ? colorScheme.onSurface.withValues(alpha: 0.7)
                      : CustomColor.textThemeDarkSoftColor,
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

            prefixIcon: const Icon(
              EvaIcons.lock_outline,
              color: CustomColor.textThemeDarkSoftColor,
            ),

            // Eye toggle button
            suffixIcon: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => show.value = !show.value,
              child: Icon(
                show.value ? HeroIcons.eye : HeroIcons.eye_slash,
                color: CustomColor.textThemeDarkSoftColor,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: CustomColor.secondaryColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: CustomColor.textThemeDarkSoftColor),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: CustomColor.textThemeDarkSoftColor),
            ),
          ),
        ),
      ),
    );
  }
}
