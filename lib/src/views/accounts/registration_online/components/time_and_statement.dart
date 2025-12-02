import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/statement_controller.dart';

class TimeAndStatement extends StatelessWidget {
  const TimeAndStatement({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StatementController());
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Obx(
                () => Row(
                  children: [
                    Checkbox(
                      fillColor: WidgetStatePropertyAll(CustomColor.secondaryBackground.withOpacity(0.3)),
                      checkColor: CustomColor.secondaryColor,
                      side: WidgetStateBorderSide.resolveWith((Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return const BorderSide(color: Colors.black45); // tetap tampil meski dicentang
                        }
                        return const BorderSide(color: Colors.black45); // tidak dicentang
                      }),
                      value: controller.selectedStatement.value == true ? true : false,
                      onChanged: (value) => controller.selectedStatement.value = !controller.selectedStatement.value,
                    ),
                    Text("YA")
                  ],
                ),
              ),
              Obx(
                () => Row(
                  children: [
                    Checkbox(
                      fillColor: WidgetStatePropertyAll(CustomColor.secondaryBackground.withOpacity(0.3)),
                      checkColor: CustomColor.secondaryColor,
                      side: WidgetStateBorderSide.resolveWith((Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return const BorderSide(color: Colors.black45); // tetap tampil meski dicentang
                        }
                        return const BorderSide(color: Colors.black45); // tidak dicentang
                      }),
                      value: controller.selectedStatement.value == false ? true : false,
                      onChanged: (value) => controller.selectedStatement.value = !controller.selectedStatement.value,
                    ),
                    Text("TIDAK")
                  ],
                ),
              ),
            ],
          ),
          StreamBuilder<DateTime>(
            stream: controller.timeStream(),
            builder: (context, snapshot) {
              final now = snapshot.data ?? DateTime.now();
              return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Menerima pada Tanggal", maxLines: 1, overflow: TextOverflow.clip),
                    Text(
                      DateFormat('yyyy-MM-dd hh:mm:ss').format(now),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1, overflow: TextOverflow.clip
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}