import 'package:flutter/material.dart';

Future<void> showClosePositionDialog({
  required BuildContext context,
  required String symbol,
  required double lot,
  required double price,
  required double profit,
  required double biaya,
  required double biayaInap,
  required VoidCallback onConfirm,
}) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text("Close Position ($symbol)?"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Lot: $lot"),
          Text("Price: $price"),
          Text("Profit: ${profit.toStringAsFixed(2)}"),
          Text("Biaya: $biaya"),
          Text("Biaya Inap: $biayaInap"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text("Close Now"),
        ),
      ],
    ),
  );
}
