import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/colors/default.dart';

class DescriptiveTextField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final bool? readOnly;
  final String? fieldName;
  final TextEditingController? controller;
  final bool? useValidator;
  final bool requiredField; // ⭐ NEW
  final IconData? iconData;

  const DescriptiveTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.readOnly,
    this.fieldName,
    this.useValidator,
    this.iconData,
    this.requiredField = false, // ⭐ NEW
  });

  @override
  State<DescriptiveTextField> createState() => _DescriptiveTextFieldState();
}

class _DescriptiveTextFieldState extends State<DescriptiveTextField> {
  RxBool isValid = false.obs;
  RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();

    final text = widget.controller?.text ?? "";
    if (text.trim().length > 2) {
      isValid(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isReadOnly = widget.readOnly ?? false;
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
          minLines: 5,
          maxLines: 5,
          readOnly: isReadOnly,
          controller: widget.controller,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          keyboardType: TextInputType.multiline,
          cursorColor: CustomColor.secondaryColor,

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
              if (!isValid.value) {
                return "Mohon isikan ${widget.fieldName} yang benar";
              }
            }
            return null;
          },

          decoration: InputDecoration(
            floatingLabelAlignment: FloatingLabelAlignment.start,
            alignLabelWithHint: true,

            prefixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: Icon(
                widget.iconData ?? EvaIcons.edit_outline,
                
                // ⭐ Warna icon adaptif dengan theme
                color: isReadOnly
                    ? colorScheme.onSurface.withOpacity(0.4)
                    : colorScheme.onSurfaceVariant,
              ),
            ),

            hintText: widget.hintText,
            hintStyle: GoogleFonts.inter(
              color: CustomColor.textThemeDarkSoftColor.withOpacity(0.7),
              fontSize: 14,
            ),

            // ⭐ Label dengan tanda wajib (*) merah
            label: RichText(
              text: TextSpan(
                text: widget.labelText ?? "",
                style: TextStyle(
                  fontSize: 14,
                  color: isReadOnly
                      ? colorScheme.onSurface.withOpacity(0.3)
                      : CustomColor.textThemeDarkSoftColor,
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
            fillColor: fillColor,

            suffix: widget.useValidator == true && !isReadOnly
                ? AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color:
                          isValid.value ? CustomColor.secondaryColor : Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isValid.value ? Icons.done : Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  )
                : const SizedBox(),

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
                color:
                    isReadOnly ? borderColor : CustomColor.secondaryColor,
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

          onChanged: (value) {
            isValid(value.trim().length > 2);
          },
        );
      }),
    );
  }
}
