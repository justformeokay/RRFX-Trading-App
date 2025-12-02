import 'package:flutter/material.dart';

class GradientCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final Color secondaryColor;

  const GradientCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.secondaryColor = const Color.fromRGBO(228, 183, 60, 1.0),
  });

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: [
        secondaryColor,
        secondaryColor.withOpacity(0.8),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: value ? null : Border.all(color: Colors.grey, width: 1.5),
        gradient: value ? gradient : null,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          unselectedWidgetColor: Colors.transparent,
        ),
        child: Checkbox(
          value: value,
          onChanged: onChanged,
          side: BorderSide.none, // supaya border luar diatur container
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          checkColor: Colors.white,
          fillColor: WidgetStateProperty.all(Colors.transparent),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}