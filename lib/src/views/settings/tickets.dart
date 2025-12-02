import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/alerts/default.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/controllers/utilities.dart';
import 'package:rrfx/src/helpers/handlers/image_picker.dart';
import 'package:rrfx/src/views/settings/send_image_chat.dart';

RxInt totalMessages = 0.obs;
class Tickets extends StatefulWidget {
  const Tickets({super.key, this.ticketCode, this.closed});
  final String? ticketCode;
  final bool? closed;

  @override
  State<Tickets> createState() => _TicketsState();
}

class _TicketsState extends State<Tickets> {

  RxBool isRefresh = false.obs;
  UtilitiesController utilitiesController = Get.find();
  Timer? _timer; // 👈 simpan timer biar bisa di-stop

  @override
  void initState() {
    super.initState();

    // load pertama kali
    Future.delayed(Duration.zero, () {
      _fetchMessages();
    });

    // polling tiap 5 detik
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchMessages();
    });
  }


  Future<void> _fetchMessages() async {
    // cukup panggil API tanpa ganggu isLoading
    final result = await utilitiesController.listMessageOfTicket(code: widget.ticketCode);
    if (result) {
      // replace object supaya Obx rebuild
      utilitiesController.messagesModel.refresh();
    }
  }


  @override
  void dispose() {
    _timer?.cancel(); // 👈 hentikan timer kalau halaman ditutup
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          forceMaterialTransparency: true,
          leading: GestureDetector(
            onTap: (){
              Get.back();
            },
            child: Icon(Icons.arrow_back_ios_rounded, size: 18)),
          actions: [
            widget.closed == true ? const SizedBox() : IconButton(
              onPressed: () {
                CustomAlert.alertDialogCustomInfo(
                  onTap: (){
                    utilitiesController.closeTicket(code: widget.ticketCode).then((result){
                      if(result){
                        CustomScaffoldMessanger.showAppSnackBar(
                          context,
                          message: "Berhasil menutup pesan",
                          type: SnackBarType.success,
                        );
                        utilitiesController.ticketList();
                      }
                      Get.back();
                    });
                    Get.back();
                  },
                  title: "Informasi",
                  message: "Apakah anda yakin menutup ticket?",
                  moreThanOneButton: true
                );
              },
              icon: Row(
                children: [
                  Icon(EvaIcons.close),
                  Text("Tutup Ticket", style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.red.shade400))
                ],
              )
            )
          ],
          titleSpacing: 0,
          leadingWidth: 35.0,
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).cardColor,
                backgroundImage: AssetImage('assets/images/logo-rrfx-3.png'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Admin RRFX", style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.circle, size: 8, color: Colors.green),
                        const SizedBox(width: 5),
                        Text("Online", style: GoogleFonts.inter(fontWeight: FontWeight.w300, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          centerTitle: false,
        ),
        body: Column(
  children: [
    // Bagian chat list
    Expanded(
      child: Obx(() {
        final messages = utilitiesController.messagesModel.value?.response ?? [];

        if (totalMessages.value == 0 || messages.isEmpty) {
          return const Center(
            child: Text('Start your conversation now :)'),
          );
        }

        return RefreshIndicator(
          strokeWidth: 3,
          color: CustomColor.secondaryColor,
          onRefresh: () async {
            final result = await utilitiesController.listMessageOfTicket(
              code: widget.ticketCode,
            );
            if (result) {
              // trigger rebuild
              utilitiesController.messagesModel.refresh();
              totalMessages(
                utilitiesController.messagesModel.value?.response?.length ?? 0,
              );
            }
          },
          child: ListView.builder(
            reverse: false,
            itemCount: messages.length,
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            itemBuilder: (context, index) {
              final msg = messages[index];
              final isMember = msg.type == "member";

              return Padding(
                padding: EdgeInsets.only(
                  left: isMember ? MediaQuery.of(context).size.width / 2.5 : 0,
                  right: isMember ? 0 : MediaQuery.of(context).size.width / 2.5,
                ),
                child: ChatBubble(
                  elevation: 0.0,
                  padding: EdgeInsets.zero,
                  alignment: isMember ? Alignment.bottomRight : Alignment.bottomLeft,
                  backGroundColor:
                      isMember ? Colors.green.shade700 : Colors.grey.shade300,
                  clipper: ChatBubbleClipper6(
                    type: isMember
                        ? BubbleType.sendBubble
                        : BubbleType.receiverBubble,
                  ),
                  child: Column(
                    crossAxisAlignment: isMember
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      // Nama
                      Padding(
                        padding: EdgeInsets.only(
                          top: 7.0,
                          left: isMember ? 0 : 20.0,
                          right: isMember ? 20.0 : 0,
                        ),
                        child: Text(
                          isMember ? "Saya" : "Admin",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            color: isMember ? Colors.white : Colors.black45,
                          ),
                        ),
                      ),
                      Divider(
                        color: isMember ? Colors.white38 : Colors.black12,
                        indent: isMember ? 0 : 8.0,
                      ),
                      // Isi pesan
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: msg.content != null
                            ? msg.content!.contains("https://allmediaindo")
                                ? CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {},
                                    child: Text(
                                      "Lihat Gambar",
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w700,
                                        color: isMember
                                            ? CustomColor.defaultColor
                                            : Colors.black54,
                                      ),
                                    ),
                                  )
                                : Text(
                                    msg.content ?? "",
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isMember
                                          ? Colors.white
                                          : Colors.black54,
                                    ),
                                  )
                            : const SizedBox(),
                      ),
                      // Waktu
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 18.0,
                          right: isMember ? 20.0 : 0,
                          left: isMember ? 0 : 20.0,
                        ),
                        child: Text(
                          msg.time ?? "",
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w300,
                            color: isMember ? Colors.white : Colors.black45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    ),

    // Bagian input message bar (hanya muncul kalau tiket belum ditutup)
    widget.closed == true ? const SizedBox() : _MessageBar(widget.ticketCode),
  ],
)
      ),
    );
  }
}


/// Set of widget that contains TextField and Button to submit message
class _MessageBar extends StatefulWidget {
  const _MessageBar(this.code);
  final String? code;

  @override
  State<_MessageBar> createState() => _MessageBarState();
}

class _MessageBarState extends State<_MessageBar> {
  late final TextEditingController _textController;
  RxString urlPhoto = "".obs;
  RxBool isLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Theme.of(context).cardColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    CustomMaterialBottomSheets.defaultBottomSheet(
                      context,
                      size: size,
                      isScrolledController: false,
                      title: "Pilih Opsi",
                      children: [
                        ListTile(
                          onTap: () async {
                            Get.back();
                            urlPhoto(await CustomImagePicker.pickImageFromCameraAndReturnUrl(useCamera: true));
                            Get.to(() => SendImageChat(imageURL: urlPhoto.value));
                          },
                          leading: const Icon(Bootstrap.camera),
                          title: const Text("Kamera"),
                        ),
                        ListTile(
                          onTap: () async {
                            Get.back();
                            urlPhoto(await CustomImagePicker.pickImageFromCameraAndReturnUrl());
                            Get.to(() => SendImageChat(imageURL: urlPhoto.value));
                          },
                          leading: const Icon(Bootstrap.image),
                          title: const Text("Gallery"),
                        ),
                      ]
                    );
                  },
                  tooltip: "Attach File",
                  icon: const Icon(HeroIcons.paper_clip),
                ),
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    maxLines: 4,
                    minLines: 1,
                    autofocus: false,
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.all(8),
                    ),
                  ),
                ),
                Obx(
                  () => IconButton(
                    onPressed: () {
                      if (_textController.text != "") {
                        isLoading(true);
                        utilitiesController.sendMessage(
                          code: widget.code,
                          message: _textController.text,
                        ).then((result) {
                          if (!result) {
                            CustomScaffoldMessanger.showAppSnackBar(
                              context,
                              message: utilitiesController.responseMessage.value,
                            );
                          }
                          _textController.clear();
                          isLoading(false);

                          utilitiesController.listMessageOfTicket(
                            code: widget.code,
                          ).then((result) {
                            if (result) {
                              totalMessages(
                                utilitiesController.messagesModel.value?.response?.length ?? 0,
                              );
                              utilitiesController.messagesModel.refresh(); // supaya Obx rebuild
                            }
                          });
                        });
                      }
                    },
                    tooltip: "Send Message",
                    icon: isLoading.value
                        ? const SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              color: CustomColor.defaultColor,
                            ),
                          )
                        : const Icon(Bootstrap.send),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  UtilitiesController utilitiesController = Get.find();

  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
