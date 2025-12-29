import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/controllers/home.dart';
import 'package:rrfx/src/views/accounts/deposit_new_account.dart';
import 'package:rrfx/src/views/accounts/registration_online/views/step_0_password_meta.dart';

class PendingAccount extends StatefulWidget {
  const PendingAccount({super.key});

  @override
  State<PendingAccount> createState() => _PendingAccountState();
}

class _PendingAccountState extends State<PendingAccount> {
  HomeController homeController = Get.find();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, (){
      homeController.getPendingAccount().then((result){
        if(!result){}
      });
    });
  }

  /// Get status badge color berdasarkan status
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'waiting':
      case 'waiting deposit':
      case 'register':
        return Colors.orange;
      case 'ditolak':
        return Colors.red;
      case 'regol belum selesai':
        return Colors.amber;
      case 'deposit new account':
        return Colors.blue;
      case 'good fund':
      case 'active':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Get status icon berdasarkan status
  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'waiting':
      case 'waiting deposit':
      case 'register':
        return Iconsax.clock_outline;
      case 'ditolak':
        return Iconsax.close_circle_outline;
      case 'regol belum selesai':
        return Iconsax.edit_outline;
      case 'deposit new account':
        return Iconsax.wallet_add_outline;
      case 'good fund':
      case 'active':
        return Iconsax.check_outline;
      default:
        return Iconsax.info_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => homeController.isLoading.value
        ? SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(AntDesign.loading_3_quarters_outline, color: CustomColor.secondaryColor,),
                const SizedBox(height: 5),
                Text("Getting Pending...", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700))
              ],
            ),
          )
        : homeController.pendingModel.value?.response?.isEmpty == true
          ? SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(HeroIcons.trash, color: CustomColor.secondaryColor),
                  SizedBox(height: 5),
                  Text("Tidak ada akun pending", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700))
                ],
              ),
            )
          : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            itemCount: homeController.pendingModel.value?.response?.length,
            itemBuilder: (context, index) {
              final pending = homeController.pendingModel.value?.response?[index];
              final statusColor = _getStatusColor(pending?.status);
              final statusIcon = _getStatusIcon(pending?.status);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildPendingAccountCard(
                  context,
                  pending,
                  statusColor,
                  statusIcon,
                  index,
                ),
              );
        },
      ),
    );
  }

  Widget _buildPendingAccountCard(
    BuildContext context,
    dynamic pending,
    Color statusColor,
    IconData statusIcon,
    int index,
  ) {
    if (pending == null) return const SizedBox.shrink();

    final dateCreated = pending.dateCreated != null
        ? DateTime.parse(pending.dateCreated)
        : null;

    return Bounce(
      onTap: () {
        switch (pending.status) {
          case "Regol belum selesai":
            Get.to(() => CreateMT5PasswordPage());
            break;
          case "Waiting":
            CustomScaffoldMessanger.showAppSnackBar(context,
                message:
                    "Akun masih dalam proses verifikasi oleh admin, tidak dapat melakukan perubahan data");
            break;
          case "Ditolak":
            Get.to(() => CreateMT5PasswordPage());
            break;
          case "Register":
            CustomScaffoldMessanger.showAppSnackBar(context,
                message:
                    "Akun masih dalam proses verifikasi oleh admin, tidak dapat melakukan perubahan data");
            break;
          case "Deposit New Account":
            Get.to(() => const DepositNewAccount());
            break;
          case "Waiting Deposit":
            CustomScaffoldMessanger.showAppSnackBar(context,
                message: "Akun Anda sedang menunggu konfirmasi dari admin.");
            break;
          case "Good Fund":
            break;
          case "Active":
            break;
          default:
            break;
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              statusColor.withOpacity(0.08),
              statusColor.withOpacity(0.02),
            ],
          ),
          border: Border.all(
            color: statusColor.withOpacity(0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background decorative element
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor.withOpacity(0.05),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header dengan icon dan account type
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Account Type',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pending.type ?? "-",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).textTheme.titleLarge?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            statusIcon,
                            color: statusColor,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        pending.status ?? "-",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Details Grid
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // Product & Currency Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Product',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      pending.product ?? "-",
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Theme.of(context).dividerColor.withOpacity(0.2),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Currency',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        pending.currency ?? "-",
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(
                            color: Theme.of(context).dividerColor.withOpacity(0.2),
                            height: 1,
                          ),
                          const SizedBox(height: 12),
                          // Rate
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Leverage Rate',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                                ),
                              ),
                              Text(
                                pending.rate ?? "-",
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Date & Time
                    if (dateCreated != null)
                      Row(
                        children: [
                          Icon(
                            Iconsax.calendar_1_outline,
                            size: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              DateFormat("dd MMM yyyy, HH:mm:ss")
                                  .format(dateCreated),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),

                    // Footer - Tap hint
                    Divider(
                      color: Theme.of(context).dividerColor.withOpacity(0.2),
                      height: 1,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tap to view details',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                          ),
                        ),
                        Icon(
                          Iconsax.arrow_right_3_outline,
                          size: 16,
                          color: statusColor,
                        ),
                      ],
                    ),
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
