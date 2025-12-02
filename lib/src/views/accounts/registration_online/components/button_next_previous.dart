import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/components/buttons/custom_buttons.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/views/accounts/registration_online/repository/regol_repository.dart';

class ButtonNextPrevious extends StatelessWidget {
  const ButtonNextPrevious({super.key, this.onPressed, bool? isLoading});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RegolRepository());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: CustomButtons.buildIconButton(iconColor: Colors.white, textColor: Colors.white, iconAlignment: IconAlignment.start, text: "Sebelumnya", onPressed: (){
              Get.back();
            }, icon: Icons.arrow_left, backgroundColor: Colors.grey),
          ),
          const SizedBox(width: 5.0),
          Expanded(child: Obx(
            () => CustomButtons.buildIconButton(text: controller.isLoading.value ? "Processing..." : "Berikutnya", onPressed: controller.isLoading.value ? null : onPressed, icon: Icons.arrow_right, textColor: Colors.black, iconColor: Colors.black, backgroundColor: controller.isLoading.value ? Colors.grey : CustomColor.secondaryColor),
          ))
        ],
      ),
    );
  }
}