import 'package:flutter/material.dart';
import '../../data/models/chart_config.dart';

/// Overlay widget shown when chart is loading
class LoadingOverlay extends StatelessWidget {
  final ChartConfig config;
  final String? message;
  
  const LoadingOverlay({
    super.key,
    required this.config,
    this.message,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: config.backgroundColor.withValues(alpha: 0.8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  config.textColor.withValues(alpha: 0.8),
                ),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message!,
                style: TextStyle(
                  color: config.textColor.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
