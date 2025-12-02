import 'package:flutter/material.dart';

class CustomNotificationCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String time;

  const CustomNotificationCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.time,
  });

  // Factory methods untuk berbagai jenis notifikasi
  factory CustomNotificationCard.promo({
    required String title,
    required String message,
    required String time,
  }) {
    return CustomNotificationCard(
      icon: Icons.campaign_rounded,
      iconColor: Colors.orange,
      title: title,
      message: message,
      time: time,
    );
  }

  factory CustomNotificationCard.success({
    required String title,
    required String message,
    required String time,
  }) {
    return CustomNotificationCard(
      icon: Icons.check_circle_rounded,
      iconColor: Colors.green,
      title: title,
      message: message,
      time: time,
    );
  }

  factory CustomNotificationCard.error({
    required String title,
    required String message,
    required String time,
  }) {
    return CustomNotificationCard(
      icon: Icons.error_rounded,
      iconColor: Colors.red,
      title: title,
      message: message,
      time: time,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
