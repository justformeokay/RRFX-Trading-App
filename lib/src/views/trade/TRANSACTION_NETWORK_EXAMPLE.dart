// CONTOH IMPLEMENTASI NETWORK SPEED CHECK DI HALAMAN TRANSAKSI
// Copy dan integrasikan ke halaman transaksi Anda

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/controllers/network_controller.dart';
import 'package:rrfx/src/components/widgets/network_speed_indicator.dart';

class TransactionPageExample extends StatefulWidget {
  const TransactionPageExample({super.key});

  @override
  State<TransactionPageExample> createState() => _TransactionPageExampleState();
}

class _TransactionPageExampleState extends State<TransactionPageExample> {
  final networkController = Get.find<NetworkController>();

  // Contoh method untuk proses transaksi
  Future<void> processTransaction() async {
    // 1. Cek network speed sebelum transaksi
    final speed = networkController.networkSpeed.value;
    
    if (speed > 100) {
      // Tampilkan warning
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Koneksi lambat (${speed}ms). Transaksi mungkin gagal.'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      
      // Tanya konfirmasi ke user
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Koneksi Tidak Stabil'),
          content: Text('Latency saat ini: ${speed}ms.\nLanjutkan transaksi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Lanjutkan'),
            ),
          ],
        ),
      );
      
      if (shouldContinue != true) return;
    }
    
    // 2. Lanjutkan transaksi
    // Your transaction logic here
    print('Transaction started with speed: ${speed}ms');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        actions: [
          // Action button untuk check network speed
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: networkController.checkNetworkSpeed,
              child: Obx(() {
                final speed = networkController.networkSpeed.value;
                final color = speed <= 100 ? Colors.green : Colors.red;
                return Center(
                  child: Text(
                    speed > 0 ? '${speed}ms' : 'Checking...',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Compact Network Speed Indicator
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Network Status:'),
                    NetworkSpeedIndicator(showDetailedInfo: false),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Detailed Network Speed Indicator
            const NetworkSpeedIndicator(showDetailedInfo: true),
            const SizedBox(height: 24),

            // Transaction Form
            Text(
              'Detail Transaksi',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Nominal',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Tujuan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button dengan Network Speed Check
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: processTransaction,
                icon: const Icon(Icons.send),
                label: const Text('Proses Transaksi'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Manual Check Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: networkController.checkNetworkSpeed,
                icon: const Icon(Icons.refresh),
                label: const Text('Cek Kecepatan Jaringan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// CONTOH PENGGUNAAN DI DALAM FUNCTION
// ============================================

/// Contoh: Check network speed sebelum melakukan API call
Future<void> exampleApiCallWithNetworkCheck() async {
  final networkController = Get.find<NetworkController>();
  
  // Cek speed sebelum API call
  final speed = await networkController.getNetworkSpeed();
  
  if (speed != null) {
    print('Network speed: ${speed}ms');
    
    if (speed > 100) {
      print('Warning: Slow network detected!');
    }
  }
  
  // Lanjutkan API call dengan backoff jika perlu
  // await api.call();
}

/// Contoh: Continuous monitoring dengan Obx
Widget exampleContinuousMonitoring() {
  final networkController = Get.find<NetworkController>();
  
  return Obx(() {
    final speed = networkController.networkSpeed.value;
    final isGood = speed <= 100 && speed > 0;
    
    return Container(
      color: isGood ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            isGood ? 'Jaringan Baik' : 'Jaringan Lambat',
            style: TextStyle(
              color: isGood ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (speed > 0) Text('Latency: ${speed}ms'),
        ],
      ),
    );
  });
}
