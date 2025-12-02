import 'package:flutter/material.dart';
import 'package:rrfx/src/components/colors/default.dart';

class TimeframeSelector extends StatelessWidget {
  final String selected;
  final Function(String) onChanged;

  const TimeframeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tfs = ["M1", "M5", "M15", "M30", "H1", "H4", "D1"];
    return SizedBox(
      height: 45,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: tfs.map((tf) {
          final bool active = tf == selected;
          return GestureDetector(
            onTap: () => onChanged(tf),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: active ? CustomColor.secondaryColor : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(tf,
                  style: TextStyle(
                    color: active ? Colors.black : Colors.grey[300],
                    fontWeight: FontWeight.bold,
                    fontSize: 11.0
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
