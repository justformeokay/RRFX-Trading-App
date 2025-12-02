import 'package:flutter/material.dart';

Future<void> showClosePositionDialog({
  required BuildContext context,
  required String symbol,
  required dynamic lot,
  required dynamic price,
  required dynamic biaya,
  required dynamic biayaInap,
  required dynamic profit,
  required VoidCallback onConfirm,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Konfirmasi tutup posisi",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildRow("Simbol", symbol, valueColor: Theme.of(context).textTheme.bodyMedium?.color),
              _buildRow("Volume (lot)", lot.toStringAsFixed(2), valueColor: Theme.of(context).textTheme.bodyMedium?.color, trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text("BELI", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
              )),
              _buildRow("Harga", price.toStringAsFixed(4), valueColor: Theme.of(context).textTheme.bodyMedium?.color),
              _buildRow("Biaya", biaya.toStringAsFixed(2), valueColor: Theme.of(context).textTheme.bodyMedium?.color),
              _buildRow("Biaya Inap", biayaInap.toStringAsFixed(2), valueColor: Theme.of(context).textTheme.bodyMedium?.color),
              _buildRow(
                "Profit",
                profit.toStringAsFixed(2),
                valueColor: profit >= 0 ? Colors.green : Colors.red,
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("Batalkan", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onConfirm();
                      },
                      child: Text("Konfirmasi", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildRow(String label, String value,
    {Widget? trailing, Color? valueColor}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Row(
          children: [
            trailing ?? const SizedBox(),
            if (trailing != null) const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


Future<void> showCloseMarketDialog({
  required BuildContext context,
  required String marketName,
  required VoidCallback onConfirm,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔹 Title
              Text(
                "Tutup Posisi",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),

              // 🔹 Divider aesthetic
              Divider(thickness: 1, color: Colors.grey.shade300),
              const SizedBox(height: 12),

              // 🔹 Market Name display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart_rounded,
                        color: Colors.teal.shade600, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      marketName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        "Batalkan",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onConfirm();
                      },
                      child: const Text(
                        "Konfirmasi",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}



void showClosedOrderDialog(BuildContext context, Map<String, dynamic> orderData) {
  final String symbol = orderData["symbol"] ?? "";
  final double lot = (orderData["lot"] ?? 0).toDouble();
  final String orderType = orderData["orderType"] ?? "";
  final double profit = (orderData["profit"] ?? 0).toDouble();
  final double openPrice = (orderData["openPrice"] ?? 0).toDouble();
  final double closePrice = (orderData["closePrice"] ?? 0).toDouble();
  final int openTime = orderData["openTime"] ?? 0;
  final int closeTime = orderData["closeTime"] ?? 0;

  showDialog(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);

      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          "Detail Posisi Tertutup",
          style: theme.textTheme.titleMedium,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRowClosed("Simbol", symbol, theme),
            _buildRowClosed("Tipe", orderType.toUpperCase(), theme),
            _buildRowClosed("Volume (lot)", lot.toStringAsFixed(2), theme),
            _buildRowClosed("Open Price", openPrice.toStringAsFixed(orderData["digits"] ?? 2), theme),
            _buildRowClosed("Close Price", closePrice.toStringAsFixed(orderData["digits"] ?? 2), theme),
            _buildRowClosed("Open Time", DateTime.fromMillisecondsSinceEpoch(openTime * 1000).toString(), theme),
            _buildRowClosed("Close Time", DateTime.fromMillisecondsSinceEpoch(closeTime * 1000).toString(), theme),
            const SizedBox(height: 8),
            Divider(color: theme.dividerColor),
            _buildRowClosed(
              "Profit",
              profit.toStringAsFixed(2),
              theme,
              valueColor: profit >= 0 ? Colors.green : Colors.red,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Tutup", style: theme.textTheme.labelLarge),
          ),
        ],
      );
    },
  );
}

Widget _buildRowClosed(String label, String value, ThemeData theme, {Color? valueColor}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor ?? theme.textTheme.bodyMedium?.color,
          ),
        ),
      ],
    ),
  );
}
