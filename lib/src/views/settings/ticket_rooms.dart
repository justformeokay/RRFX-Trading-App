import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/controllers/utilities.dart';
import 'package:rrfx/src/views/settings/tickets.dart';
import 'package:shimmer/shimmer.dart';

class TicketRooms extends StatefulWidget {
  const TicketRooms({super.key});

  @override
  State<TicketRooms> createState() => _TicketRoomsState();
}

class _TicketRoomsState extends State<TicketRooms> {
  final UtilitiesController utilitiesController = Get.find();

  static const List<Color> _avatarPalette = [
    Color(0xFF5C6BC0),
    Color(0xFF26A69A),
    Color(0xFFEF5350),
    Color(0xFFAB47BC),
    Color(0xFF29B6F6),
    Color(0xFFFF7043),
    Color(0xFF66BB6A),
    Color(0xFFFFA726),
  ];

  Color _avatarColor(int index) => _avatarPalette[index % _avatarPalette.length];

  IconData _subjectIcon(String? subject) {
    final s = (subject ?? '').toLowerCase();
    if (s.contains('teknis') || s.contains('bug')) return Icons.bug_report_rounded;
    if (s.contains('pembayaran') || s.contains('billing')) return Icons.credit_card_rounded;
    if (s.contains('akun')) return Icons.manage_accounts_rounded;
    if (s.contains('saran') || s.contains('umpan')) return Icons.lightbulb_rounded;
    return Icons.support_agent_rounded;
  }

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
      utilitiesController.getTopics().then((success) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF5F6FA),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 110,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            leading: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 0, bottom: 14),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Support Chat",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Obx(() {
                    final count = utilitiesController.listTicketModel.value?.response?.length ?? 0;
                    return Text(
                      "$count tiket aktif",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: CustomColor.secondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                child: GestureDetector(
                  onTap: () => utilitiesController.ticketList(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: CustomColor.secondaryColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.refresh_rounded,
                      size: 20,
                      color: CustomColor.secondaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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
                itemBuilder: (_, __) => shimmerTicketItem(isDark),
              );
            }

            /// === EMPTY STATE ===
            if (tickets!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: CustomColor.secondaryColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mark_chat_unread_rounded,
                        size: 42,
                        color: CustomColor.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Belum ada tiket",
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Buat tiket baru untuk menghubungi\ntim support kami.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 28),
                    GestureDetector(
                      onTap: () => _openCreateBottomSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              CustomColor.secondaryColor,
                              CustomColor.secondaryBackground,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: CustomColor.secondaryColor.withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              "Buat Tiket",
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            /// === LIST DATA ===
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: tickets.length,
              itemBuilder: (_, i) {
                final item = tickets[i];
                final isClosed = item.status == "closed";
                final avatarColor = _avatarColor(i);
                final icon = _subjectIcon(item.subject);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        Get.to(() => Tickets(
                          ticketCode: item.code,
                          closed: isClosed,
                        ));
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                              color: Colors.black.withOpacity(isDark ? 0.25 : 0.07),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          child: Row(
                            children: [
                              // Avatar with icon
                              Stack(
                                children: [
                                  Container(
                                    height: 52,
                                    width: 52,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          avatarColor,
                                          avatarColor.withOpacity(0.65),
                                        ],
                                      ),
                                    ),
                                    child: Icon(icon, color: Colors.white, size: 24),
                                  ),
                                  // Online/status dot
                                  Positioned(
                                    bottom: 1,
                                    right: 1,
                                    child: Container(
                                      width: 13,
                                      height: 13,
                                      decoration: BoxDecoration(
                                        color: isClosed ? Colors.grey.shade400 : const Color(0xFF22C55E),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 14),

                              /// TEXT INFO
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.subject ?? "-",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: isDark ? Colors.white : Colors.black87,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          item.createdAt != null
                                              ? DateFormat('dd MMM').format(DateTime.parse(item.createdAt!))
                                              : "",
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.tag_rounded,
                                          size: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                        const SizedBox(width: 3),
                                        Expanded(
                                          child: Text(
                                            item.code ?? "-",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ),
                                        // Status chip
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: isClosed
                                                ? Colors.red.withOpacity(isDark ? 0.2 : 0.1)
                                                : const Color(0xFF22C55E).withOpacity(isDark ? 0.2 : 0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 5,
                                                height: 5,
                                                decoration: BoxDecoration(
                                                  color: isClosed ? Colors.red : const Color(0xFF22C55E),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                isClosed ? "Closed" : "Open",
                                                style: GoogleFonts.inter(
                                                  color: isClosed ? Colors.red : const Color(0xFF22C55E),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 20,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),

      /// FLOATING BUTTON
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [CustomColor.secondaryColor, CustomColor.secondaryBackground],
          ),
          boxShadow: [
            BoxShadow(
              color: CustomColor.secondaryColor.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          elevation: 0,
          backgroundColor: Colors.transparent,
          onPressed: () => _openCreateBottomSheet(context),
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text(
            "Tiket Baru",
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  void _openCreateBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateTicketSheet(utilitiesController: utilitiesController),
    );
  }

  /// ===== SHIMMER SKELETON UI =====
  Widget shimmerTicketItem(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: isDark ? Colors.grey.shade800 : Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(height: 13, width: double.infinity, color: Colors.white, margin: const EdgeInsets.only(bottom: 8)),
                    Container(height: 10, width: 140, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CREATE TICKET WIZARD — 2-step bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _SubjectOption {
  final String label;
  final String description;
  final IconData icon;
  final Color color;
  const _SubjectOption({
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
  });
}

const List<_SubjectOption> _subjectOptions = [
  _SubjectOption(
    label: "Masalah Teknis/Bug",
    description: "Error, crash, atau fitur tidak berfungsi",
    icon: Icons.bug_report_rounded,
    color: Color(0xFFEF5350),
  ),
  _SubjectOption(
    label: "Pertanyaan Umum",
    description: "Info produk & cara penggunaan",
    icon: Icons.help_outline_rounded,
    color: Color(0xFF5C6BC0),
  ),
  _SubjectOption(
    label: "Pembayaran/Billing",
    description: "Gagal bayar, refund, tagihan keliru",
    icon: Icons.credit_card_rounded,
    color: Color(0xFF26A69A),
  ),
  _SubjectOption(
    label: "Perubahan Akun",
    description: "Data profil, password, verifikasi",
    icon: Icons.manage_accounts_rounded,
    color: Color(0xFFAB47BC),
  ),
  _SubjectOption(
    label: "Saran & Masukan",
    description: "Ide fitur baru atau umpan balik",
    icon: Icons.lightbulb_rounded,
    color: Color(0xFFFFA726),
  ),
];

class _CreateTicketSheet extends StatefulWidget {
  final UtilitiesController utilitiesController;
  const _CreateTicketSheet({required this.utilitiesController});

  @override
  State<_CreateTicketSheet> createState() => _CreateTicketSheetState();
}

class _CreateTicketSheetState extends State<_CreateTicketSheet> {
  int _step = 0;
  int _selectedSubject = 0;
  int _selectedTopic = 0;
  bool _isLoading = false;

  late final PageController _pageCtrl;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _goStep(int step) {
    setState(() => _step = step);
    _pageCtrl.animateToPage(
      step,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    final subject = _subjectOptions[_selectedSubject].label;
    final topics = widget.utilitiesController.topics;
    if (topics.isNotEmpty) {
      widget.utilitiesController.selectedTopic.value = topics[_selectedTopic];
    }
    final success = await widget.utilitiesController.createTicket(subject: subject);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      await widget.utilitiesController.ticketList();
      if (!mounted) return;
      Get.back();
      final list = widget.utilitiesController.listTicketModel.value?.response;
      if (list != null && list.isNotEmpty) {
        final newTicket = list.first;
        Get.to(() => Tickets(
          ticketCode: newTicket.code,
          closed: newTicket.status == "closed",
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── drag handle ──────────────────────────────────────────────────
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.35),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 18),

          // ── header ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                if (_step == 1)
                  GestureDetector(
                    onTap: () => _goStep(0),
                    child: Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 15,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _step == 0 ? "Pilih Kategori" : "Pilih Topik",
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _step == 0
                            ? "Langkah 1 dari 2 — masalah apa yang kamu alami?"
                            : "Langkah 2 dari 2 — pilih topik yang paling sesuai",
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── step progress bar ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Row(
              children: List.generate(2, (i) {
                final active = i <= _step;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i == 0 ? 6 : 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: active
                          ? CustomColor.secondaryColor
                          : (isDark ? Colors.white12 : Colors.black12),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 16),

          // ── paged content ────────────────────────────────────────────────
          SizedBox(
            height: 340,
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSubjectStep(isDark),
                _buildTopicStep(isDark),
              ],
            ),
          ),

          // ── action button ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: GestureDetector(
              onTap: _isLoading
                  ? null
                  : () {
                      if (_step == 0) {
                        _goStep(1);
                      } else {
                        _submit();
                      }
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: _isLoading
                      ? null
                      : const LinearGradient(
                          colors: [
                            CustomColor.secondaryColor,
                            CustomColor.secondaryBackground,
                          ],
                        ),
                  color: _isLoading ? Colors.grey.shade300 : null,
                  boxShadow: _isLoading
                      ? null
                      : [
                          BoxShadow(
                            color: CustomColor.secondaryColor.withOpacity(0.4),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                ),
                alignment: Alignment.center,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _step == 0 ? "Lanjut" : "Buat Tiket",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            _step == 0 ? Icons.arrow_forward_rounded : Icons.send_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 1: subject cards ─────────────────────────────────────────────────
  Widget _buildSubjectStep(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _subjectOptions.length,
      itemBuilder: (_, i) {
        final opt = _subjectOptions[i];
        final selected = _selectedSubject == i;
        return GestureDetector(
          onTap: () => setState(() => _selectedSubject = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: selected
                  ? opt.color.withOpacity(isDark ? 0.18 : 0.08)
                  : (isDark ? const Color(0xFF252525) : const Color(0xFFF8F8FB)),
              border: Border.all(
                color: selected ? opt.color : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: opt.color.withOpacity(selected ? 0.2 : 0.12),
                  ),
                  child: Icon(opt.icon, color: opt.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opt.label,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? opt.color
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        opt.description,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? opt.color : Colors.transparent,
                    border: Border.all(
                      color: selected ? opt.color : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 12)
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Step 2: topic tags ────────────────────────────────────────────────────
  Widget _buildTopicStep(bool isDark) {
    return Obx(() {
      final topics = widget.utilitiesController.topics;
      if (topics.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: CustomColor.secondaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Memuat topik...",
                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pilih satu topik yang paling menggambarkan masalah kamu:",
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(topics.length, (i) {
                    final selected = _selectedTopic == i;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedTopic = i);
                        widget.utilitiesController.selectedTopic.value = topics[i];
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: selected
                              ? CustomColor.secondaryColor
                              : (isDark ? const Color(0xFF252525) : const Color(0xFFF0F0F5)),
                          border: Border.all(
                            color: selected
                                ? CustomColor.secondaryColor
                                : (isDark ? Colors.white12 : Colors.black12),
                            width: 1,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: CustomColor.secondaryColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (selected) ...[
                              const Icon(Icons.check_circle_rounded,
                                  size: 14, color: Colors.white),
                              const SizedBox(width: 5),
                            ],
                            Text(
                              topics[i],
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                color: selected
                                    ? Colors.white
                                    : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
