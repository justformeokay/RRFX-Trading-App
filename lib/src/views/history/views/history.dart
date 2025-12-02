import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Bootstrap.clock_history, size: 50),
            const SizedBox(height: 10.0),
            Text("Riwayat", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800)),
            Text("Tab Riwayat masih dalam pengembangan", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}