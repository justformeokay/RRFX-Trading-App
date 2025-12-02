import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/colors/default.dart';

class NameTextField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final bool? readOnly;
  final String? fieldName;
  final TextEditingController? controller;
  final bool? useValidator;
  final bool? requiredField; // ⭐ NEW
  final IconData? iconData;
  final int? maxLength;

  const NameTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.readOnly,
    this.fieldName,
    this.useValidator,
    this.iconData,
    this.maxLength, 
    this.requiredField,
  });

  @override
  State<NameTextField> createState() => _NameTextFieldState();
}

class _NameTextFieldState extends State<NameTextField> {
  RxBool isName = false.obs;
  RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    if ((widget.controller?.text.length ?? 0) >= 1) {
      isName(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isReadOnly = widget.readOnly ?? false;
    final colorScheme = Theme.of(context).colorScheme;
    final disabledBorderColor = colorScheme.onSurface.withOpacity(0.12);
    final borderColor = isReadOnly
        ? disabledBorderColor
        : CustomColor.textThemeDarkSoftColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Obx(
        () => isLoading.value
            ? const SizedBox()
            : TextFormField(
                readOnly: widget.readOnly ?? false,
                controller: widget.controller,
                maxLength: widget.maxLength ?? 100,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                autofillHints: const [AutofillHints.name],
                keyboardAppearance: Brightness.dark,
                keyboardType: TextInputType.name,
                style: GoogleFonts.inter(
                  color: isReadOnly
                      ? colorScheme.onSurface.withOpacity(0.3)
                      : colorScheme.onSurface,
                  fontSize: 15,
                ),
                cursorColor: CustomColor.secondaryColor,
                validator: (value) {
                  if (widget.useValidator == true) {
                    if (value == null || value.isEmpty) {
                      return 'Mohon isikan ${widget.fieldName}';
                    } else if (!isName.value) {
                      return 'Mohon isikan ${widget.fieldName} yang benar';
                    }
                    return null;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: widget.hintText,
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
                    color: CustomColor.textThemeDarkSoftColor,
                    fontSize: 14,
                  ),

                  /// 🔥 Label + Tanda wajib diisi *
                  label: RichText(
                    text: TextSpan(
                      text: widget.labelText ?? "",
                      style: TextStyle(
                        fontSize: 14,
                        color: isReadOnly
                            ? colorScheme.onSurface.withOpacity(0.3)
                            : Theme.of(context).textTheme.bodyMedium?.color,
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
                  suffix: widget.useValidator == false
                      ? const SizedBox()
                      : AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: isName.value == false
                                ? Colors.red
                                : CustomColor.secondaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: isName.value == false
                              ? const Icon(Icons.close,
                                  color: Colors.white, size: 16)
                              : const Icon(Icons.done,
                                  color: Colors.white, size: 16),
                        ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: borderColor
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: borderColor,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: borderColor,
                    ),
                  ),
                ),
                onChanged: (value) {
                  if (value.length > 2) {
                    isName(true);
                  } else {
                    isName(false);
                  }
                },
              ),
      ),
    );
  }
}
