import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/views/accounts/registration_online/components/check_box.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/agreement_section_controller.dart';

class AgreementSectionList extends StatelessWidget {
  final Map<String, List<dynamic>> sections;
  
  AgreementSectionController get controller {
    final ctrl = Get.find<AgreementSectionController>();
    // Initialize sections if needed
    ctrl.initSections(sections.length);
    return ctrl;
  }

  const AgreementSectionList({super.key, required this.sections});

  String _toRoman(int number) {
    switch (number) {
      case 1:
        return "i)";
      case 2:
        return "ii)";
      case 3:
        return "iii)";
      case 4:
        return "iv)";
      case 5:
        return "v)";
      default:
        return "$number)";
    }
  }

  @override
  Widget build(BuildContext context) {
    final sectionList = sections.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Daftar section
        Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sectionList.asMap().entries.map((entry) {
            final int sectionIndex = entry.key;
            final String sectionTitle = entry.value.key;
            final List<dynamic> subItems = entry.value.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Number + Title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${sectionIndex + 1}. ",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          sectionTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Sub Items
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: subItems.asMap().entries.map((subEntry) {
                      final int subIndex = subEntry.key + 1;
                      final dynamic subContent = subEntry.value;

                      // Jika subContent String biasa
                      if (subContent is String) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$subIndex. ",
                                style: const TextStyle(fontSize: 15),
                              ),
                              Expanded(
                                child: Text(
                                  subContent,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Jika subContent Map => nested roman items
                      else if (subContent is Map<String, List<String>>) {
                        final String nestedTitle = subContent.keys.first;
                        final List<String> nestedItems = subContent.values.first;

                        return Padding(
                          padding: const EdgeInsets.only(left: 16, top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "($subIndex) $nestedTitle",
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(height: 4),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: nestedItems.asMap().entries.map((nestedEntry) {
                                  final int romanIndex = nestedEntry.key + 1;
                                  final String nestedText = nestedEntry.value;

                                  return Padding(
                                    padding: const EdgeInsets.only(left: 17, bottom: 4),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${_toRoman(romanIndex)} ",
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                        Expanded(
                                          child: Text(
                                            nestedText,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              height: 1.4,
                                            ),
                                            textAlign: TextAlign.justify,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    }).toList(),
                  ),

                  const SizedBox(height: 8),

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
                              return Colors.transparent;
                            }),
                            checkColor: WidgetStateProperty.all(Colors.white),
                          ),
                        ),
                        child: GradientCheckbox(
                          value: controller.checkedSections[sectionIndex],
                          onChanged: (val) => controller.toggleSection(sectionIndex, val),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "Saya sudah membaca dan memahami *)",
                          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        )),
        // Align(
        //   alignment: Alignment.centerRight,
        //   child: TextButton.icon(
        //     onPressed: controller.checkAll,
        //     icon: Icon(
        //       controller.allChecked ? Icons.clear_all : Icons.done_all,
        //       color: CustomColor.secondaryColor,
        //     ),
        //     label: Text(
        //       controller.allChecked
        //           ? "Hapus Centang Semua"
        //           : "Centang Semua",
        //       style: TextStyle(
        //         color: CustomColor.secondaryColor,
        //         fontWeight: FontWeight.w600,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}