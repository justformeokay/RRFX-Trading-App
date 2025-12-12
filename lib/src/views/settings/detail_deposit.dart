import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/controllers/user_controller.dart';

class TransactionDetailView extends StatefulWidget {
  const TransactionDetailView({super.key, this.id});
  final String? id;

  @override
  State<TransactionDetailView> createState() => _TransactionDetailViewState();
}

class _TransactionDetailViewState extends State<TransactionDetailView> {
  final UserController controller = Get.find();
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      controller.historyTransactionDetail(id: widget.id).then((result) {
        if (!result) {
          CustomScaffoldMessanger.showAppSnackBar(
            context,
            message: controller.responseMessage.value,
            type: SnackBarType.error,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        forceMaterialTransparency: true,
        elevation: 0,
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Transaction Details',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: CustomColor.secondaryColor,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading transaction details...',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.transactionDetail.value == null) {
          return _buildErrorState(context, isDark);
        }

        final data = controller.transactionDetail.value!;
        final statusColor = _getStatusColor(data.response?.status ?? 'pending');
        final formattedDate = _formatDateTime(data.response?.datetime ?? '');

        return RefreshIndicator(
          color: CustomColor.secondaryColor,
          onRefresh: () async {
            await controller.historyTransactionDetail(id: widget.id);
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Status Card with gradient
              _buildStatusCard(
                context,
                isDark,
                data.response?.status?.toString() ?? 'pending',
                data.response?.amountReceived?.toString() ?? '\$0',
                statusColor,
                formattedDate,
              ),

              const SizedBox(height: 24),

              // Transaction ID Card
              _buildTransactionIdCard(
                context,
                isDark,
                data.response?.id?.toString() ?? '-',
              ),

              const SizedBox(height: 20),

              // General Information
              _buildModernSectionHeader(
                context,
                isDark,
                'General Information',
                Iconsax.info_circle_outline,
              ),
              const SizedBox(height: 12),
              _buildModernInfoCard(
                context: context,
                isDark: isDark,
                children: [
                  _buildModernInfoRow(
                    context,
                    isDark,
                    'Transaction Type',
                    data.response?.type?.toString() ?? '-',
                    Iconsax.category_outline,
                  ),
                  _buildDivider(isDark),
                  _buildModernInfoRow(
                    context,
                    isDark,
                    'Login ID',
                    data.response?.login?.toString() ?? '-',
                    Iconsax.profile_circle_outline,
                  ),
                  _buildDivider(isDark),
                  _buildModernInfoRow(
                    context,
                    isDark,
                    'Amount',
                    data.response?.amountReceived?.toString() ?? '\$0',
                    Iconsax.wallet_money_outline,
                  ),
                  // Only show 'From' if it exists
                  if (data.response?.from != null &&
                      data.response!.from!.toString().isNotEmpty) ...[
                    _buildDivider(isDark),
                    _buildModernInfoRow(
                      context,
                      isDark,
                      'From',
                      data.response!.from!.toString(),
                      Iconsax.arrow_right_3_outline,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 20),

              // Determine if it's a withdrawal to swap the bank details
              // For withdrawal: Only show User Bank as Receiver (no sender)
              // For deposit: bankUser is sender, bankAdmin is receiver
              if (data.response?.type?.toString().toLowerCase() ==
                  'withdrawal') ...[
                // For Withdrawal: Show User Bank as Receiver (User's bank account)
                _buildModernSectionHeader(
                  context,
                  isDark,
                  'Receiver Bank Details',
                  Iconsax.receive_square_outline,
                ),
                const SizedBox(height: 12),
                _buildModernInfoCard(
                  context: context,
                  isDark: isDark,
                  children: [
                    _buildModernInfoRow(
                      context,
                      isDark,
                      'Bank Name',
                      data.response?.bankUser?.name?.toString() ?? '-',
                      Iconsax.building_outline,
                    ),
                    _buildDivider(isDark),
                    _buildModernInfoRow(
                      context,
                      isDark,
                      'Account Number',
                      data.response?.bankUser?.accountNumber?.toString() ?? '-',
                      Iconsax.card_outline,
                    ),
                    _buildDivider(isDark),
                    _buildModernInfoRow(
                      context,
                      isDark,
                      'Account Name',
                      data.response?.bankUser?.accountName?.toString() ?? '-',
                      Iconsax.user_outline,
                    ),
                  ],
                ),
              ] else ...[
                // For Deposit: Show User Bank as Sender
                _buildModernSectionHeader(
                  context,
                  isDark,
                  'Sender Bank Details',
                  Iconsax.bank_outline,
                ),
                const SizedBox(height: 12),
                _buildModernInfoCard(
                  context: context,
                  isDark: isDark,
                  children: [
                    _buildModernInfoRow(
                      context,
                      isDark,
                      'Bank Name',
                      data.response?.bankUser?.name?.toString() ?? '-',
                      Iconsax.building_outline,
                    ),
                    _buildDivider(isDark),
                    _buildModernInfoRow(
                      context,
                      isDark,
                      'Account Number',
                      data.response?.bankUser?.accountNumber?.toString() ?? '-',
                      Iconsax.card_outline,
                    ),
                    _buildDivider(isDark),
                    _buildModernInfoRow(
                      context,
                      isDark,
                      'Account Name',
                      data.response?.bankUser?.accountName?.toString() ?? '-',
                      Iconsax.user_outline,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // For Deposit: Show Admin Bank as Receiver
                _buildModernSectionHeader(
                  context,
                  isDark,
                  'Receiver Bank Details',
                  Iconsax.receive_square_outline,
                ),
                const SizedBox(height: 12),
                _buildModernInfoCard(
                  context: context,
                  isDark: isDark,
                  children: [
                    _buildModernInfoRow(
                      context,
                      isDark,
                      'Bank Name',
                      data.response?.bankAdmin?.name?.toString() ?? '-',
                      Iconsax.building_outline,
                    ),
                    _buildDivider(isDark),
                    _buildModernInfoRow(
                      context,
                      isDark,
                      'Account Number',
                      data.response?.bankAdmin?.accountNumber?.toString() ??
                          '-',
                      Iconsax.card_outline,
                    ),
                    _buildDivider(isDark),
                    _buildModernInfoRow(
                      context,
                      isDark,
                      'Account Name',
                      data.response?.bankAdmin?.accountName?.toString() ?? '-',
                      Iconsax.user_outline,
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  // --- Modern Widget Components ---

  Widget _buildErrorState(BuildContext context, bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Icon with gradient background
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.red.withValues(alpha: 0.15),
                    Colors.orange.withValues(alpha: 0.15),
                  ],
                ),
              ),
              child: Icon(
                Iconsax.close_circle_outline,
                size: 60,
                color: Colors.red.shade400,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Transaction Not Found',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Unable to load transaction details.\nPlease try again later.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.5,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),

            const SizedBox(height: 32),

            // Retry Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await controller.historyTransactionDetail(id: widget.id);
                },
                icon: const Icon(Icons.refresh_rounded),
                label: Text(
                  'Retry',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColor.secondaryColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Back Button
            TextButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: Text(
                'Go Back',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    bool isDark,
    String status,
    String amount,
    Color statusColor,
    String date,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor.withValues(alpha: 0.15),
            statusColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        children: [
          // Status Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(_getStatusIcon(status), size: 40, color: statusColor),
          ),

          const SizedBox(height: 16),

          // Amount
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),

          const SizedBox(height: 12),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getStatusIcon(status), size: 16, color: statusColor),
                const SizedBox(width: 6),
                Text(
                  status.toUpperCase(),
                  style: GoogleFonts.inter(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Date
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.clock_outline,
                size: 14,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 6),
              Text(
                date,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionIdCard(BuildContext context, bool isDark, String id) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: CustomColor.secondaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Iconsax.hashtag_outline,
              size: 20,
              color: CustomColor.secondaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transaction ID',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  id,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
          // Copy Button
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: id));
              CustomScaffoldMessanger.showAppSnackBar(
                context,
                message: 'Transaction ID copied to clipboard',
                type: SnackBarType.success,
              );
            },
            icon: Icon(
              Iconsax.copy_outline,
              size: 20,
              color: CustomColor.secondaryColor,
            ),
            tooltip: 'Copy Transaction ID',
            style: IconButton.styleFrom(
              backgroundColor: CustomColor.secondaryColor.withValues(
                alpha: 0.1,
              ),
              padding: const EdgeInsets.all(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSectionHeader(
    BuildContext context,
    bool isDark,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: CustomColor.secondaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: CustomColor.secondaryColor),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildModernInfoCard({
    required BuildContext context,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildModernInfoRow(
    BuildContext context,
    bool isDark,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CustomColor.secondaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: CustomColor.secondaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
    );
  }

  // --- Helper Functions ---

  // --- Helper Functions ---

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toLowerCase()) {
      case 'success':
        return Colors.green.shade600;
      case 'reject':
        return Colors.red.shade600;
      case 'pending':
        return Colors.orange.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getStatusIcon(String? status) {
    if (status == null) return Icons.help_outline_rounded;

    switch (status.toLowerCase()) {
      case 'success':
        return Icons.check_circle_rounded;
      case 'reject':
        return Icons.cancel_rounded;
      case 'pending':
        return Icons.schedule_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _formatDateTime(String? datetime) {
    if (datetime == null || datetime.isEmpty) return '-';

    try {
      final dateTime = DateTime.parse(datetime);
      return DateFormat('dd MMMM yyyy, HH:mm').format(dateTime);
    } catch (e) {
      return datetime;
    }
  }
}
