import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  final int pendingItems;

  const OfflineBanner({super.key, this.pendingItems = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      color: Colors.orange.shade100,
      child: Row(
        children: [
          Icon(Icons.cloud_off, color: Colors.orange.shade900),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              pendingItems > 0
                  ? 'Offline mode • $pendingItems item(s) waiting to sync'
                  : 'Offline mode • Your data is saved locally',
              style: TextStyle(
                color: Colors.orange.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
