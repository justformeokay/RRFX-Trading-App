// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:rrfx/src/views/trade/closed_position.dart';

// import 'open_position.dart';

// class TradingOrderHistory extends StatefulWidget {
//   const TradingOrderHistory({super.key, this.accountID});
//   final int? accountID;

//   @override
//   State<TradingOrderHistory> createState() => _TradingOrderHistoryState();
// }

// class _TradingOrderHistoryState extends State<TradingOrderHistory> {
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text("Transaksi ${widget.accountID}", style: GoogleFonts.aBeeZee()),
//           actions: [
//             IconButton(onPressed: () async {
//               SharedPreferences prefs = await SharedPreferences.getInstance();
//               prefs.getString('accessToken');
//             }, icon: Icon(CupertinoIcons.info))
//           ],
//           bottom: TabBar(
//             // dividerColor: CustomColor.defaultColor,
//             // automaticIndicatorColorAdjustment: true,
//             // dividerHeight: 1.0,
//             // indicatorSize: TabBarIndicatorSize.tab,
//             // unselectedLabelColor: Colors.black26,
//             // indicatorColor: CustomColor.defaultColor,
//             // labelStyle: GoogleFonts.inter(color: CustomColor.defaultColor),
//             // physics: BouncingScrollPhysics(),
//             tabs: <Widget>[
//               Tab(icon: Text("OPEN")),
//               Tab(icon: Text("CLOSED")),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             OpenPosition(loginID: widget.accountID.toString()),
//             ClosedPosition(loginID: widget.accountID)
//           ]
//         ),
//       )
//     );
//   }
// }
