import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class CustomDatePicker {

  static String formatTanggalIndonesia(DateTime dateTime) {
    final DateFormat formatter = DateFormat("EEEE, dd MMMM yyyy HH:mm:ss", "id_ID");
    return formatter.format(dateTime);
  }

  static String formatIndonesiaDate(DateTime dateTime) {
    final DateFormat formatter = DateFormat("EEEE, dd MMMM yyyy", "id_ID");
    return formatter.format(dateTime);
  }

  static String normalFormat(DateTime dateTime) {
    final DateFormat formatter = DateFormat("yyyy-MM-dd");
    return formatter.format(dateTime);
  }

  static Future<DateTime?> material(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime lastAllowed = DateTime(now.year - 17, now.month, now.day); // minimal 17 tahun
    final DateTime firstAllowed = DateTime(now.year - 65, now.month, now.day); // maksimal 65 tahun

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: lastAllowed, // default pilih usia minimal
      firstDate: firstAllowed,
      lastDate: lastAllowed,
    );

    return pickedDate;
  }
}