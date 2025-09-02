import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moet_hub/features/attendence/presentation/widgets/card_container.dart';

import '../../../../core/constants/constants.dart';

/// Displays a grid of off-site check-in cards showing the time of each check-in.
class OffSiteCheckInsGrid extends StatelessWidget {
  final List<int> offSiteCheckIns;

  const OffSiteCheckInsGrid({Key? key, required this.offSiteCheckIns}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dates = offSiteCheckIns
        .map((ts) => DateTime.fromMillisecondsSinceEpoch(ts))
        .toList()
      ..sort((a, b) => b.compareTo(a));
    final formatter = DateFormat('hh:mm');

    return Container(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4
        
        ),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final timeString = formatter.format(date);
          return CardContainer(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fingerprint, color: primaryColor),
              const SizedBox(height: 8),
              Text(
                timeString,
                style: const TextStyle(
                  color: Colors.black45,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),);
        },
      ),
    );
  }
}
