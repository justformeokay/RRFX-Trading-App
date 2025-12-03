import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
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
  final UtilitiesController utilitiesController = Get.find();
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchMessages());

    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _fetchMessages());
  }

  Future<void> _fetchMessages() async {
    final ok = await utilitiesController.listMessageOfTicket(code: widget.ticketCode);
    if (ok) {
      utilitiesController.messagesModel.refresh();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    Future.delayed(const Duration(milliseconds: 250), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool isImageUrl(String url) {
    final l = url.toLowerCase();
    return l.endsWith(".jpg") || l.endsWith(".jpeg") || l.endsWith(".png") || l.endsWith(".webp");
  }

  bool isUrl(String text) {
    final urlPattern = r'((https?:\/\/)|(www\.))[^\s]+';
    return RegExp(urlPattern).hasMatch(text);
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            Expanded(
              child: Obx(() {
                final messages = utilitiesController.messagesModel.value?.response ?? [];

                if (messages.isEmpty) {
                  return const Center(
                    child: Text("Start your conversation now :)"),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final m = messages[i];
                    return _animatedBubble(
                      MessageBubble(
                        message: m.content ?? "",
                        date: m.date ?? "",
                        time: m.time ?? "",
                        isUser: m.type == "member",
                        contentType: m.contentType ?? "message",
                      )
                    );
                  },
                );
              }),
            ),

            widget.closed == true ? const SizedBox() : _MessageBar(widget.ticketCode),
          ],
        ),
      ),
    );
  }

  PreferredSize _buildAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: AppBar(
              elevation: 0,
              forceMaterialTransparency: true,
              backgroundColor: (isDark ? Colors.white10 : Colors.white.withOpacity(0.6)),
              automaticallyImplyLeading: false,
              leadingWidth: 50,
              titleSpacing: 0,
              leading: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  margin: const EdgeInsets.only(left: 8, right: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isDark ? Colors.white12 : Colors.grey.shade200)
                        .withOpacity(.5),
                  ),
                  child: const Center(
                    child: Icon(Icons.arrow_back_ios_rounded, size: 18),
                  ),
                ),
              ),

              title: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Theme.of(context).cardColor,
                    backgroundImage:
                        const AssetImage('assets/images/logo-rrfx-3.png'),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Admin RRFX",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.circle,
                                size: 8, color: Colors.green),
                            const SizedBox(width: 6),
                            Text(
                              "Online",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w300,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              actions: [
                widget.closed == true
                    ? const SizedBox()
                    : Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: (isDark
                                  ? Colors.white10
                                  : Colors.grey.shade200)
                              .withOpacity(.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            CustomAlert.alertDialogCustomInfo(
                              onTap: () {
                                utilitiesController
                                    .closeTicket(code: widget.ticketCode)
                                    .then((result) {
                                  if (result) {
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
                              message:
                                  "Apakah anda yakin menutup ticket?",
                              moreThanOneButton: true,
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.close_rounded,
                                  color: Colors.red.shade400),
                              const SizedBox(width: 4),
                              Text(
                                "Tutup",
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.red.shade400,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔥 Animasi ala WhatsApp — Fade + slide up
  Widget _animatedBubble(Widget child) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 230),
      builder: (context, value, widget) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: widget,
          ),
        );
      },
      child: child,
    );
  }
}
  
class FullscreenImage extends StatelessWidget {
  final String url;
  const FullscreenImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Get.back(),
        child: Center(
          child: Hero(tag: url, child: Image.network(url)),
        ),
      ),
    );
  }
}

class _MessageBar extends StatefulWidget {
  const _MessageBar(this.code);
  final String? code;

  @override
  State<_MessageBar> createState() => _MessageBarState();
}

class _MessageBarState extends State<_MessageBar> {
  late final TextEditingController _textController;
  final RxString urlPhoto = "".obs;
  final RxBool isLoading = false.obs;
  final UtilitiesController utilitiesController = Get.find();

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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Theme.of(context).cardColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                IconButton(
                  tooltip: "Attach File",
                  icon: const Icon(HeroIcons.paper_clip),
                  onPressed: () {
                    CustomMaterialBottomSheets.defaultBottomSheet(
                      context,
                      size: size,
                      isScrolledController: false,
                      title: "Pilih Opsi",
                      children: [
                        ListTile(
                          leading: const Icon(Bootstrap.camera),
                          title: const Text("Kamera"),
                          onTap: () async {
                            Get.back();
                            urlPhoto(await CustomImagePicker.pickImageFromCameraAndReturnUrl(useCamera: true));
                            Get.to(() => SendImageChat(imageURL: urlPhoto.value, codeChat: widget.code));
                          },
                        ),
                        ListTile(
                          leading: const Icon(Bootstrap.image),
                          title: const Text("Gallery"),
                          onTap: () async {
                            Get.back();
                            urlPhoto(await CustomImagePicker.pickImageFromCameraAndReturnUrl());
                            Get.to(() => SendImageChat(imageURL: urlPhoto.value, codeChat: widget.code));
                          },
                        ),
                      ],
                    );
                  },
                ),

                Expanded(
                  child: TextFormField(
                    controller: _textController,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: "Type a message",
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.all(8),
                    ),
                  ),
                ),

                Obx(() {
                  return IconButton(
                    tooltip: "Send Message",
                    icon: isLoading.value
                        ? const SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(strokeWidth: 2, color: CustomColor.secondaryColor),
                          )
                        : const Icon(Bootstrap.send),
                    onPressed: () async {
                      if (_textController.text.isEmpty) return;

                      isLoading(true);

                      final ok = await utilitiesController.sendMessage(
                        code: widget.code,
                        message: _textController.text,
                      );

                      if (!ok) {
                        CustomScaffoldMessanger.showAppSnackBar(
                          context,
                          message: utilitiesController.responseMessage.value,
                        );
                      }

                      _textController.clear();

                      await utilitiesController.listMessageOfTicket(code: widget.code);
                      utilitiesController.messagesModel.refresh();

                      // 🔥 Auto-scroll
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        (context.findAncestorStateOfType<_TicketsState>())
                            ?._scrollToBottom();
                      });

                      isLoading(false);
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class MessageBubble extends StatefulWidget {
  final String message;
  final String date;
  final String time;
  final bool isUser;
  final String contentType; // "message" / "image"

  const MessageBubble({
    super.key,
    required this.message,
    required this.date,
    required this.time,
    required this.isUser,
    required this.contentType,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {

  double _scale = 1.0;

  String formatIndo(String date, String time) {
    initializeDateFormatting('id_ID');
    final dt = DateTime.parse("$date $time").toLocal();
    return DateFormat("EEEE, dd MMMM yyyy HH:mm", "id_ID").format(dt);
  }

  void _onLongPress() async {
    setState(() => _scale = 0.97);

    await HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 140));
    setState(() => _scale = 1.0);

    // show dialog menu
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(200, 300, 40, 40),
      items: [
        PopupMenuItem(
          child: const Text("Copy"),
          onTap: () {
            Clipboard.setData(ClipboardData(text: widget.message));
            AppSnackbar.success("Pesan telah disalin ke clipboard");
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final isImage = widget.contentType == "image";

    return GestureDetector(
      onLongPress: _onLongPress,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: _scale,
        child: Row(
          mainAxisAlignment: widget.isUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                minWidth: size.width / 2.5,
                maxWidth: size.width / 1.7,
              ),
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              padding: EdgeInsets.all(isImage ? 4 : 12),
        decoration: BoxDecoration(
          color: widget.isUser
              ? const Color(0xffdcf8c6)   // hijau WhatsApp
              : Colors.grey.shade300,     // abu WhatsApp
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(widget.isUser ? 16 : 4),
            topRight: Radius.circular(widget.isUser ? 4 : 16),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(16),
          ),
        ),

        child: Column(
          crossAxisAlignment: widget.isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            
            // ======================
            // 🍀 1. Pesan Gambar
            // ======================
            if (isImage)
              GestureDetector(
                onTap: () {
                  Get.to(() => FullscreenImage(url: widget.message));
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    widget.message,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return SizedBox(
                        height: 160,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                                : null,
                            color: CustomColor.secondaryColor,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      padding: const EdgeInsets.all(20),
                      child: const Text("Gambar gagal dimuat"),
                    ),
                  ),
                ),
              ),

            // ======================
            // ✏️ 2. Pesan Text
            // ======================
            if (!isImage)
              Text(
                widget.message,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),

            const SizedBox(height: 6),

            // ======================
            // ⏱ 3. Waktu
            // ======================
            Text(
              formatIndo(widget.date, widget.time),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),
);
}
}