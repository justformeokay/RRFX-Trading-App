import 'dart:async';
import 'dart:ui';
import 'package:rrfx/src/helpers/widgets/app_network_image.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF2F3F8),
        appBar: _buildAppBar(context, isDark),
        body: Column(
          children: [
            // ── Closed banner ──
            if (widget.closed == true)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: Colors.red.withOpacity(isDark ? 0.15 : 0.08),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_rounded, size: 14, color: Colors.red.shade400),
                    const SizedBox(width: 6),
                    Text(
                      "Tiket ini sudah ditutup",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ],
                ),
              ),

            // ── Messages ──
            Expanded(
              child: Obx(() {
                final messages = utilitiesController.messagesModel.value?.response ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: CustomColor.secondaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 32,
                            color: CustomColor.secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Mulai percakapan",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Ketik pesan untuk menghubungi tim support",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Group messages by date
                final grouped = <String, List<dynamic>>{};
                for (final m in messages) {
                  final key = m.date ?? '';
                  grouped.putIfAbsent(key, () => []);
                  grouped[key]!.add(m);
                }
                final dateKeys = grouped.keys.toList();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  itemCount: dateKeys.length,
                  itemBuilder: (_, di) {
                    final dateStr = dateKeys[di];
                    final dayMessages = grouped[dateStr]!;

                    return Column(
                      children: [
                        // ── Date separator ──
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _formatDateLabel(dateStr),
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white54 : Colors.black45,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // ── Messages for this date ──
                        ...dayMessages.map((m) => _animatedBubble(
                          MessageBubble(
                            message: m.content ?? "",
                            date: m.date ?? "",
                            time: m.time ?? "",
                            isUser: m.type == "member",
                            contentType: m.contentType ?? "message",
                            isDark: isDark,
                          ),
                        )),
                      ],
                    );
                  },
                );
              }),
            ),

            // ── Input bar ──
            if (widget.closed != true) _MessageBar(widget.ticketCode),
          ],
        ),
      ),
    );
  }

  String _formatDateLabel(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      initializeDateFormatting('id_ID');
      final dt = DateTime.parse(dateStr);
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return "Hari Ini";
      }
      final yesterday = now.subtract(const Duration(days: 1));
      if (dt.year == yesterday.year && dt.month == yesterday.month && dt.day == yesterday.day) {
        return "Kemarin";
      }
      return DateFormat("dd MMMM yyyy", "id_ID").format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  PreferredSize _buildAppBar(BuildContext context, bool isDark) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(68),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                // ── Back button ──
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? Colors.white10 : Colors.grey.shade100,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // ── Avatar with online dot ──
                Stack(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: CustomColor.secondaryColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 19,
                        backgroundColor: isDark ? const Color(0xFF252525) : Colors.grey.shade50,
                        backgroundImage: const AssetImage('assets/images/logo-rrfx-3.png'),
                      ),
                    ),
                    Positioned(
                      bottom: 1,
                      right: 1,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: widget.closed == true ? Colors.grey : const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),

                // ── Name + status + ticket code ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Admin RRFX",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Row(
                        children: [
                          Text(
                            widget.closed == true ? "Tiket ditutup" : "Online",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: widget.closed == true
                                  ? Colors.grey
                                  : const Color(0xFF22C55E),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: CustomColor.secondaryColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "# ${widget.ticketCode?.substring(0, widget.ticketCode!.length > 8 ? 8 : widget.ticketCode!.length) ?? '-'}",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                                color: CustomColor.secondaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Close ticket button ──
                if (widget.closed != true)
                  GestureDetector(
                    onTap: () {
                      CustomAlert.alertDialogCustomInfo(
                        onTap: () {
                          utilitiesController.closeTicket(code: widget.ticketCode).then((result) {
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
                        message: "Apakah anda yakin menutup ticket?",
                        moreThanOneButton: true,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(isDark ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.close_rounded, size: 14, color: Colors.red.shade400),
                          const SizedBox(width: 4),
                          Text(
                            "Tutup",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade400,
                            ),
                          ),
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


// ─────────────────────────────────────────────────────────────────────────────
// FULLSCREEN IMAGE
// ─────────────────────────────────────────────────────────────────────────────

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
          child: Hero(tag: url, child: AppNetworkImage(url)),
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// MESSAGE INPUT BAR
// ─────────────────────────────────────────────────────────────────────────────

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
  final RxBool _hasText = false.obs;
  final UtilitiesController utilitiesController = Get.find();

  @override
  void initState() {
    _textController = TextEditingController();
    _textController.addListener(() {
      _hasText.value = _textController.text.trim().isNotEmpty;
    });
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // ── Attach button ──
              GestureDetector(
                onTap: () {
                  CustomMaterialBottomSheets.defaultBottomSheet(
                    context,
                    size: size,
                    isScrolledController: false,
                    title: "Pilih Opsi",
                    children: [
                      ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: CustomColor.secondaryColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Bootstrap.camera, size: 18, color: CustomColor.secondaryColor),
                        ),
                        title: Text("Kamera", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        subtitle: Text("Ambil foto langsung", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                        onTap: () async {
                          Get.back();
                          urlPhoto(await CustomImagePicker.pickImageFromCameraAndReturnUrl(useCamera: true));
                          Get.to(() => SendImageChat(imageURL: urlPhoto.value, codeChat: widget.code));
                        },
                      ),
                      ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Bootstrap.image, size: 18, color: Colors.blue),
                        ),
                        title: Text("Galeri", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        subtitle: Text("Pilih dari galeri foto", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                        onTap: () async {
                          Get.back();
                          urlPhoto(await CustomImagePicker.pickImageFromCameraAndReturnUrl());
                          Get.to(() => SendImageChat(imageURL: urlPhoto.value, codeChat: widget.code));
                        },
                      ),
                    ],
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? Colors.white10 : Colors.grey.shade100,
                  ),
                  child: Icon(
                    Icons.attach_file_rounded,
                    size: 20,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // ── Text field ──
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF252525) : const Color(0xFFF2F3F8),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextFormField(
                    controller: _textController,
                    minLines: 1,
                    maxLines: 4,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: "Ketik pesan...",
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // ── Send button ──
              Obx(() {
                final sending = isLoading.value;
                final hasContent = _hasText.value;

                return GestureDetector(
                  onTap: sending
                      ? null
                      : () async {
                          if (_textController.text.trim().isEmpty) return;
                          isLoading(true);

                          final ok = await utilitiesController.sendMessage(
                            code: widget.code,
                            message: _textController.text,
                          );

                          if (!ok) {
                            if (context.mounted) {
                              CustomScaffoldMessanger.showAppSnackBar(
                                context,
                                message: utilitiesController.responseMessage.value,
                              );
                            }
                          }

                          _textController.clear();
                          await utilitiesController.listMessageOfTicket(code: widget.code);
                          utilitiesController.messagesModel.refresh();

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            (context.findAncestorStateOfType<_TicketsState>())?._scrollToBottom();
                          });

                          isLoading(false);
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 42,
                    height: 42,
                    margin: const EdgeInsets.only(bottom: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: (hasContent || sending)
                          ? const LinearGradient(
                              colors: [CustomColor.secondaryColor, CustomColor.secondaryBackground],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: (hasContent || sending) ? null : (isDark ? Colors.white10 : Colors.grey.shade200),
                      boxShadow: hasContent
                          ? [
                              BoxShadow(
                                color: CustomColor.secondaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Icon(
                              Icons.send_rounded,
                              size: 18,
                              color: hasContent ? Colors.white : (isDark ? Colors.white30 : Colors.grey.shade400),
                            ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// MESSAGE BUBBLE
// ─────────────────────────────────────────────────────────────────────────────

class MessageBubble extends StatefulWidget {
  final String message;
  final String date;
  final String time;
  final bool isUser;
  final String contentType;
  final bool isDark;

  const MessageBubble({
    super.key,
    required this.message,
    required this.date,
    required this.time,
    required this.isUser,
    required this.contentType,
    required this.isDark,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  double _scale = 1.0;

  String formatTime(String date, String time) {
    try {
      initializeDateFormatting('id_ID');
      final dt = DateTime.parse("$date $time").toLocal();
      return DateFormat("HH:mm").format(dt);
    } catch (_) {
      return time;
    }
  }

  void _onLongPress() async {
    setState(() => _scale = 0.97);
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 140));
    setState(() => _scale = 1.0);

    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(200, 300, 40, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        PopupMenuItem(
          child: Row(
            children: [
              const Icon(Icons.copy_rounded, size: 16),
              const SizedBox(width: 8),
              const Text("Copy"),
            ],
          ),
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
    final isDark = widget.isDark;

    // Modern colors
    final userBubbleColor = const Color(0xFFE4B73C); // gold
    final adminBubbleColor = isDark ? const Color(0xFF252525) : Colors.white;
    final userTextColor = Colors.white;
    final adminTextColor = isDark ? Colors.white : Colors.black87;

    return GestureDetector(
      onLongPress: _onLongPress,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: _scale,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisAlignment: widget.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Admin avatar (small)
              if (!widget.isUser)
                Padding(
                  padding: const EdgeInsets.only(right: 6, bottom: 2),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: isDark ? const Color(0xFF333333) : Colors.grey.shade100,
                    backgroundImage: const AssetImage('assets/images/logo-rrfx-3.png'),
                  ),
                ),

              Flexible(
                child: Container(
                  constraints: BoxConstraints(maxWidth: size.width * 0.72),
                  padding: EdgeInsets.all(isImage ? 4 : 0),
                  decoration: BoxDecoration(
                    color: widget.isUser ? userBubbleColor : adminBubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(widget.isUser ? 18 : 4),
                      bottomRight: Radius.circular(widget.isUser ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                        widget.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      // ── Image message ──
                      if (isImage)
                        GestureDetector(
                          onTap: () => Get.to(() => FullscreenImage(url: widget.message)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: AppNetworkImage(
                              widget.message,
                              fit: BoxFit.cover,
                              loadingBuilder: (_, child, progress) {
                                if (progress == null) return child;
                                return SizedBox(
                                  height: 160,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: progress.expectedTotalBytes != null
                                          ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                          : null,
                                      color: CustomColor.secondaryColor,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => Container(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  "Gambar gagal dimuat",
                                  style: TextStyle(color: widget.isUser ? userTextColor : adminTextColor),
                                ),
                              ),
                            ),
                          ),
                        ),

                      // ── Text message ──
                      if (!isImage)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                          child: Text(
                            widget.message,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              height: 1.4,
                              color: widget.isUser ? userTextColor : adminTextColor,
                            ),
                          ),
                        ),

                      // ── Time ──
                      Padding(
                        padding: EdgeInsets.fromLTRB(14, isImage ? 6 : 4, 14, 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatTime(widget.date, widget.time),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: widget.isUser
                                    ? Colors.white.withOpacity(0.7)
                                    : Colors.grey.shade500,
                              ),
                            ),
                            if (widget.isUser) ...[
                              const SizedBox(width: 3),
                              Icon(
                                Icons.done_all_rounded,
                                size: 13,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}