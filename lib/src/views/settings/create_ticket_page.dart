import 'package:flutter/material.dart';
import 'package:rrfx/src/components/appbars/default.dart';

class CreateTicketPage extends StatefulWidget {
  const CreateTicketPage({super.key});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.defaultAppBar(
        title: "Create Ticket",
        autoImplyLeading: true
      ),
    );
  }
}
