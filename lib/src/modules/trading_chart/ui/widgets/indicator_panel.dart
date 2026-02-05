import 'package:flutter/material.dart';
import '../../controller/trading_chart_controller.dart';
import '../../data/models/chart_config.dart';
import '../../data/models/indicator_model.dart';

/// Panel for managing indicators on the chart
class IndicatorPanel extends StatelessWidget {
  final TradingChartController controller;
  final ChartConfig? config;
  final VoidCallback? onAddIndicator;
  
  const IndicatorPanel({
    super.key,
    required this.controller,
    this.config,
    this.onAddIndicator,
  });
  
  @override
  Widget build(BuildContext context) {
    final effectiveConfig = config ?? controller.config;
    final indicators = controller.indicators;
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: effectiveConfig.backgroundColor,
        border: Border(
          bottom: BorderSide(color: effectiveConfig.gridLineColor),
        ),
      ),
      child: Row(
        children: [
          // Active indicators
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ...indicators.map((indicator) => _IndicatorChip(
                  indicator: indicator,
                  config: effectiveConfig,
                  onToggleVisibility: () => controller.toggleIndicatorVisibility(indicator.id),
                  onRemove: () => controller.removeIndicator(indicator.id),
                )),
              ],
            ),
          ),
          
          // Add indicator button
          IconButton(
            onPressed: onAddIndicator ?? () => _showAddIndicatorDialog(context, effectiveConfig),
            icon: Icon(
              Icons.add_chart,
              color: effectiveConfig.textColor.withValues(alpha: 0.7),
              size: 20,
            ),
            tooltip: 'Add Indicator',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showAddIndicatorDialog(BuildContext context, ChartConfig config) {
    showDialog(
      context: context,
      builder: (context) => _AddIndicatorDialog(
        controller: controller,
        config: config,
      ),
    );
  }
}

class _IndicatorChip extends StatelessWidget {
  final IndicatorModel indicator;
  final ChartConfig config;
  final VoidCallback onToggleVisibility;
  final VoidCallback onRemove;
  
  const _IndicatorChip({
    required this.indicator,
    required this.config,
    required this.onToggleVisibility,
    required this.onRemove,
  });
  
  @override
  Widget build(BuildContext context) {
    final opacity = indicator.isVisible ? 1.0 : 0.5;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: indicator.color.withValues(alpha: 0.15 * opacity),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: indicator.color.withValues(alpha: 0.5 * opacity),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Color indicator
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: indicator.color.withValues(alpha: opacity),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          
          // Indicator name
          Text(
            indicator.displayName,
            style: TextStyle(
              color: config.textColor.withValues(alpha: opacity),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          
          // Toggle visibility
          GestureDetector(
            onTap: onToggleVisibility,
            child: Icon(
              indicator.isVisible ? Icons.visibility : Icons.visibility_off,
              size: 14,
              color: config.textColor.withValues(alpha: 0.5 * opacity),
            ),
          ),
          const SizedBox(width: 2),
          
          // Remove
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 14,
              color: config.textColor.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddIndicatorDialog extends StatefulWidget {
  final TradingChartController controller;
  final ChartConfig config;
  
  const _AddIndicatorDialog({
    required this.controller,
    required this.config,
  });
  
  @override
  State<_AddIndicatorDialog> createState() => _AddIndicatorDialogState();
}

class _AddIndicatorDialogState extends State<_AddIndicatorDialog> {
  String _selectedType = 'ma';
  MovingAverageType _maType = MovingAverageType.sma;
  int _period = 20;
  double _bbDeviation = 2.0;
  Color _color = Colors.blue;
  
  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.cyan,
    Colors.amber,
    Colors.green,
  ];
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.config.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: widget.config.gridLineColor),
      ),
      title: Text(
        'Add Indicator',
        style: TextStyle(
          color: widget.config.textColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indicator type selection
            _buildLabel('Indicator Type'),
            const SizedBox(height: 8),
            _buildTypeSelector(),
            const SizedBox(height: 16),
            
            // Type-specific options
            if (_selectedType == 'ma') ...[
              _buildLabel('MA Type'),
              const SizedBox(height: 8),
              _buildMATypeSelector(),
              const SizedBox(height: 16),
            ],
            
            // Period
            _buildLabel('Period'),
            const SizedBox(height: 8),
            _buildPeriodSlider(),
            const SizedBox(height: 16),
            
            // Bollinger Bands deviation
            if (_selectedType == 'bb') ...[
              _buildLabel('Deviation'),
              const SizedBox(height: 8),
              _buildDeviationSlider(),
              const SizedBox(height: 16),
            ],
            
            // Color
            _buildLabel('Color'),
            const SizedBox(height: 8),
            _buildColorSelector(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: widget.config.textColor.withValues(alpha: 0.7),
            ),
          ),
        ),
        FilledButton(
          onPressed: _addIndicator,
          style: FilledButton.styleFrom(
            backgroundColor: widget.config.currentPriceLabelColor,
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }
  
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: widget.config.textColor.withValues(alpha: 0.7),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }
  
  Widget _buildTypeSelector() {
    return Row(
      children: [
        _TypeButton(
          label: 'Moving Average',
          isSelected: _selectedType == 'ma',
          config: widget.config,
          onTap: () => setState(() => _selectedType = 'ma'),
        ),
        const SizedBox(width: 8),
        _TypeButton(
          label: 'Bollinger Bands',
          isSelected: _selectedType == 'bb',
          config: widget.config,
          onTap: () => setState(() => _selectedType = 'bb'),
        ),
      ],
    );
  }
  
  Widget _buildMATypeSelector() {
    return Wrap(
      spacing: 8,
      children: MovingAverageType.values.map((type) {
        final isSelected = type == _maType;
        return GestureDetector(
          onTap: () => setState(() => _maType = type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? widget.config.currentPriceLabelColor.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isSelected
                    ? widget.config.currentPriceLabelColor
                    : widget.config.gridLineColor,
              ),
            ),
            child: Text(
              type.name.toUpperCase(),
              style: TextStyle(
                color: isSelected
                    ? widget.config.currentPriceLabelColor
                    : widget.config.textColor,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildPeriodSlider() {
    return Row(
      children: [
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: widget.config.currentPriceLabelColor,
              thumbColor: widget.config.currentPriceLabelColor,
              inactiveTrackColor: widget.config.gridLineColor,
            ),
            child: Slider(
              value: _period.toDouble(),
              min: 5,
              max: 200,
              divisions: 39,
              onChanged: (value) => setState(() => _period = value.toInt()),
            ),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            '$_period',
            style: TextStyle(
              color: widget.config.textColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
  
  Widget _buildDeviationSlider() {
    return Row(
      children: [
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: widget.config.currentPriceLabelColor,
              thumbColor: widget.config.currentPriceLabelColor,
              inactiveTrackColor: widget.config.gridLineColor,
            ),
            child: Slider(
              value: _bbDeviation,
              min: 1.0,
              max: 3.0,
              divisions: 20,
              onChanged: (value) => setState(() => _bbDeviation = value),
            ),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            _bbDeviation.toStringAsFixed(1),
            style: TextStyle(
              color: widget.config.textColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
  
  Widget _buildColorSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _colorOptions.map((color) {
        final isSelected = color == _color;
        return GestureDetector(
          onTap: () => setState(() => _color = color),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
  
  void _addIndicator() {
    if (_selectedType == 'ma') {
      widget.controller.addMovingAverage(
        type: _maType,
        period: _period,
        color: _color,
      );
    } else if (_selectedType == 'bb') {
      widget.controller.addBollingerBands(
        period: _period,
        deviation: _bbDeviation,
        middleColor: _color,
      );
    }
    
    Navigator.of(context).pop();
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ChartConfig config;
  final VoidCallback onTap;
  
  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.config,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? config.currentPriceLabelColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected
                ? config.currentPriceLabelColor
                : config.gridLineColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? config.currentPriceLabelColor
                : config.textColor,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
