// TESTING & DEBUG REFERENCE
// Gunakan kode ini untuk testing network speed feature

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/controllers/network_controller.dart';
import 'package:rrfx/src/components/widgets/network_speed_indicator.dart';

/// Debug page untuk test semua fitur network speed
class NetworkSpeedDebugPage extends StatefulWidget {
  const NetworkSpeedDebugPage({super.key});

  @override
  State<NetworkSpeedDebugPage> createState() => _NetworkSpeedDebugPageState();
}

class _NetworkSpeedDebugPageState extends State<NetworkSpeedDebugPage> {
  final networkController = Get.find<NetworkController>();
  final List<String> logs = [];

  void _addLog(String message) {
    setState(() {
      logs.insert(0, '[${DateTime.now().toIso8601String()}] $message');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Speed Debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => setState(() => logs.clear()),
            tooltip: 'Clear logs',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Status',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Obx(() {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Network Connected: ${networkController.hasConnection.value}'),
                            Text('Network Speed: ${networkController.networkSpeed.value}ms'),
                            Text('Is Checking: ${networkController.isCheckingSpeed.value}'),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Network Speed Indicator Preview
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Indicator Preview',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      NetworkSpeedIndicator(showDetailedInfo: false),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      const NetworkSpeedIndicator(showDetailedInfo: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Actions',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            _addLog('Checking network speed...');
                            await networkController.checkNetworkSpeed();
                            _addLog('Network speed check completed: ${networkController.networkSpeed.value}ms');
                          },
                          child: const Text('Check Network Speed (with Dialog)'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () async {
                            _addLog('Getting network speed...');
                            final speed = await networkController.getNetworkSpeed();
                            _addLog('Got network speed: ${speed}ms');
                          },
                          child: const Text('Get Network Speed (Silent)'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            _addLog('Simulating warning dialog...');
                            // Simulate slow network
                            networkController.networkSpeed.value = 150;
                          },
                          child: const Text('Simulate Slow Network (150ms)'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            _addLog('Simulating good network...');
                            // Simulate good network
                            networkController.networkSpeed.value = 45;
                          },
                          child: const Text('Simulate Good Network (45ms)'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Logs
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Activity Logs (${logs.length})',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (logs.isNotEmpty)
                            TextButton.icon(
                              onPressed: () => setState(() => logs.clear()),
                              icon: const Icon(Icons.delete_outline, size: 18),
                              label: const Text('Clear'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 300),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: logs.isEmpty
                            ? Center(
                                child: Text(
                                  'No logs yet',
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              )
                            : SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: SelectableText(
                                    logs.join('\n'),
                                    style: const TextStyle(
                                      color: Colors.greenAccent,
                                      fontFamily: 'Courier',
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Info Section
              Card(
                color: Colors.blue.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💡 Debug Info',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fitur ini mengukur latency dengan HTTP HEAD request ke google.com. '
                        'Jika latency > 100ms, warning dialog akan ditampilkan. '
                        'Threshold dapat diubah di network_controller.dart',
                        style: Theme.of(context).textTheme.bodySmall,
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

// ============================================
// TEST CASES & MANUAL TESTING GUIDE
// ============================================

/*
MANUAL TESTING CHECKLIST:

1. ✅ Test Auto-trigger on App Launch
   - Run app
   - Verify "Checking Speed" dialog appears
   - Verify speed is measured and dialog closes
   - Check console for: "Network Speed: Xms"

2. ✅ Test Warning Dialog (Speed > 100ms)
   - Simulate slow network: tap "Simulate Slow Network (150ms)"
   - Verify warning dialog appears with:
     - WiFi icon in circle
     - "Koneksi Tidak Stabil" title
     - Latency info showing 150ms
     - Tips/recommendations
     - Action buttons

3. ✅ Test Good Network (Speed <= 100ms)
   - Simulate good network: tap "Simulate Good Network (45ms)"
   - Verify no warning dialog
   - Verify indicator shows green status

4. ✅ Test Dark Mode
   - Switch app to dark mode
   - Trigger network check
   - Verify dialog has dark theme colors
   - Verify contrast is good
   - Verify button styles are correct

5. ✅ Test Light Mode
   - Switch app to light mode
   - Trigger network check
   - Verify dialog has light theme colors
   - Verify text is readable

6. ✅ Test Manual Check
   - Tap "Check Network Speed (with Dialog)"
   - Verify loading dialog appears
   - Verify speed is measured
   - Verify dialog closes and speed is displayed

7. ✅ Test Silent Check
   - Tap "Get Network Speed (Silent)"
   - Verify no dialog appears
   - Verify speed is updated in status
   - Check console for speed value

8. ✅ Test Indicator Widget
   - Observe compact indicator
   - Observe detailed indicator
   - Change speed values
   - Verify colors update correctly (green/amber/red)

9. ✅ Test Connection Change
   - Turn off WiFi/data
   - Turn back on
   - Verify network check is triggered automatically
   - Verify speed is re-measured

10. ✅ Test Dialog Actions
    - Tap "Tutup" button - dialog closes
    - Tap "Coba Lagi" button - dialog closes

EXPECTED RESULTS:
- All dialogs render correctly
- Colors match theme
- No crashes or errors
- Console logs are informative
- UI is responsive
*/
