import 'package:flutter/material.dart';

class LeaveRequestButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        // Navigate to leave request form
      },
      icon: Icon(Icons.request_page),
      label: Text('Request Leave'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
