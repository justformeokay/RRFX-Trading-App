import 'package:flutter/material.dart';
import '../../data/models/timeframe_model.dart';
import '../../data/models/chart_config.dart';

/// Timeframe selector widget
class TimeframeSelector extends StatelessWidget {
  final ChartTimeframe currentTimeframe;
  final ValueChanged<ChartTimeframe> onTimeframeChanged;
  final ChartConfig? config;
  final List<ChartTimeframe>? availableTimeframes;
  
  const TimeframeSelector({
    super.key,
    required this.currentTimeframe,
    required this.onTimeframeChanged,
    this.config,
    this.availableTimeframes,
  });
  
  @override
  Widget build(BuildContext context) {
    final timeframes = availableTimeframes ?? ChartTimeframe.values;
    final effectiveConfig = config ?? const ChartConfig();
    
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: effectiveConfig.backgroundColor,
        border: Border(
          bottom: BorderSide(color: effectiveConfig.gridLineColor, width: 1),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: timeframes.length,
        itemBuilder: (context, index) {
          final timeframe = timeframes[index];
          final isSelected = timeframe == currentTimeframe;
          
          return _TimeframeButton(
            timeframe: timeframe,
            isSelected: isSelected,
            config: effectiveConfig,
            onTap: () => onTimeframeChanged(timeframe),
          );
        },
      ),
    );
  }
}

class _TimeframeButton extends StatelessWidget {
  final ChartTimeframe timeframe;
  final bool isSelected;
  final ChartConfig config;
  final VoidCallback onTap;
  
  const _TimeframeButton({
    required this.timeframe,
    required this.isSelected,
    required this.config,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? config.currentPriceLabelColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected
                ? config.currentPriceLabelColor
                : Colors.transparent,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          timeframe.displayName,
          style: TextStyle(
            color: isSelected
                ? config.currentPriceLabelColor
                : config.textColor.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/// Compact timeframe selector for tight spaces
class CompactTimeframeSelector extends StatelessWidget {
  final ChartTimeframe currentTimeframe;
  final ValueChanged<ChartTimeframe> onTimeframeChanged;
  final ChartConfig? config;
  
  const CompactTimeframeSelector({
    super.key,
    required this.currentTimeframe,
    required this.onTimeframeChanged,
    this.config,
  });
  
  @override
  Widget build(BuildContext context) {
    final effectiveConfig = config ?? const ChartConfig();
    
    return PopupMenuButton<ChartTimeframe>(
      initialValue: currentTimeframe,
      onSelected: onTimeframeChanged,
      offset: const Offset(0, 36),
      color: effectiveConfig.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: effectiveConfig.gridLineColor),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: effectiveConfig.backgroundColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: effectiveConfig.gridLineColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentTimeframe.displayName,
              style: TextStyle(
                color: effectiveConfig.textColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: effectiveConfig.textColor.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
      itemBuilder: (context) {
        return ChartTimeframe.values.map((timeframe) {
          final isSelected = timeframe == currentTimeframe;
          return PopupMenuItem<ChartTimeframe>(
            value: timeframe,
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: effectiveConfig.currentPriceLabelColor,
                        )
                      : null,
                ),
                Text(
                  timeframe.displayName,
                  style: TextStyle(
                    color: isSelected
                        ? effectiveConfig.currentPriceLabelColor
                        : effectiveConfig.textColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const Spacer(),
                Text(
                  _getTimeframeDuration(timeframe),
                  style: TextStyle(
                    color: effectiveConfig.textColor.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
  
  String _getTimeframeDuration(ChartTimeframe timeframe) {
    switch (timeframe) {
      case ChartTimeframe.m1:
        return '1 minute';
      case ChartTimeframe.m5:
        return '5 minutes';
      case ChartTimeframe.m15:
        return '15 minutes';
      case ChartTimeframe.m30:
        return '30 minutes';
      case ChartTimeframe.h1:
        return '1 hour';
      case ChartTimeframe.h4:
        return '4 hours';
      case ChartTimeframe.d1:
        return '1 day';
      case ChartTimeframe.w1:
        return '1 week';
      case ChartTimeframe.mn:
        return '1 month';
    }
  }
}
