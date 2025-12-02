import 'package:flutter/material.dart';

class TableCompanyProfile extends StatelessWidget {
  final Map<String, String> data; // Key-value map for dynamic rows

  const TableCompanyProfile({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2, // Adjust flex to control width ratio
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14.0,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0), // Spacer between key and value
                Expanded(
                  flex: 5, // Adjust flex to control width ratio
                  child: Text(': ${entry.value}', // Prepend colon and space
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}