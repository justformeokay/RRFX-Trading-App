import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/colors/default.dart';

class NameTextFieldNewVersion extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final bool? readOnly;
  final String? fieldName;
  final TextEditingController? controller;
  final bool? useValidator;
  final bool requiredField;
  final IconData? iconData;
  final int? maxLength;
  final bool? useStringOnly;

  const NameTextFieldNewVersion({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.readOnly,
    this.fieldName,
    this.useValidator,
    this.iconData,
    this.maxLength,
    this.requiredField = false,
    this.useStringOnly,
  });

  @override
  State<NameTextFieldNewVersion> createState() =>
      _NameTextFieldNewVersionState();
}

class _NameTextFieldNewVersionState extends State<NameTextFieldNewVersion> {
  final RegExp stringOnlyRegex = RegExp(r"^[a-zA-Z ]+$");
  final RegExp stringAndNumberRegex = RegExp(r"^[a-zA-Z0-9 ]+$");
  RxBool isName = false.obs;
  RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();

    final initialText = widget.controller?.text;
    if (widget.useValidator == true && (initialText?.isNotEmpty ?? false)) {
      _updateValidationStatus(initialText!);
    }
  }

  void _updateValidationStatus(String value) {
    if (widget.useValidator == true) {
      final useStringOnly = widget.useStringOnly ?? false;
      final regex = useStringOnly ? stringOnlyRegex : stringAndNumberRegex;
      if (value.length > 2 && regex.hasMatch(value)) {
        isName(true);
      } else {
        isName(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isReadOnly = widget.readOnly ?? false;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isReadOnly ? colorScheme.surfaceVariant.withOpacity(isDark ? 0.25 : 0.5) : Colors.transparent;
    final disabledBorderColor = colorScheme.onSurface.withOpacity(isDark ? 0.25 : 0.12);
    final borderColor = isReadOnly ? disabledBorderColor : CustomColor.textThemeDarkSoftColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Obx(
        () => isLoading.value
            ? const SizedBox()
            : TweenAnimationBuilder<Color?>(
                tween: ColorTween(
                  end: isReadOnly ? disabledBorderColor : CustomColor.textThemeDarkSoftColor,
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                builder: (context, animatedColor, _) {
                  final aBorderColor = animatedColor ?? borderColor;
                  return TextFormField(
                readOnly: isReadOnly,
                showCursor: !isReadOnly,
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
                ),

                cursorColor: CustomColor.secondaryColor,

                validator: (value) {
                  if (widget.useValidator == true) {
                    if (value == null || value.isEmpty) {
                      return "Mohon isikan ${widget.fieldName}";
                    }
                    final useStringOnly = widget.useStringOnly ?? false;
                    final regex = useStringOnly ? stringOnlyRegex : stringAndNumberRegex;
                    if (!regex.hasMatch(value)) {
                      final errorMsg = useStringOnly
                          ? "Hanya boleh mengandung huruf dan spasi."
                          : "Hanya boleh mengandung huruf, angka, dan spasi.";
                      return errorMsg;
                    }
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
                          : colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                  ),

                  hintStyle: GoogleFonts.inter(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    fontSize: 14,
                  ),

                  // ⭐ Label + tanda bintang
                  label: RichText(
                    text: TextSpan(
                      text: widget.labelText ?? "",
                      style: TextStyle(
                        color: isReadOnly
                            ? colorScheme.onSurface.withOpacity(0.3)
                            : Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 14,
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
                  ),

                  filled: isReadOnly,
                  fillColor: fillColor,

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: aBorderColor, width: isReadOnly ? 0.8 : 1.2),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: isReadOnly
                          ? aBorderColor
                          : CustomColor.secondaryColor,
                      width: isReadOnly ? 0.8 : 1.3,
                    ),
                  ),

                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide:
                        BorderSide(color: aBorderColor, width: 0.8),
                  ),
                ),

                onChanged: (value) {
                  // Filter berdasarkan useStringOnly
                  final useStringOnly = widget.useStringOnly ?? false;
                  final pattern = useStringOnly ? r'[^a-zA-Z ]' : r'[^a-zA-Z0-9 ]';
                  String filtered = value.replaceAll(RegExp(pattern), '');
                  
                  // Update controller jika ada perubahan
                  if (filtered != value) {
                    widget.controller?.value = TextEditingValue(
                      text: filtered,
                      selection: TextSelection.collapsed(offset: filtered.length),
                    );
                  }
                  
                  _updateValidationStatus(filtered);
                },
              );
                },
              ),
      ),
    );
  }
}
