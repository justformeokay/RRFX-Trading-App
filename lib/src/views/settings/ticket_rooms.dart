import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
import 'package:rrfx/src/components/buttons/custom_buttons.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/controllers/utilities.dart';
import 'package:rrfx/src/helpers/variables/random_color.dart';
import 'package:rrfx/src/views/settings/tickets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class TicketRooms extends StatefulWidget {
  const TicketRooms({super.key});

  @override
  State<TicketRooms> createState() => _TicketRoomsState();
}

class _TicketRoomsState extends State<TicketRooms> {
  final UtilitiesController utilitiesController = Get.find();
  final RxInt selectedIndex = 0.obs;
  final RxBool isLoadingCreate = false.obs;

  final RxList<String> subjectType = [
    "Masalah Teknis/Bug",
    "Pertanyaan/Informasi Umum",
    "Masalah Pembayaran/Billing",
    "Permintaan/Perubahan Akun",
    "Saran/Umpan Balik"
  ].obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      utilitiesController.ticketList().then((success) {
        if (!success) {
          CustomScaffoldMessanger.showAppSnackBar(
            context,
            message: utilitiesController.responseMessage.value,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: CustomAppBar.defaultAppBar(
        autoImplyLeading: true,
        title: "Daftar Ticket",
      ),
      body: RefreshIndicator(
        color: CustomColor.secondaryColor,
        onRefresh: () async => utilitiesController.ticketList(),
        child: Obx(() {
          final data = utilitiesController.listTicketModel.value;
          final tickets = data?.response;

          /// === LOADING STATE (SHIMMER) ===
          if (data == null) {
            return ListView.builder(
              itemCount: 6,
              padding: const EdgeInsets.only(top: 10),
              itemBuilder: (_, __) => shimmerTicketItem(),
            );
          }

          /// === EMPTY STATE ===
          if (tickets!.isEmpty) {
            return Center(
              child: Text(
                "Start new conversation 🙂",
                style: GoogleFonts.inter(fontSize: 15),
              ),
            );
          }

          /// === LIST DATA ===
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: tickets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final item = tickets[i];

              return GestureDetector(
                onTap: () {
                  Get.to(() => Tickets(
                    ticketCode: item.code,
                    closed: item.status == "closed",
                  ));
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                        color: Colors.black.withOpacity(0.06),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        height: 48,
                        width: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              CustomColorPicker.getRandomColor(),
                              CustomColorPicker.getRandomColor().withOpacity(.7),
                            ],
                          ),
                        ),
                        child: Text(
                          "${i + 1}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      /// TEXT INFO
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.subject ?? "-",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.createdAt != null
                                  ? DateFormat('dd MMM yyyy, HH:mm')
                                      .format(DateTime.parse(item.createdAt!))
                                  : "-",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// STATUS BADGE
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: item.status == "closed"
                              ? Colors.red.withOpacity(0.15)
                              : Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.status == "closed" ? "Closed" : "Open",
                          style: GoogleFonts.inter(
                            color: item.status == "closed"
                                ? Colors.red
                                : Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),

      /// FLOATING BUTTON
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        backgroundColor: CustomColor.secondaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.getString("accessToken");

          CustomMaterialBottomSheets.defaultBottomSheet(
            context,
            size: size,
            title: "Pilih Subjek Ticket",
            children: [
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  subjectType.length,
                  (i) => Obx(
                    () => ChoiceChip(
                      shape: const StadiumBorder(),
                      label: Text(subjectType[i]),
                      selectedColor: CustomColor.secondaryColor,
                      backgroundColor: Theme.of(context).chipTheme.backgroundColor,
                      selected: selectedIndex.value == i,
                      onSelected: (_) => selectedIndex.value = i,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Obx(() {
                return CustomButtons.buildFilledButton(
                  text: isLoadingCreate.value
                      ? "Membuat Ticket..."
                      : "Mulai Tiket Sekarang",
                  onPressed: () {
                    isLoadingCreate.value = true;

                    utilitiesController
                        .createTicket(subject: subjectType[selectedIndex.value])
                        .then((success) {
                      isLoadingCreate.value = false;

                      if (success) {
                        utilitiesController.ticketList().then((_) {
                          Get.back();
                          final newTicket = utilitiesController.listTicketModel.value!.response!.first;
                          Get.to(() => Tickets(
                            ticketCode: newTicket.code,
                            closed: newTicket.status == "closed",
                          ));
                        });
                      }
                    });
                  },
                );
              }),
            ],
          );
        },
      ),
    );
  }

  /// ===== SHIMMER SKELETON UI =====
  Widget shimmerTicketItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
        ),
      ),
    );
  }
}
