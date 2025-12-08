import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/helpers/handlers/holiday.dart';

enum MarketEmptyReason {
  noData,           // Data kosong
  disconnected,     // WebSocket gagal terhubung
  marketClosed,     // Market tutup (weekend/holiday)
}

class EmptyMarketState extends StatelessWidget {
  final MarketEmptyReason reason;
  final VoidCallback? onRetry;
  final bool isRetrying;

  const EmptyMarketState({
    super.key,
    required this.reason,
    this.onRetry,
    this.isRetrying = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon/Animation berdasarkan reason
            _buildVisual(isDarkMode),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              _getTitle(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Description
            Text(
              _getDescription(),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.6,
                fontSize: 15,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            
            if (reason == MarketEmptyReason.marketClosed) ...[
              const SizedBox(height: 20),
              _buildMarketScheduleInfo(theme, isDarkMode),
            ],
            
            // Retry button (hanya untuk disconnected)
            if (reason == MarketEmptyReason.disconnected) ...[
              const SizedBox(height: 32),
              _buildRetryButton(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVisual(bool isDarkMode) {
    switch (reason) {
      case MarketEmptyReason.noData:
        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: CustomColor.secondaryColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Iconsax.chart_outline,
            size: 64,
            color: CustomColor.secondaryColor,
          ),
        );
        
      case MarketEmptyReason.disconnected:
        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Iconsax.wifi_square_outline,
            size: 64,
            color: Colors.orange.shade700,
          ),
        );
        
      case MarketEmptyReason.marketClosed:
        return Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.withOpacity(0.15),
                Colors.purple.withOpacity(0.15),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Iconsax.clock_outline,
            size: 64,
            color: CustomColor.secondaryColor,
          ),
        );
    }
  }

  String _getTitle() {
    switch (reason) {
      case MarketEmptyReason.noData:
        return "Data Market Kosong";
      case MarketEmptyReason.disconnected:
        return "Koneksi Terputus";
      case MarketEmptyReason.marketClosed:
        return "Market Sedang Tutup";
    }
  }

  String _getDescription() {
    final now = DateTime.now();
    final isWeekend = now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;
    final isHoliday = isForexHoliday(now);
    
    switch (reason) {
      case MarketEmptyReason.noData:
        return "Belum ada data market yang tersedia saat ini.\nData akan muncul ketika server mengirimkan informasi terbaru.";
        
      case MarketEmptyReason.disconnected:
        return "Tidak dapat terhubung ke server market.\nPeriksa koneksi internet Anda dan coba lagi.";
        
      case MarketEmptyReason.marketClosed:
        if (isWeekend) {
          return "Market Forex tutup pada akhir pekan.\nTrading akan dibuka kembali pada hari Senin pukul 05:00 WIB.";
        } else if (isHoliday) {
          return "Hari ini adalah hari libur market internasional.\nTrading akan dibuka kembali pada hari kerja berikutnya.";
        } else {
          return "Market sedang dalam waktu istirahat.\nSilakan cek kembali pada jam trading.";
        }
    }
  }

  Widget _buildMarketScheduleInfo(ThemeData theme, bool isDarkMode) {
    final now = DateTime.now();
    final isWeekend = now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode 
          ? CustomColor.secondaryColor.withOpacity(0.2)
          : CustomColor.secondaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:CustomColor.secondaryColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Iconsax.info_circle_outline,
                size: 20,
                color: CustomColor.secondaryColor,
              ),
              const SizedBox(width: 10),
              Text(
                "Jadwal Trading",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: CustomColor.secondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildScheduleRow("Senin - Jumat", "05:00 - 04:00 WIB", theme, isDarkMode),
          const SizedBox(height: 6),
          _buildScheduleRow("Sabtu - Minggu", "Tutup", theme, isDarkMode, isInactive: true),
          if (isWeekend) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDarkMode 
                  ? Colors.amber.shade900.withOpacity(0.3)
                  : Colors.amber.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Iconsax.calendar_1_outline,
                    size: 16,
                    color: isDarkMode ? Colors.amber.shade300 : Colors.amber.shade800,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getNextOpeningTime(),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.amber.shade300 : Colors.amber.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleRow(String day, String time, ThemeData theme, bool isDarkMode, {bool isInactive = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          day,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isInactive
              ? theme.colorScheme.onSurface.withOpacity(0.4)
              : theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        Text(
          time,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isInactive
              ? theme.colorScheme.onSurface.withOpacity(0.4)
              : isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
          ),
        ),
      ],
    );
  }

  String _getNextOpeningTime() {
    final now = DateTime.now();
    DateTime nextMonday = now;
    
    // Cari hari Senin berikutnya
    while (nextMonday.weekday != DateTime.monday) {
      nextMonday = nextMonday.add(const Duration(days: 1));
    }
    
    // Set jam ke 05:00
    nextMonday = DateTime(nextMonday.year, nextMonday.month, nextMonday.day, 5, 0);
    
    final daysUntil = nextMonday.difference(now).inDays;
    final hoursUntil = nextMonday.difference(now).inHours % 24;
    
    if (daysUntil == 0) {
      return "Buka dalam $hoursUntil jam";
    } else if (daysUntil == 1) {
      return "Buka besok pukul 05:00";
    } else {
      return "Buka ${daysUntil} hari lagi";
    }
  }

  Widget _buildRetryButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isRetrying ? null : onRetry,
        icon: isRetrying 
          ? const SizedBox.shrink()
          : const Icon(Iconsax.refresh_outline, color: Colors.black),
        label: isRetrying
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Menyambung...",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            )
          : Text(
              "Coba Sambungkan Lagi",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomColor.secondaryColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
