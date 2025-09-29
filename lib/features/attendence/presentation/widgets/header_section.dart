import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:moet_hub/core/utils/base64_utils.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/Initials.dart';
import '../../../../core/widgets/avatar_widgets.dart';
import '../../../authentication/domain/entities/employee.dart';
import '../../../services/presentation/employees/view/team_contacts_screen.dart';

class HeaderSection extends StatefulWidget {
  final Employee employee;
  const HeaderSection({Key? key, required this.employee}) : super(key: key);
  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  late Timer _timer;
  String _currentDate = '';


  @override
  void initState() {
    super.initState();
    _updateDate();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _updateDate());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateDate() {
    final now = DateTime.now();
    final formatter = DateFormat('MMMM d, yyyy   hh:mm a', 'en');
    setState(() {
      _currentDate = formatter.format(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    final fullName = (lang == 'ar' && widget.employee.employeeNameInAr.isNotEmpty)
        ? widget.employee.employeeNameInAr
        : widget.employee.employeeNameInEn;
    final firstName = fullName.split(' ').first;
    final greeting = 'helloName'.tr(namedArgs: {'name': firstName});
    return Row(
      children: [
        const SizedBox(width: 15),
        CircleAvatarOrInitials(
          base64: widget.employee.empImageUrl,
          fullName: widget.employee.employeeNameInEn,
          radius: 26,
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
              _currentDate,
              style: const TextStyle(color: lightGray, fontSize: 14),
            ),
          ],
        ),
        // const SizedBox(width: 25),
        // Lottie.asset(
        //   'assets/lottie/sunny.json',
        //   width: 48,
        //   height: 48,
        //   fit: BoxFit.cover,
        // ),
      ],
    );
  }
}
