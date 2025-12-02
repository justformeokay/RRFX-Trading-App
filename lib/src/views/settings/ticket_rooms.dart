import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/buttons/custom_buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/controllers/utilities.dart';
import 'package:rrfx/src/helpers/variables/random_color.dart';
import 'package:rrfx/src/views/settings/tickets.dart';

class TicketRooms extends StatefulWidget {
  const TicketRooms({super.key});

  @override
  State<TicketRooms> createState() => _TicketRoomsState();
}

class _TicketRoomsState extends State<TicketRooms> {
  UtilitiesController utilitiesController = Get.find();
  RxInt selectedIndex = 1.obs;
  RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    // Menggunakan addPostFrameCallback lebih eksplisit dan direkomendasikan daripada Future.delayed(Duration.zero)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      utilitiesController.ticketList().then((result) {
        if (!result) {
          CustomScaffoldMessanger.showAppSnackBar(context,message: utilitiesController.responseMessage.value,
          );
          return;
        }
      });
    });
  }

  RxList subjectType = [
    "Masalah Teknis/Bug",
    "Pertanyaan/Informasi Umum",
    "Masalah Pembayaran/Billing",
    "Permintaan/Perubahan Akun",
    "Saran/Umpan Balik"
  ].obs;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBar.defaultAppBar(
        autoImplyLeading: true,
        title: "Daftar Ticket"
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await utilitiesController.ticketList();
        },
        child: Obx(
            () {
              final tickets = utilitiesController.listTicketModel.value?.response;

              if(tickets?.isEmpty == true){
                return SizedBox(
                  width: double.infinity,
                  height: size.width * 1.5,
                  child: Center(child: Text("Start new conversation :)"))
                );
              }

              return ListView.builder(
                itemCount: tickets?.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: (){
                      Get.to(() => Tickets(ticketCode: utilitiesController.listTicketModel.value?.response?[index].code, closed: utilitiesController.listTicketModel.value?.response?[index].status == "open" ? false : true));
                    },
                    leading: CircleAvatar(
                      backgroundColor: CustomColorPicker.getRandomColor(),
                      child: Text("${index+1}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),),
                    ),
                    title: Text(
                      utilitiesController.listTicketModel.value?.response?[index].subject ?? "-",
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: utilitiesController.listTicketModel.value?.response?[index].status == "closed" ? Text("Closed", style: GoogleFonts.inter(fontWeight: FontWeight.w300)) : Text("Opened", style: GoogleFonts.inter(fontWeight: FontWeight.w300)),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(Icons.circle, color: utilitiesController.listTicketModel.value?.response?[index].status == "closed" ? Colors.red : Colors.green, size: 12.0),
                        const SizedBox(height: 4.0),
                        Text(utilitiesController.listTicketModel.value?.response?[index].createdAt != null ? DateFormat('dd MMM yyyy').add_jms().format(DateTime.parse(utilitiesController.listTicketModel.value!.response![index].createdAt!)) : "-", style: GoogleFonts.inter(fontWeight: FontWeight.w300)),
                      ],
                    ),
                  );
                },
              );
            }
          ),
        ),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        elevation: 0.0,
        isExtended: true,
        onPressed: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.getString("accessToken");
          CustomMaterialBottomSheets.defaultBottomSheet(
            context,
            size: size,
            title: "Pilih Subjek Ticket",
            children: [
              const SizedBox(height: 10.0),
              Wrap(
                spacing: 5.0,
                children:
                List<Widget>.generate(subjectType.length, (int index) {
                  return Obx(
                    () => ChoiceChip(
                      selectedColor: CustomColor.secondaryColor,
                      backgroundColor: Theme.of(context).chipTheme.backgroundColor,
                      shape: StadiumBorder(),
                      label: Text('${subjectType[index]}'),
                      selected: selectedIndex.value == index,
                      onSelected: (bool selected) {
                        selectedIndex.value = selected ? index : 0;
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10.0),
              Obx(
                () => CustomButtons.buildIconButton(
                  icon: HeroIcons.plus_circle,
                  iconColor: Colors.black,
                  textColor: Colors.black,
                  text: isLoading.value ? "Membuat Ticket..." : "Mulai Tiket Sekarang",
                  onPressed: (){
                    isLoading(true);
                    utilitiesController.createTicket(subject: subjectType[selectedIndex.value]).then((result) {
                      if(result){
                        utilitiesController.ticketList().then((list){
                          Get.back();
                          String? code = utilitiesController.listTicketModel.value?.response?[0].code;
                          String? status = utilitiesController.listTicketModel.value?.response?[0].status;
                          Get.to(() => Tickets(ticketCode: code, closed: status == "open" ? false : true));
                        });
                      }
                      isLoading(false);
                    });
                  }
                ),
              ),
            ]
          );
        },
        backgroundColor: CustomColor.secondaryColor,
        child: Icon(Bootstrap.chat_right_text),
      ),
    );
  }
}
