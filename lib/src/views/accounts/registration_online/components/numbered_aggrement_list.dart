import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/views/accounts/registration_online/components/check_box.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/agreement_controller.dart';

class NumberedAgreementList extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> items;
  final String agreementText;

  const NumberedAgreementList({
    super.key,
    this.title = '',
    this.subtitle = '',
    required this.items,
    this.agreementText = "Saya sudah membaca dan memahami",
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AgreementController>();
    controller.initList(items.length);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),

          // Subtitle
          if (subtitle.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Text(
                subtitle,
                style: const TextStyle(fontSize: 16.0),
              ),
            ),

          // List isi + checkbox
          ...items.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final text = entry.value;

            // Pisahkan bagian pertama (sebelum titik)
            String boldPart = text;
            String normalPart = "";
            final dotIndex = text.indexOf('.');

            if (dotIndex != -1 && dotIndex < text.length - 1) {
              boldPart = text.substring(0, dotIndex + 1);
              normalPart = text.substring(dotIndex + 1).trim();
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nomor + teks
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$index. ",
                        style: const TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: RichText(
                          textAlign: TextAlign.start,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 16.0,
                              height: 1.5,
                            ),
                            children: [
                              TextSpan(
                                text: "$boldPart ",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(
                                text: normalPart,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8.0),

                  // Checkbox
                  Row(
                    children: [
                      Theme(
                        data: Theme.of(context).copyWith(
                          checkboxTheme: CheckboxThemeData(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: const BorderSide(width: 1.5, color: Colors.grey),
                            fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
                              if (states.contains(WidgetState.selected)) {
                                return Theme.of(context).colorScheme.primary;
                              }
                              return Colors.transparent; // background transparan saat belum dicentang
                            }),
                            checkColor: WidgetStateProperty.all(Colors.white),
                          ),
                        ),
                        child: GradientCheckbox(
                          value: controller.checkedList[entry.key],
                          onChanged: (val) {
                            controller.toggleCheck(entry.key, val);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          agreementText,
                          style: TextStyle(
                            fontSize: 14.5,
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                controller.toggleAll(!controller.allChecked);
              },
              icon: Icon(
                controller.allChecked ? Icons.clear_all : Icons.done_all,
                color: CustomColor.secondaryColor,
              ),
              label: Text(
                controller.allChecked
                    ? "Hapus Centang Semua"
                    : "Centang Semua",
                style: TextStyle(
                  color: CustomColor.secondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }
}