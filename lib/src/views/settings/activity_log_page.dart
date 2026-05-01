import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/controllers/activity_logs_controller.dart';
import 'package:rrfx/src/models/settings/activity_model.dart';

class ActivityLogPage extends StatelessWidget {
  const ActivityLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller
    final controller = Get.put(ActivityLogsController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.grey.shade50,
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text("Aktivitas Akun",
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2_outline),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        // 1. Shimmer/Loading State saat pertama kali buka
        if (controller.isLoading.value && controller.activityLogs.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        // 2. Empty State
        if (controller.activityLogs.isEmpty) {
          return _buildEmptyState(isDark);
        }

        // 3. Main List with Pagination & Refresh
        return RefreshIndicator(
          onRefresh: () => controller.fetchActivityLogs(isRefresh: true),
          color: Colors.blue,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              // Trigger Load More saat user scroll mendekati bawah (sisa 200px)
              if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                controller.loadMoreLogs();
              }
              return true;
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              // Tambah 1 item untuk indikator loading di paling bawah
              itemCount: controller.activityLogs.length + (controller.hasMoreData.value ? 1 : 0),
              itemBuilder: (context, index) {
                // Item Loading di bawah
                if (index == controller.activityLogs.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator.adaptive(strokeWidth: 2)),
                  );
                }

                final log = controller.activityLogs[index];
                return _buildLogItem(
                  log, 
                  isDark, 
                  index == controller.activityLogs.length - 1 && !controller.hasMoreData.value
                );
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.document_filter_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "Belum ada aktivitas",
            style: GoogleFonts.inter(
              fontSize: 16, 
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(ActivityLog log, bool isDark, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line & Icon
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getCategoryColor(log.activity).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getCategoryIcon(log.activity),
                  size: 18,
                  color: _getCategoryColor(log.activity),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content Card
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      log.activity,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      _formatDate(log.createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 11, 
                        color: Colors.grey,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  log.description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.5,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 10),
                // Footer: Device & IP
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildBadge(
                      Iconsax.mobile_outline, 
                      _parseDevice(log.device), 
                      isDark
                    ),
                    _buildBadge(
                      Iconsax.global_outline, 
                      log.ipAddress, 
                      isDark
                    ),
                  ],
                ),
                const SizedBox(height: 24), 
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10, 
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helpers
  IconData _getCategoryIcon(String activity) {
    final act = activity.toLowerCase();
    if (act.contains('ticket')) return Iconsax.ticket_2_outline;
    if (act.contains('passcode') || act.contains('password') || act.contains('reset')) return Iconsax.key_outline;
    if (act.contains('signup') || act.contains('verification')) return Iconsax.user_add_outline;
    if (act.contains('otp')) return Iconsax.message_notif_outline;
    if (act.contains('ib') || act.contains('request')) return Iconsax.hierarchy_outline;
    return Iconsax.document_text_outline;
  }

  Color _getCategoryColor(String activity) {
    final act = activity.toLowerCase();
    if (act.contains('ticket')) return Colors.blue;
    if (act.contains('password') || act.contains('reset')) return Colors.orange;
    if (act.contains('signup') || act.contains('otp')) return Colors.green;
    if (act.contains('ib')) return Colors.purple;
    return Colors.blueGrey;
  }

  String _parseDevice(String device) {
    if (device.contains('Mozilla')) return 'Web Browser';
    if (device.contains('Postman')) return 'API Tester';
    if (device.contains('SM-') || device.contains('samsung')) return 'Samsung Mobile';
    if (device.contains('iPhone')) return 'iPhone';
    return device.split(',').first;
  }

  String _formatDate(String rawDate) {
    try {
      DateTime dt = DateTime.parse(rawDate);
      DateTime now = DateTime.now();
      
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return "Hari ini, ${DateFormat('HH:mm').format(dt)}";
      }
      return DateFormat('dd MMM, HH:mm').format(dt);
    } catch (e) {
      return rawDate;
    }
  }
}