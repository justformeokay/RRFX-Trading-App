import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.transactionDetail.value == null) {
          return const Center(child: Text('Data transaksi tidak tersedia.'));
        }

        final data = controller.transactionDetail.value!;
        final statusColor = _getStatusColor(data.response?.status);
        final formattedDate = _formatDateTime(data.response?.datetime);

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Header: Status dan Jumlah
            _buildStatusHeader(data.response?.status, data.response?.amountReceived, statusColor),
            const SizedBox(height: 24),
            
            // Detail Transaksi Umum
            _buildSectionHeader(context, 'Informasi Umum'),
            _buildInfoCard(
              children: [
                _buildInfoRow('ID Transaksi', data.response?.id),
                _buildInfoRow('Tipe', data.response?.type),
                _buildInfoRow('Tanggal & Waktu', formattedDate),
                _buildInfoRow('Login ID', data.response?.login),
              ],
            ),
            const SizedBox(height: 16),

            // Detail Bank
            _buildSectionHeader(context, 'Detail Bank'),
            _buildInfoCard(
              children: [
                _buildInfoRow('Bank', data.response?.bankUser?.name ?? '-'),
                _buildInfoRow('No. Rekening', data.response?.bankUser?.accountNumber ?? '-'),
                _buildInfoRow('Nama Akun', data.response?.bankUser?.accountName ?? '-'),
              ],
            ),
            const SizedBox(height: 16),

            // Detail Tambahan (contoh: bank admin)
            _buildSectionHeader(context, 'Keterangan Tambahan'),
            _buildInfoCard(
              children: [
                _buildInfoRow('Bank Admin', data.response?.bankAdmin?.name ?? '-'),
                _buildInfoRow('No. Rekening Admin', data.response?.bankAdmin?.name ?? '-'),
                _buildInfoRow('Nama Akun Admin', data.response?.bankAdmin?.name ?? '-'),
              ],
            ),
          ],
        );
      }),
    );
  }

  // --- Widget & Helper Functions ---
  Widget _buildStatusHeader(String status, String amount, Color color) {
    return Column(
      children: [
        Icon(
          _getStatusIcon(status),
          size: 64,
          color: color,
        ),
        const SizedBox(height: 8),
        Text(
          amount,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Get.isDarkMode ? Colors.white70 : Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'reject':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Icons.check_circle_outline;
      case 'reject':
        return Icons.cancel_outlined;
      case 'pending':
        return Icons.access_time_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String _formatDateTime(String datetime) {
    try {
      final dateTime = DateTime.parse(datetime);
      return DateFormat('dd MMMM yyyy, HH:mm').format(dateTime);
    } catch (e) {
      return datetime;
    }
  }
}