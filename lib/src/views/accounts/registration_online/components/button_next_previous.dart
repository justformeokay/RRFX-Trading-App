import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/views/accounts/registration_online/repository/regol_repository.dart';

class ButtonNextPrevious extends StatelessWidget {
  const ButtonNextPrevious({super.key, this.onPressed, bool? isLoading});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RegolRepository());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 50.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _buildModernButton(
              context,
              label: "Sebelumnya",
              icon: Icons.arrow_back_ios_new_rounded,
              isPrimary: false,
              isDark: isDark,
              isLoading: false,
              onPressed: () => Get.back(),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Obx(
              () => _buildModernButton(
                context,
                label: controller.isLoading.value ? "Processing..." : "Berikutnya",
                icon: Icons.arrow_forward_ios_rounded,
                isPrimary: true,
                isDark: isDark,
                isLoading: controller.isLoading.value,
                onPressed: controller.isLoading.value ? null : onPressed,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildModernButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isPrimary,
    required bool isDark,
    required bool isLoading,
    required VoidCallback? onPressed,
  }) {
    final isDisabled = onPressed == null;
    
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: !isDisabled
            ? [
                BoxShadow(
                  color: (isPrimary ? CustomColor.secondaryColor : Colors.grey)
                      .withOpacity(isDark ? 0.3 : 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: isPrimary
                  ? isDisabled
                      ? LinearGradient(
                          colors: [Colors.grey.shade400, Colors.grey.shade400],
                        )
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            CustomColor.secondaryColor,
                            CustomColor.secondaryColor.withOpacity(0.85),
                          ],
                        )
                  : LinearGradient(
                      colors: [
                        isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                        isDark
                            ? Colors.grey.shade700.withOpacity(0.85)
                            : Colors.grey.shade300.withOpacity(0.85),
                      ],
                    ),
              border: Border.all(
                color: isPrimary
                    ? Colors.transparent
                    : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isPrimary) ...[
                  Icon(
                    icon,
                    size: 18,
                    color: isPrimary
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.grey.shade700),
                  ),
                  const SizedBox(width: 8),
                ],
                if (isLoading)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isPrimary ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  )
                else
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isPrimary
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.grey.shade700),
                      letterSpacing: 0.3,
                    ),
                  ),
                if (isPrimary && !isLoading) ...[
                  const SizedBox(width: 8),
                  Icon(
                    icon,
                    size: 18,
                    color: Colors.white,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}