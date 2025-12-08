import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/colors/default.dart';

class EditPositionController extends GetxController {
  final RxDouble stopLoss;
  final RxDouble takeProfit;
  final RxDouble currentPrice;
  final double openPrice;
  final String direction;
  final int digits;

  // Track if user has interacted with SL/TP
  final RxBool _slInitialized = false.obs;
  final RxBool _tpInitialized = false.obs;

  EditPositionController({
    required double initialSL,
    required double initialTP,
    required double initialCurrentPrice,
    required this.openPrice,
    required this.direction,
    required this.digits,
  }) : stopLoss = initialSL.obs,
       takeProfit = initialTP.obs,
       currentPrice = initialCurrentPrice.obs;

  // Calculate pip value based on digits
  // digits 2 -> 0.01, digits 3 -> 0.001, digits 5 -> 0.00001
  double get pipValue => 1 / (pow(10, digits));

  void incrementSL() {
    // First time: set to current price
    if (!_slInitialized.value) {
      stopLoss.value = double.parse(currentPrice.value.toStringAsFixed(digits));
      _slInitialized.value = true;
    }
    stopLoss.value = double.parse(
      (stopLoss.value + pipValue).toStringAsFixed(digits),
    );
  }

  void decrementSL() {
    // First time: set to current price
    if (!_slInitialized.value) {
      stopLoss.value = double.parse(currentPrice.value.toStringAsFixed(digits));
      _slInitialized.value = true;
    }
    stopLoss.value = double.parse(
      (stopLoss.value - pipValue).toStringAsFixed(digits),
    );
  }

  void incrementTP() {
    // First time: set to current price
    if (!_tpInitialized.value) {
      takeProfit.value = double.parse(
        currentPrice.value.toStringAsFixed(digits),
      );
      _tpInitialized.value = true;
    }
    takeProfit.value = double.parse(
      (takeProfit.value + pipValue).toStringAsFixed(digits),
    );
  }

  void decrementTP() {
    // First time: set to current price
    if (!_tpInitialized.value) {
      takeProfit.value = double.parse(
        currentPrice.value.toStringAsFixed(digits),
      );
      _tpInitialized.value = true;
    }
    takeProfit.value = double.parse(
      (takeProfit.value - pipValue).toStringAsFixed(digits),
    );
  }

  void resetSL() {
    stopLoss.value = 0.0;
    _slInitialized.value = false;
  }

  void resetTP() {
    takeProfit.value = 0.0;
    _tpInitialized.value = false;
  }

  String formatPrice(double price) {
    if (price == 0.0) return "Not Set";
    return price.toStringAsFixed(digits);
  }
}

Future<void> showEditPositionDialog({
  required BuildContext context,
  required String symbol,
  required String positionId,
  required String direction,
  required double openPrice,
  required double currentPrice,
  required double stopLoss,
  required double takeProfit,
  required int digits,
  required Rx<double> currentPriceObservable,
  required Function(double sl, double tp) onModify,
}) async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  final onSurface = theme.colorScheme.onSurface;
  final onSurfaceVariant = onSurface.withOpacity(0.6);
  final primary = CustomColor.secondaryColor;

  final sheetColor =
      theme.bottomSheetTheme.backgroundColor ??
      (isDark ? const Color(0xFF121212) : Colors.white);

  final controller = Get.put(
    EditPositionController(
      initialSL: stopLoss,
      initialTP: takeProfit,
      initialCurrentPrice: currentPrice,
      openPrice: openPrice,
      direction: direction,
      digits: digits,
    ),
    tag: positionId,
  );

  // Listen to current price observable
  final worker = ever(currentPriceObservable, (price) {
    controller.currentPrice.value = price;
  });

  await showModalBottomSheet(
    context: context,
    backgroundColor: sheetColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    isScrollControlled: true,
    builder: (_) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // DRAG HANDLE
              Container(
                width: 45,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: onSurface.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // TITLE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Modify Position",
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$symbol • #$positionId",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          direction.toLowerCase() == 'buy'
                              ? Colors.green.withOpacity(0.15)
                              : Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      direction.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color:
                            direction.toLowerCase() == 'buy'
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // CURRENT PRICE CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primary.withOpacity(0.1),
                      primary.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: primary.withOpacity(0.3), width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      "Current Price",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Text(
                        controller.formatPrice(controller.currentPrice.value),
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Open: ",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: onSurfaceVariant,
                          ),
                        ),
                        Text(
                          controller.formatPrice(openPrice),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // STOP LOSS SECTION
              _buildPriceControl(
                context: context,
                label: "Stop Loss",
                icon: Icons.arrow_downward_rounded,
                iconColor: Colors.red,
                controller: controller,
                isStopLoss: true,
                onIncrement: controller.incrementSL,
                onDecrement: controller.decrementSL,
                onReset: controller.resetSL,
                valueObservable: controller.stopLoss,
              ),

              const SizedBox(height: 16),

              // TAKE PROFIT SECTION
              _buildPriceControl(
                context: context,
                label: "Take Profit",
                icon: Icons.arrow_upward_rounded,
                iconColor: Colors.green,
                controller: controller,
                isStopLoss: false,
                onIncrement: controller.incrementTP,
                onDecrement: controller.decrementTP,
                onReset: controller.resetTP,
                valueObservable: controller.takeProfit,
              ),

              const SizedBox(height: 24),

              // MODIFY BUTTON
              Obx(() {
                final isSLSet = controller.stopLoss.value != 0.0;
                final isTPSet = controller.takeProfit.value != 0.0;
                final isEnabled = isSLSet && isTPSet;

                return SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isEnabled
                        ? () {
                            Get.back();
                            onModify(
                              controller.stopLoss.value,
                              controller.takeProfit.value,
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: onSurface.withOpacity(0.12),
                      disabledForegroundColor: onSurface.withOpacity(0.38),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      "Modify Position",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  ).whenComplete(() {
    worker.dispose();
    Get.delete<EditPositionController>(tag: positionId);
  });
}

Widget _buildPriceControl({
  required BuildContext context,
  required String label,
  required IconData icon,
  required Color iconColor,
  required EditPositionController controller,
  required bool isStopLoss,
  required VoidCallback onIncrement,
  required VoidCallback onDecrement,
  required VoidCallback onReset,
  required RxDouble valueObservable,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final onSurface = theme.colorScheme.onSurface;
  final surface = theme.colorScheme.surface;

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF1E1E1E) : surface.withOpacity(0.5),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: onSurface.withOpacity(0.1), width: 1),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                ),
              ),
            ),
            TextButton(
              onPressed: onReset,
              style: TextButton.styleFrom(
                foregroundColor: CustomColor.secondaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                "Reset",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // DECREMENT BUTTON
            _buildControlButton(
              context: context,
              icon: Icons.remove,
              onPressed: onDecrement,
            ),
            const SizedBox(width: 12),
            // VALUE DISPLAY
            Expanded(
              child: Obx(() {
                final value = valueObservable.value;
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: CustomColor.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    controller.formatPrice(value),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color:
                          value == 0.0
                              ? onSurface.withOpacity(0.4)
                              : CustomColor.secondaryColor,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(width: 12),
            // INCREMENT BUTTON
            _buildControlButton(
              context: context,
              icon: Icons.add,
              onPressed: onIncrement,
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildControlButton({
  required BuildContext context,
  required IconData icon,
  required VoidCallback onPressed,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return _HoldableButton(
    onPressed: onPressed,
    child: Material(
      color: isDark ? const Color(0xFF2A2A2A) : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.onSurface.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Icon(icon, color: CustomColor.secondaryColor, size: 22),
      ),
    ),
  );
}

class _HoldableButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const _HoldableButton({required this.onPressed, required this.child});

  @override
  State<_HoldableButton> createState() => _HoldableButtonState();
}

class _HoldableButtonState extends State<_HoldableButton> {
  bool _isHolding = false;
  Timer? _timer;
  Timer? _accelerationTimer;
  int _holdDuration = 0;

  void _startHolding() {
    setState(() => _isHolding = true);

    // Execute immediately on press
    widget.onPressed();

    // Start repeating after initial delay
    _timer = Timer(const Duration(milliseconds: 200), () {
      _holdDuration = 0;
      _startRepeating();
    });
  }

  void _startRepeating() {
    _accelerationTimer?.cancel();

    // Start with slower interval
    int interval = 100;

    _accelerationTimer = Timer.periodic(Duration(milliseconds: interval), (
      timer,
    ) {
      widget.onPressed();
      _holdDuration++;

      // Accelerate after holding for a while
      if (_holdDuration > 10 && interval > 50) {
        timer.cancel();
        _startRepeating(); // Restart with faster interval
      } else if (_holdDuration > 20 && interval > 30) {
        timer.cancel();
        _accelerationTimer = Timer.periodic(const Duration(milliseconds: 30), (
          _,
        ) {
          widget.onPressed();
        });
      }
    });
  }

  void _stopHolding() {
    setState(() => _isHolding = false);
    _timer?.cancel();
    _accelerationTimer?.cancel();
    _holdDuration = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _accelerationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _startHolding(),
      onTapUp: (_) => _stopHolding(),
      onTapCancel: _stopHolding,
      child: widget.child,
    );
  }
}
