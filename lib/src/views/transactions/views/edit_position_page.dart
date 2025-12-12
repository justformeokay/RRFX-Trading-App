import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/colors/default.dart';

enum EditMode { price, points }

class EditPositionPageController extends GetxController {
  final RxDouble stopLoss;
  final RxDouble takeProfit;
  final RxDouble currentPrice;
  final double openPrice;
  final String direction;
  final int digits;

  // Track points
  final RxInt slPoints = 0.obs;
  final RxInt tpPoints = 0.obs;

  // Edit mode toggle
  final Rx<EditMode> editMode = EditMode.points.obs;

  EditPositionPageController({
    required double initialSL,
    required double initialTP,
    required double initialCurrentPrice,
    required this.openPrice,
    required this.direction,
    required this.digits,
  }) : stopLoss = initialSL.obs,
       takeProfit = initialTP.obs,
       currentPrice = initialCurrentPrice.obs {
    // Initialize points if SL/TP already set
    if (initialSL > 0) {
      slPoints.value = _calculatePointsFromPrice(initialSL, isStopLoss: true);
    }
    if (initialTP > 0) {
      tpPoints.value = _calculatePointsFromPrice(initialTP, isStopLoss: false);
    }
  }

  double get pipValue => 1 / (pow(10, digits));
  int get minPoints => 20;

  int _calculatePointsFromPrice(double price, {required bool isStopLoss}) {
    if (price == 0) return 0;
    final difference = (price - currentPrice.value).abs();
    final points = (difference / pipValue).round();
    return points;
  }

  double _calculateSLPrice(int points) {
    if (points == 0) return 0.0;
    if (direction.toLowerCase() == 'buy') {
      return currentPrice.value - (points * pipValue);
    } else {
      return currentPrice.value + (points * pipValue);
    }
  }

  double _calculateTPPrice(int points) {
    if (points == 0) return 0.0;
    if (direction.toLowerCase() == 'buy') {
      return currentPrice.value + (points * pipValue);
    } else {
      return currentPrice.value - (points * pipValue);
    }
  }

  // Public methods to recalculate prices based on points
  void recalculateSLFromPoints() {
    if (slPoints.value > 0) {
      stopLoss.value = double.parse(
        _calculateSLPrice(slPoints.value).toStringAsFixed(digits),
      );
    }
  }

  void recalculateTPFromPoints() {
    if (tpPoints.value > 0) {
      takeProfit.value = double.parse(
        _calculateTPPrice(tpPoints.value).toStringAsFixed(digits),
      );
    }
  }

  // POINTS MODE - SL
  void incrementSLPoints() {
    if (slPoints.value == 0) {
      slPoints.value = minPoints;
    } else {
      slPoints.value++;
    }
    stopLoss.value = double.parse(
      _calculateSLPrice(slPoints.value).toStringAsFixed(digits),
    );
  }

  void decrementSLPoints() {
    if (slPoints.value == 0) return;
    if (slPoints.value <= minPoints) return;
    slPoints.value--;
    stopLoss.value = double.parse(
      _calculateSLPrice(slPoints.value).toStringAsFixed(digits),
    );
  }

  // POINTS MODE - TP
  void incrementTPPoints() {
    if (tpPoints.value == 0) {
      tpPoints.value = minPoints;
    } else {
      tpPoints.value++;
    }
    takeProfit.value = double.parse(
      _calculateTPPrice(tpPoints.value).toStringAsFixed(digits),
    );
  }

  void decrementTPPoints() {
    if (tpPoints.value == 0) return;
    if (tpPoints.value <= minPoints) return;
    tpPoints.value--;
    takeProfit.value = double.parse(
      _calculateTPPrice(tpPoints.value).toStringAsFixed(digits),
    );
  }

  // PRICE MODE - SL
  void incrementSLPrice() {
    if (stopLoss.value == 0) {
      // First time: set to minimum
      slPoints.value = minPoints;
      stopLoss.value = double.parse(
        _calculateSLPrice(slPoints.value).toStringAsFixed(digits),
      );
    } else {
      stopLoss.value = double.parse(
        (stopLoss.value + pipValue).toStringAsFixed(digits),
      );
      slPoints.value = _calculatePointsFromPrice(
        stopLoss.value,
        isStopLoss: true,
      );
    }
  }

  void decrementSLPrice() {
    if (stopLoss.value == 0) return;

    final newValue = stopLoss.value - pipValue;
    final newPoints = _calculatePointsFromPrice(newValue, isStopLoss: true);

    if (newPoints < minPoints) return;

    stopLoss.value = double.parse(newValue.toStringAsFixed(digits));
    slPoints.value = newPoints;
  }

  // PRICE MODE - TP
  void incrementTPPrice() {
    if (takeProfit.value == 0) {
      // First time: set to minimum
      tpPoints.value = minPoints;
      takeProfit.value = double.parse(
        _calculateTPPrice(tpPoints.value).toStringAsFixed(digits),
      );
    } else {
      takeProfit.value = double.parse(
        (takeProfit.value + pipValue).toStringAsFixed(digits),
      );
      tpPoints.value = _calculatePointsFromPrice(
        takeProfit.value,
        isStopLoss: false,
      );
    }
  }

  void decrementTPPrice() {
    if (takeProfit.value == 0) return;

    final newValue = takeProfit.value - pipValue;
    final newPoints = _calculatePointsFromPrice(newValue, isStopLoss: false);

    if (newPoints < minPoints) return;

    takeProfit.value = double.parse(newValue.toStringAsFixed(digits));
    tpPoints.value = newPoints;
  }

  bool get canDecrementSL =>
      editMode.value == EditMode.points
          ? slPoints.value > minPoints
          : stopLoss.value > 0 &&
              _calculatePointsFromPrice(
                    stopLoss.value - pipValue,
                    isStopLoss: true,
                  ) >=
                  minPoints;

  bool get canDecrementTP =>
      editMode.value == EditMode.points
          ? tpPoints.value > minPoints
          : takeProfit.value > 0 &&
              _calculatePointsFromPrice(
                    takeProfit.value - pipValue,
                    isStopLoss: false,
                  ) >=
                  minPoints;

  void resetSL() {
    stopLoss.value = 0.0;
    slPoints.value = 0;
  }

  void resetTP() {
    takeProfit.value = 0.0;
    tpPoints.value = 0;
  }

  void setManualSL(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null) {
      final points = _calculatePointsFromPrice(parsed, isStopLoss: true);
      if (points >= minPoints) {
        stopLoss.value = double.parse(parsed.toStringAsFixed(digits));
        slPoints.value = points;
      }
    }
  }

  void setManualTP(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null) {
      final points = _calculatePointsFromPrice(parsed, isStopLoss: false);
      if (points >= minPoints) {
        takeProfit.value = double.parse(parsed.toStringAsFixed(digits));
        tpPoints.value = points;
      }
    }
  }

  void setManualSLPoints(String value) {
    final parsed = int.tryParse(value);
    if (parsed != null && parsed >= minPoints) {
      slPoints.value = parsed;
      stopLoss.value = double.parse(
        _calculateSLPrice(parsed).toStringAsFixed(digits),
      );
    }
  }

  void setManualTPPoints(String value) {
    final parsed = int.tryParse(value);
    if (parsed != null && parsed >= minPoints) {
      tpPoints.value = parsed;
      takeProfit.value = double.parse(
        _calculateTPPrice(parsed).toStringAsFixed(digits),
      );
    }
  }

  String formatPrice(double price) {
    if (price == 0.0) return "Not Set";
    return price.toStringAsFixed(digits);
  }

  String formatPoints(int points) {
    if (points == 0) return "0 pts";
    return "$points pts";
  }

  void toggleEditMode() {
    editMode.value =
        editMode.value == EditMode.points ? EditMode.price : EditMode.points;
  }
}

class EditPositionPage extends StatefulWidget {
  final String symbol;
  final String positionId;
  final String direction;
  final double openPrice;
  final double currentPrice;
  final double stopLoss;
  final double takeProfit;
  final int digits;
  final Rx<double> currentPriceObservable;
  final Function(double sl, double tp) onModify;

  const EditPositionPage({
    super.key,
    required this.symbol,
    required this.positionId,
    required this.direction,
    required this.openPrice,
    required this.currentPrice,
    required this.stopLoss,
    required this.takeProfit,
    required this.digits,
    required this.currentPriceObservable,
    required this.onModify,
  });

  @override
  State<EditPositionPage> createState() => _EditPositionPageState();
}

class _EditPositionPageState extends State<EditPositionPage> {
  late EditPositionPageController controller;
  StreamSubscription? priceSubscription;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      EditPositionPageController(
        initialSL: widget.stopLoss,
        initialTP: widget.takeProfit,
        initialCurrentPrice: widget.currentPrice,
        openPrice: widget.openPrice,
        direction: widget.direction,
        digits: widget.digits,
      ),
      tag: widget.positionId,
    );

    // Subscribe to price updates
    priceSubscription = widget.currentPriceObservable.listen((price) {
      controller.currentPrice.value = price;

      // Recalculate SL/TP prices based on points when current price changes
      controller.recalculateSLFromPoints();
      controller.recalculateTPFromPoints();
    });
  }

  @override
  void dispose() {
    priceSubscription?.cancel();
    Get.delete<EditPositionPageController>(tag: widget.positionId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        forceMaterialTransparency: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: onSurface),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Modify Position",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: onSurface,
              ),
            ),
            Text(
              "${widget.symbol} • #${widget.positionId}",
              style: GoogleFonts.inter(
                fontSize: 12,
                color: onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Position Info Card
                  _buildPositionInfoCard(theme, isDark, onSurface),

                  const SizedBox(height: 24),

                  // Edit Mode Toggle
                  _buildEditModeToggle(theme, isDark, onSurface),

                  const SizedBox(height: 24),

                  // Stop Loss Section
                  _buildSLSection(theme, isDark, onSurface),

                  const SizedBox(height: 20),

                  // Take Profit Section
                  _buildTPSection(theme, isDark, onSurface),
                ],
              ),
            ),
          ),

          // Bottom Action Button
          _buildBottomButton(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildPositionInfoCard(ThemeData theme, bool isDark, Color onSurface) {
    final directionColor =
        widget.direction.toLowerCase() == 'buy' ? Colors.blue : Colors.red;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Direction",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: directionColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.direction.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: directionColor,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Open Price",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.openPrice.toStringAsFixed(widget.digits),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: onSurface.withOpacity(0.1)),
          const SizedBox(height: 16),
          Obx(() {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Current Price",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: onSurface.withOpacity(0.6),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      controller.currentPrice.value.toStringAsFixed(
                        widget.digits,
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: CustomColor.secondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEditModeToggle(ThemeData theme, bool isDark, Color onSurface) {
    return Obx(() {
      final isPoints = controller.editMode.value == EditMode.points;
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.editMode.value = EditMode.points,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color:
                        isPoints
                            ? CustomColor.secondaryColor
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.hashtag_outline,
                        size: 18,
                        color:
                            isPoints
                                ? Colors.black
                                : onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Points",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color:
                              isPoints
                                  ? Colors.black
                                  : onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.editMode.value = EditMode.price,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color:
                        !isPoints
                            ? CustomColor.secondaryColor
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.dollar_circle_outline,
                        size: 18,
                        color:
                            !isPoints
                                ? Colors.black
                                : onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Price",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color:
                              !isPoints
                                  ? Colors.black
                                  : onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSLSection(ThemeData theme, bool isDark, Color onSurface) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Iconsax.shield_cross_outline,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Stop Loss",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                  ),
                ),
              ),
              TextButton(
                onPressed: controller.resetSL,
                child: Text(
                  "Reset",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CustomColor.secondaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            return _buildControlRow(
              theme: theme,
              isDark: isDark,
              onSurface: onSurface,
              value: controller.stopLoss.value,
              points: controller.slPoints.value,
              onDecrement:
                  controller.editMode.value == EditMode.points
                      ? controller.decrementSLPoints
                      : controller.decrementSLPrice,
              onIncrement:
                  controller.editMode.value == EditMode.points
                      ? controller.incrementSLPoints
                      : controller.incrementSLPrice,
              canDecrement: controller.canDecrementSL,
              onTap:
                  () => _showInputDialog(
                    context: context,
                    title: "Set Stop Loss",
                    isStopLoss: true,
                  ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTPSection(ThemeData theme, bool isDark, Color onSurface) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Iconsax.shield_tick_outline,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Take Profit",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                  ),
                ),
              ),
              TextButton(
                onPressed: controller.resetTP,
                child: Text(
                  "Reset",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CustomColor.secondaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            return _buildControlRow(
              theme: theme,
              isDark: isDark,
              onSurface: onSurface,
              value: controller.takeProfit.value,
              points: controller.tpPoints.value,
              onDecrement:
                  controller.editMode.value == EditMode.points
                      ? controller.decrementTPPoints
                      : controller.decrementTPPrice,
              onIncrement:
                  controller.editMode.value == EditMode.points
                      ? controller.incrementTPPoints
                      : controller.incrementTPPrice,
              canDecrement: controller.canDecrementTP,
              onTap:
                  () => _showInputDialog(
                    context: context,
                    title: "Set Take Profit",
                    isStopLoss: false,
                  ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildControlRow({
    required ThemeData theme,
    required bool isDark,
    required Color onSurface,
    required double value,
    required int points,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required bool canDecrement,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        // Decrement Button
        _buildControlButton(
          icon: Icons.remove,
          onPressed: canDecrement ? onDecrement : null,
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        // Value Display
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: CustomColor.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CustomColor.secondaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Obx(() {
                    final isPoints =
                        controller.editMode.value == EditMode.points;
                    return Text(
                      isPoints
                          ? controller.formatPoints(points)
                          : controller.formatPrice(value),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color:
                            value == 0.0
                                ? onSurface.withOpacity(0.4)
                                : CustomColor.secondaryColor,
                      ),
                    );
                  }),
                  if (value > 0) ...[
                    const SizedBox(height: 4),
                    Obx(() {
                      final isPoints =
                          controller.editMode.value == EditMode.points;
                      return Text(
                        isPoints
                            ? controller.formatPrice(value)
                            : controller.formatPoints(points),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: onSurface.withOpacity(0.5),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Increment Button
        _buildControlButton(
          icon: Icons.add,
          onPressed: onIncrement,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isDark,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color:
            onPressed != null
                ? CustomColor.secondaryColor
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: onPressed != null ? Colors.black : Colors.grey),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildBottomButton(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(() {
        final isSLSet = controller.stopLoss.value != 0.0;
        final isTPSet = controller.takeProfit.value != 0.0;
        final isEnabled = isSLSet || isTPSet;

        return SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed:
                isEnabled
                    ? () {
                      Get.back();
                      widget.onModify(
                        controller.stopLoss.value,
                        controller.takeProfit.value,
                      );
                    }
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomColor.secondaryColor,
              foregroundColor: Colors.black,
              disabledBackgroundColor: theme.colorScheme.onSurface.withOpacity(
                0.12,
              ),
              disabledForegroundColor: theme.colorScheme.onSurface.withOpacity(
                0.38,
              ),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.tick_circle_bold, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Modify Position",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showInputDialog({
    required BuildContext context,
    required String title,
    required bool isStopLoss,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPoints = controller.editMode.value == EditMode.points;

    final textController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isPoints
                      ? "Enter points (minimum ${controller.minPoints})"
                      : "Enter price (minimum ${controller.minPoints} points from current)",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: textController,
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: !isPoints,
                  ),
                  inputFormatters:
                      isPoints
                          ? [FilteringTextInputFormatter.digitsOnly]
                          : [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,5}'),
                            ),
                          ],
                  decoration: InputDecoration(
                    hintText:
                        isPoints
                            ? "20"
                            : controller.currentPrice.value.toStringAsFixed(
                              widget.digits,
                            ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: CustomColor.secondaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: CustomColor.secondaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  autofocus: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.inter(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final value = textController.text;
                  if (value.isNotEmpty) {
                    if (isPoints) {
                      if (isStopLoss) {
                        controller.setManualSLPoints(value);
                      } else {
                        controller.setManualTPPoints(value);
                      }
                    } else {
                      if (isStopLoss) {
                        controller.setManualSL(value);
                      } else {
                        controller.setManualTP(value);
                      }
                    }
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColor.secondaryColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Set",
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
    );
  }
}
