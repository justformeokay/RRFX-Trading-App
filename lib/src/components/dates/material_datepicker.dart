import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomMaterialDatePicker {
  static Future<String?> selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      return DateFormat("dd MMMM yyyy").format(pickedDate);
    }

    return null;
  }
}