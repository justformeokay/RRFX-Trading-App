import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';

class CustomSlideAbleListTile {
  static Slidable openListTile(BuildContext context, {Function(BuildContext)? onPressedEdit, Function(BuildContext)? onPressedClose, int? index, String? market, String? orderType, dynamic lot, String? dateTime, dynamic profitLoss, dynamic openPrice, dynamic currentPrice, dynamic commission, dynamic swap, dynamic id, dynamic sl, dynamic tp}){
    return Slidable(
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(onDismissed: () {}),
        children: [
          SlidableAction(
            onPressed: onPressedEdit,
            backgroundColor: Color(0xFF1852E8),
            foregroundColor: Colors.white,
            icon: LineAwesome.edit,
            label: 'Edit Position',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: onPressedClose,
            backgroundColor: Color(0xFF7BC043),
            foregroundColor: Colors.white,
            icon: Icons.done_all_rounded,
            label: 'Close Position',
          ),
        ],
      ),
      child: ExpansionTile(
        dense: true,
        showTrailingIcon: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$market,',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      ' $orderType $lot',
                      style: GoogleFonts.inter(color: orderType != null ? orderType == "Sell" ? Colors.redAccent : Colors.blue : Colors.black38, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '$openPrice ',
                      style: TextStyle(),
                    ),
                    Icon(Icons.arrow_right_alt),
                    Text(
                      ' $currentPrice',
                      style: TextStyle(),
                    ),
                  ],
                ),
              ],
            ),
            Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$dateTime',
                  style: GoogleFonts.inter(fontSize: 12),
                ),
                Text(
                  '$profitLoss',
                  style: GoogleFonts.inter(color: profitLoss != null ? profitLoss >= 0 ? Colors.blueAccent : Colors.red : Colors.black26, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        collapsedBackgroundColor: Colors.white60,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                _buildRow('S / L:', '${sl ?? 0}', 'T / P:', '${tp ?? 0}'),
                SizedBox(height: 8),
                _buildRow('ID:', '#${id ?? 0}'),
                SizedBox(height: 8),
                _buildRow('Swap:', '${swap ?? 0.00}', 'Commission:', '${commission ?? 0.00}'),
              ],
            ),
          ),
        ],
      ),
    );
  }


  static ExpansionTile closedListTile(
    BuildContext context, {
      int? index,
      String? marketName,
      String? executionName,
      String? dateTime,
      String? lot,
      String? stopLoss,
      String? takeProfit,
      String? openPrice,
      String? closedPrice,
      String? orderID,
      String? commission,
      String? profit
    }){
    return ExpansionTile(
      dense: true,
      showTrailingIcon: false,
      subtitle: Text(dateTime ?? ""),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            marketName != null ? "$marketName, " : '-,',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          Text(
            '${executionName ?? "-"} ${lot ?? 1.00}',
            style: TextStyle(color: Colors.redAccent),
          ),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                dateTime ?? '-',
                style: GoogleFonts.inter(fontSize: 12),
              ),
              Text(
                profit ?? '0',
                style: GoogleFonts.inter(color: Colors.blueAccent, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide.none
      ),
      backgroundColor: Theme.of(context).sliderTheme.thumbColor,
      collapsedBackgroundColor: Theme.of(context).sliderTheme.activeTickMarkColor,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              _buildRow('$openPrice → $closedPrice', '-'),
              SizedBox(height: 8),
              _buildRow('S / L:', '$stopLoss', 'T / P:', '$takeProfit'),
              SizedBox(height: 8),
              _buildRow('Open:', "$dateTime"),
              _buildRow('Id:', '#$orderID'),
              SizedBox(height: 8),
              _buildRow('Swap:', '0.00', 'Commission:', '0.00'),
            ],
          ),
        ),
      ],
    );
  }

  /// Helper for 2 or 4-column style rows
  static Widget _buildRow(String label1, String value1, [String? label2, String? value2]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label1, style: TextStyle()),
              SizedBox(width: 6),
              Text(value1, style: TextStyle()),
          ]),
        ),
        const SizedBox(width: 5),
        if (label2 != null && value2 != null)
          Expanded(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label2, style: TextStyle()),
                SizedBox(width: 6),
                Text(value2, style: TextStyle()),
            ]),
          )
      ],
    );
  }
}

