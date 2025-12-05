// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class TestView extends StatefulWidget {
//   const TestView({super.key});

//   @override
//   State<TestView> createState() => _TestViewState();
// }

// class _TestViewState extends State<TestView> {
//   final supabase = Supabase.instance.client;
//   RxList<Map<String, dynamic>> marketSymbol = <Map<String, dynamic>>[].obs;

//   Future<void> getMarketSupabase() async {
//     supabase.from('market_prices')
//       .stream(primaryKey: ['id'])
//       .listen((List<Map<String, dynamic>> data) {
//         marketSymbol.value = data;
//     });
//   }

//   Future<void> fetchMarketData() async {
//     final response = await supabase.from('market_prices').select();
//     print(response);
//   }

//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(Duration.zero, (){
//       getMarketSupabase();
//       // fetchMarketData();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Test API"),
//       ),
//       body: SingleChildScrollView(
//         child: Obx(
//           () => Column(
//             children: List.generate(marketSymbol.length, (i){
//               return ListTile(
//                 title: Text(marketSymbol[i]['symbol']),
//                 subtitle: Row(
//                   children: [
//                     Text("Open: ${marketSymbol[i]['open']}"),
//                     Text("Close: ${marketSymbol[i]['close']}"),
//                     Text("High: ${marketSymbol[i]['high']}"),
//                     Text("Low: ${marketSymbol[i]['low']}"),
//                   ],
//                 ),
//               );
//             }),
//           ),
//         ),
//       ),
//     );
//   }
// }