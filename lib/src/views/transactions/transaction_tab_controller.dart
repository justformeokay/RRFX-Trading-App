import 'package:get/get.dart';

/// Tracks which tab is currently visible in TransactionTab.
/// Used by child tabs (e.g. PendingOrdersPage) to pause/resume
/// their WebSocket connections when they're not on screen.
class TransactionTabController extends GetxController {
  final currentIndex = 0.obs;
}
