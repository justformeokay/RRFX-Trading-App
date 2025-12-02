import 'package:flutter/material.dart';
import 'package:rrfx/src/views/beranda/components/notification_tile.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView(
        children: [
          CustomNotificationCard.promo(
            title: "Special Promotion",
            message: "Get 50% bonus on your first deposit!",
            time: "2:14 PM",
          ),
          CustomNotificationCard.success(
            title: "Account Created",
            message: "Your trading account has been created successfully.",
            time: "3:05 PM",
          ),
          CustomNotificationCard.error(
            title: "Account Creation Failed",
            message: "We couldn't create your trading account. Please try again.",
            time: "3:10 PM",
          ),
        ],
      ),
      // body: SizedBox(
      //   width: size.width,
      //   height: size.height / 1.2,
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Icon(Clarity.notification_line, size: 60),
      //       const SizedBox(height: 10.0),
      //       Text("Tidak ada notifikasi")
      //     ],
      //   ),
      // ),
    );
  }
}