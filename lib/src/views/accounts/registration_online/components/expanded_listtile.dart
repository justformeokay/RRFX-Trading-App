import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/components/colors/default.dart';

class SmoothExpansionTile extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;

  const SmoothExpansionTile({
    super.key,
    required this.title,
    required this.children,
    this.initiallyExpanded = false,
  });

  @override
  State<SmoothExpansionTile> createState() => _SmoothExpansionTileState();
}

class _SmoothExpansionTileState extends State<SmoothExpansionTile>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final expandedColor = CustomColor.secondaryColor.withOpacity(0.15);
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDarkMode ? CustomColor.textThemeDarkSoftColor.withOpacity(0.6) : Get.theme.dividerColor.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _expanded ? expandedColor : Colors.transparent,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(8.0), topRight: Radius.circular(8.0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: _expanded
                            ? CustomColor.secondaryColor
                            : isDarkMode
                                ? CustomColor.textThemeDarkSoftColor
                                : CustomColor.textThemeLightSoftColor,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 250),
                    turns: _expanded ? 0.5 : 0,
                    child: Icon(
                      Icons.expand_more,
                      color: _expanded
                          ? CustomColor.secondaryColor
                          : CustomColor.textThemeDarkSoftColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body (AnimatedSize membuatnya smooth)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _expanded
                ? Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...widget.children,
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            onPressed: _toggleExpanded,
                            icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 18),
                            label: const Text("Tutup"),
                            style: FilledButton.styleFrom(
                              backgroundColor: CustomColor.secondaryColor,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
