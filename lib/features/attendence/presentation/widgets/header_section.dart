import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/constants.dart';
import '../../../authentication/domain/entities/employee.dart';

/// Displays a greeting with the user’s first name and the current date/time.
class HeaderSection extends StatelessWidget {
  final Employee employee;
  final String currentDate;

  const HeaderSection({Key? key, required this.employee, required this.currentDate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    final fullName =
    (lang == 'ar' && employee.employeeNameInAr.isNotEmpty)
        ? employee.employeeNameInAr
        : employee.employeeNameInEn;
    final firstName = fullName.split(' ').first;
    final greeting = 'helloName'.tr(namedArgs: {'name': firstName});
    return Row(
      children: [
        const SizedBox(width: 15),
        const CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage('assets/user_profile.jpg'),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: const TextStyle(
                color: primaryColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              currentDate,
              style: const TextStyle(color: lightGray, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(width: 25),
        Lottie.asset(
          'assets/lottie/sunny.json',
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        ),
      ],
    );
  }
}