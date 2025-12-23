// HOW TO INTEGRATE NETWORK SPEED CHECK TO YOUR TRANSACTION PAGES
// Copy & paste examples sesuai kebutuhan

// ========================================
// OPTION 1: MINIMAL INTEGRATION
// ========================================
// Gunakan ini jika hanya perlu auto-warning saja
// (Tidak perlu buat apapun - sudah berjalan otomatis!)

// Behavior:
// ✓ Auto-check saat app launch
// ✓ Auto-check saat koneksi berubah
// ✓ Warning dialog muncul jika speed > 100ms
// ✓ Transparent ke user

/*
  Status: ✅ ALREADY IMPLEMENTED
  Location: main.dart (initState already added)
*/

// ========================================
// OPTION 2: DISPLAY INDICATOR ON PAGE
// ========================================
// Gunakan ini untuk show network status di halaman

import 'package:flutter/material.dart';
import 'package:rrfx/src/components/widgets/network_speed_indicator.dart';

class YourTransactionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Compact indicator di header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Network Status:'),
                NetworkSpeedIndicator(showDetailedInfo: false),
              ],
            ),
            const SizedBox(height: 24),

            // Form transaksi Anda
            // ...

            // Atau detailed indicator di tengah
            const SizedBox(height: 24),
            const NetworkSpeedIndicator(showDetailedInfo: true),
          ],
        ),
      ),
    );
  }
}

// ========================================
// OPTION 3: MANUAL CHECK SEBELUM TRANSAKSI
// ========================================
// Gunakan ini untuk check sebelum submit

import 'package:get/get.dart';
import 'package:rrfx/src/controllers/network_controller.dart';
import 'package:rrfx/src/components/popups/network_speed_dialog.dart';

class TransactionFormPage extends GetView<NetworkController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Your transaction form here

          ElevatedButton(
            onPressed: () async {
              // Step 1: Check network speed
              await controller.checkNetworkSpeed();

              // Step 2: Get the speed value
              final speed = controller.networkSpeed.value;

              // Step 3: Handle based on speed
              if (speed > 100) {
                print('Koneksi lambat: ${speed}ms');
                // Dialog sudah ditampilkan otomatis
                return; // Jangan lanjutkan transaksi
              }

              // Step 4: Proceed dengan transaksi
              print('Koneksi OK: ${speed}ms');
              await _processTransaction();
            },
            child: const Text('Proses Transaksi'),
          ),
        ],
      ),
    );
  }

  Future<void> _processTransaction() async {
    // Your transaction logic here
  }
}

// ========================================
// OPTION 4: CUSTOM HANDLING
// ========================================
// Gunakan untuk custom behavior

import 'package:rrfx/src/service/network_speed_service.dart';

Future<void> customNetworkCheck() async {
  try {
    // Get speed tanpa dialog
    final speed = await NetworkSpeedService.measureNetworkSpeedWithRetry(
      retryCount: 3, // Lebih akurat
    );

    if (speed == null) {
      // Error handling
      print('Gagal mengukur network speed');
      return;
    }

    // Custom logic berdasarkan speed
    if (speed <= 50) {
      print('Excellent connection: ${speed}ms');
      // Fast path for transaction
    } else if (speed <= 100) {
      print('Good connection: ${speed}ms');
      // Normal path for transaction
    } else if (speed <= 200) {
      print('Slow connection: ${speed}ms');
      // Show warning but allow
      // NetworkSpeedDialog.showUnstableConnectionDialog(speed);
    } else {
      print('Very slow connection: ${speed}ms');
      // Reject transaction
      // Show error dialog
    }
  } catch (e) {
    print('Error: $e');
  }
}

// ========================================
// OPTION 5: PERIODIC MONITORING
// ========================================
// Gunakan untuk continuous monitoring

import 'dart:async';

class TransactionPageWithMonitoring extends StatefulWidget {
  @override
  State<TransactionPageWithMonitoring> createState() =>
      _TransactionPageWithMonitoringState();
}

class _TransactionPageWithMonitoringState
    extends State<TransactionPageWithMonitoring> {
  late Timer _monitoringTimer;
  final networkController = Get.find<NetworkController>();

  @override
  void initState() {
    super.initState();
    
    // Check every 10 seconds
    _monitoringTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      networkController.checkNetworkSpeed();
    });
  }

  @override
  void dispose() {
    _monitoringTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Your page content
        ],
      ),
    );
  }
}

// ========================================
// OPTION 6: TRANSACTION CONFIRMATION DIALOG
// ========================================
// Gunakan untuk ask user sebelum proceed

Future<bool> _showNetworkConfirmation(int speed) async {
  return await Get.dialog<bool>(
    AlertDialog(
      title: const Text('Konfirmasi Transaksi'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Kecepatan jaringan saat ini: ${speed}ms',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (speed > 100) ...[
            Text(
              '⚠️ Koneksi tidak stabil. Transaksi mungkin gagal.',
              style: TextStyle(color: Colors.red.shade600),
            ),
            const SizedBox(height: 12),
          ],
          const Text('Lanjutkan transaksi?'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Get.back(result: true),
          child: const Text('Lanjutkan'),
        ),
      ],
    ),
  ) ??
      false;
}

// Usage:
Future<void> _submitTransaction() async {
  final networkController = Get.find<NetworkController>();

  // Check speed
  final speed = networkController.networkSpeed.value;

  // Ask confirmation if slow
  if (speed > 100) {
    final proceed = await _showNetworkConfirmation(speed);
    if (!proceed) return;
  }

  // Process transaction
  // ...
}

// ========================================
// OPTION 7: DISABLE BUTTON BASED ON SPEED
// ========================================
// Gunakan untuk disable submit jika koneksi lambat

import 'package:rrfx/src/controllers/theme_controller.dart';

class SmartTransactionButton extends GetView<NetworkController> {
  final VoidCallback onPressed;

  const SmartTransactionButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final speed = controller.networkSpeed.value;
      final isSlowNetwork = speed > 150;
      final isChecking = controller.isCheckingSpeed.value;

      return Column(
        children: [
          ElevatedButton(
            onPressed:
                isSlowNetwork || isChecking ? null : onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isChecking)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                if (isChecking) const SizedBox(width: 8),
                Text(isChecking ? 'Checking Network...' : 'Process Transaction'),
              ],
            ),
          ),
          if (isSlowNetwork) ...[
            const SizedBox(height: 8),
            Text(
              '⚠️ Network too slow (${speed}ms)',
              style: TextStyle(color: Colors.red.shade400, fontSize: 12),
            ),
          ],
        ],
      );
    });
  }
}

// ========================================
// INTEGRATION CHECKLIST
// ========================================
/*
Pilih salah satu atau kombinasi:

[ ] Option 1 - Minimal (Default)
    └─ Sudah berjalan otomatis, tidak perlu setup

[ ] Option 2 - Display Indicator
    └─ Tambahkan widget ke halaman
    └─ 5 menit setup

[ ] Option 3 - Manual Check Before Transaction
    └─ Add check sebelum submit
    └─ 10 menit setup

[ ] Option 4 - Custom Handling
    └─ Custom logic untuk speed tiers
    └─ 15 menit setup

[ ] Option 5 - Periodic Monitoring
    └─ Check every X seconds
    └─ 20 menit setup

[ ] Option 6 - Confirmation Dialog
    └─ Ask user untuk proceed
    └─ 15 menit setup

[ ] Option 7 - Smart Button
    └─ Disable button jika slow network
    └─ 20 menit setup

Recommended untuk production:
✓ Option 1 (auto)
✓ Option 2 (indicator)
✓ Option 3 (manual check)

Kombinasi terbaik:
- Option 1 + Option 2 + Option 3
- Total setup time: ~30 menit
*/

// ========================================
// COMMON IMPLEMENTATIONS EXAMPLES
// ========================================

// Example 1: E-commerce Transaction
class CheckoutPage extends GetView<NetworkController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const NetworkSpeedIndicator(showDetailedInfo: true),
          ElevatedButton(
            onPressed: () async {
              // Check before checkout
              await controller.checkNetworkSpeed();
              if (controller.networkSpeed.value > 100) {
                return; // Stop if slow
              }
              // Proceed
            },
            child: const Text('Checkout'),
          ),
        ],
      ),
    );
  }
}

// Example 2: Withdrawal/Transfer
class WithdrawalPage extends StatelessWidget {
  final networkController = Get.find<NetworkController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Show network indicator
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Network:'),
                      NetworkSpeedIndicator(showDetailedInfo: false),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Form
              // ...
            ],
          ),
        ),
      ),
    );
  }
}

// Example 3: Trading (Real-time)
class TradingPage extends GetView<NetworkController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trading'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              final speed = controller.networkSpeed.value;
              final color = speed <= 100 ? Colors.green : Colors.red;
              return Center(
                child: Text(
                  speed > 0 ? '${speed}ms' : 'N/A',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          // Trading content
        ],
      ),
    );
  }
}

// ========================================
// DEPLOYMENT CHECKLIST
// ========================================
/*
Before going to production:

[ ] Test all network conditions
    - Good network (< 50ms)
    - Normal network (50-100ms)
    - Slow network (> 100ms)
    - No network

[ ] Test on different devices
    - Android
    - iOS

[ ] Test themes
    - Light mode
    - Dark mode

[ ] Test dialogs
    - Dialog appears correctly
    - Buttons work
    - Can dismiss

[ ] Test indicators
    - Compact view
    - Detailed view
    - Colors update

[ ] Performance test
    - No lag
    - Memory usage normal
    - No memory leaks

[ ] User testing
    - Clear messaging
    - No confusion
    - Good UX

[ ] Analytics
    - Track network speed distribution
    - Monitor failure rates
    - User feedback
*/
