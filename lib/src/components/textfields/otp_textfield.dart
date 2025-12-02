import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/colors/default.dart';

class OTPTextField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final String? fieldName;
  final bool? readOnly;
  final bool requiredField; // ⭐ NEW
  final TextEditingController? controller;
  const OTPTextField({super.key, this.hintText, this.labelText, this.controller, this.readOnly, this.fieldName, this.requiredField = false});

  @override
  State<OTPTextField> createState() => _OTPTextFieldState();
}

class _OTPTextFieldState extends State<OTPTextField> {
  RxBool isPhone = false.obs;
  RxBool isLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    final isReadOnly = widget.readOnly ?? false;
    final colorScheme = Theme.of(context).colorScheme;
    final disabledBorderColor = colorScheme.onSurface.withOpacity(0.12);
    final borderColor = isReadOnly ? disabledBorderColor : CustomColor.textThemeDarkSoftColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Obx(
        () => isLoading.value ? const SizedBox() : TextFormField(
          readOnly: widget.readOnly ?? false,
          controller: widget.controller,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          autofillHints: const [AutofillHints.oneTimeCode],
          keyboardAppearance: Brightness.dark,
          keyboardType: TextInputType.number,
          cursorColor: CustomColor.secondaryColor,
          style: GoogleFonts.inter(
            color: isReadOnly
                ? colorScheme.onSurface.withOpacity(0.3)
                : colorScheme.onSurface,
            fontSize: 15,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Mohon isikan ${widget.fieldName}';
            }else if(!isPhone.value){
              return 'Mohon isikan ${widget.fieldName} yang benar';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: SizedBox(
              width: 30,
              child: Icon(
                CupertinoIcons.number_circle,
                color: isReadOnly ? colorScheme.onSurfaceVariant.withOpacity(0.3) : colorScheme.onSurfaceVariant,
              ),
            ),
            hintStyle: GoogleFonts.inter(
              color: CustomColor.textThemeDarkSoftColor.withOpacity(0.3),
              fontSize: 14,
            ),
            label: RichText(
              text: TextSpan(
                text: widget.labelText ?? "",
                style: TextStyle(
                  fontSize: 14,
                  color: isReadOnly ? colorScheme.onSurface.withOpacity(0.3) : Theme.of(context).textTheme.bodyMedium?.color,
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
            filled: false,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                  color: borderColor,
                  width: isReadOnly ? 0.8 : 1.2,
                ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: borderColor,
                width: isReadOnly ? 0.8 : 1.2,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: borderColor,
                width: isReadOnly ? 0.8 : 1.2,
              ),
            )
          ),
          onChanged: (value) {
            if(value.length > 3){
              isPhone(true);
            }else{
              isPhone(false);
            }
          },
        ),
      ),
    );
  }
}