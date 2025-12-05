import 'package:flutter/material.dart';

class ViewsMarket extends StatefulWidget {
  const ViewsMarket({super.key});

  @override
  State<ViewsMarket> createState() => _ViewsMarketState();
}

class _ViewsMarketState extends State<ViewsMarket> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Views Market'),
      ),
    );
  }
}