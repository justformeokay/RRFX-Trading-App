import 'package:flutter/material.dart';

class ChartAdvance extends StatefulWidget {
  const ChartAdvance({super.key});

  @override
  State<ChartAdvance> createState() => _ChartAdvanceState();
}

class _ChartAdvanceState extends State<ChartAdvance> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Advance Charts"),
      ),
      body: const Center(
        child: Text("Advance Charts Content Here"),
      ),
    );
  }
}