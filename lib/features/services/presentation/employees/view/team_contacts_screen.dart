import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Clipboard
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/constants.dart';
import '../../../../../core/injection.dart';
import '../../../../../core/local_services/local_services.dart';
import '../../../../../core/utils/Initials.dart';
import '../../../../../core/utils/base64_utils.dart';
import '../../../domain/entities/employee_details_entity.dart';
import '../../../domain/usecases/get_employee_details.dart';
import '../../pages/base_screen.dart';
import '../cubit/employees_cubit.dart';


class TeamContactScreen extends StatelessWidget {
  const TeamContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      // Make sure you have "teamContacts" in your localization JSON
      titleKey: 'tm'.tr(),
      child: BlocProvider(
        // No ctx.read(); pull the use case from getIt to avoid ProviderNotFound
        create: (_) => EmployeesCubit(getIt<GetEmployeeDetailsUseCase>())
          ..loadForMyDepartment(),
        child: const _ContactsBody(),
      ),
    );
  }
}

class _ContactsBody extends StatelessWidget {
  const _ContactsBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeesCubit, EmployeesState>(
      builder: (context, state) => state.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (m) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(m, textAlign: TextAlign.center),
          ),
        ),
        loaded: (employees) => _EmployeesList(employees: employees),
      ),
    );
  }
}

class _EmployeesList extends StatelessWidget {
  const _EmployeesList({required this.employees});
  final List<EmployeeDetailsEntity> employees;

  @override
  Widget build(BuildContext context) {
    if (employees.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No team members found.'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<EmployeesCubit>().loadForMyDepartment(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        itemCount: employees.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _EmployeeTile(member: employees[i]),
      ),
    );
  }
}

class _EmployeeTile extends StatelessWidget {
  const _EmployeeTile({required this.member});
  final EmployeeDetailsEntity member;

  @override
  Widget build(BuildContext context) {
    final locale = getIt<LocalService>().getSavedLocale().languageCode;

    // Correct language
    final displayName = (locale == 'ar' ? member.displayNameAr : member.displayNameEn) ?? '';
    final title       = (locale == 'ar' ? member.titleAr       : member.titleEn)       ?? '';

    final phone = (member.phoneNumber ?? '').trim();
    final email = (member.email ?? '').trim();
    final avatar = decodeBase64(member.photoBase64);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        border: Border.all(color: lightGray.withOpacity(0.28)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],

      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: lightGray,
          backgroundImage: avatar,
          child: avatar == null ? Initials(displayName) : null,
        ),
        title: Text(
          displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: secondaryColor,
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 0.2,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12.5, color: secondaryColor),
              ),
            ],
            if (phone.isNotEmpty) ...[
              const SizedBox(height: 8),
              _InfoPill(
                icon: Icons.phone_rounded,
                text: _formatPhoneLabel(phone),
                onTap: () => _onCall(context, phone),
                onLongPress: () => _copy(context, phone, label: 'Phone'),
              ),
            ],
            if (email.isNotEmpty) ...[
              const SizedBox(height: 6),
              _InfoPill(
                icon: Icons.email_rounded,
                text: email,
                onTap: () => _onEmail(context, email),
                onLongPress: () => _copy(context, email, label: 'Email'),
              ),
            ],
          ],
        ),
        // Small action row on the right
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (phone.isNotEmpty)
              _RoundIconButton(
                icon: Icons.call,
                onTap: () => _onCall(context, phone),
                tooltip: 'Call',
              ),
            if (email.isNotEmpty) ...[
              const SizedBox(width: 8),
              _RoundIconButton(
                icon: Icons.alternate_email_rounded,
                onTap: () => _onEmail(context, email),
                tooltip: 'Email',
              ),
            ],
          ],
        ),
      ),
    );
  }



  String _formatPhoneLabel(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    final isExt = !raw.startsWith('+') && !raw.startsWith('0') && digits.length <= 5;
    return isExt ? 'Ext: $raw' : raw;
  }

  Future<void> _onCall(BuildContext context, String raw) async {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    final isExt = !raw.startsWith('+') && !raw.startsWith('0') && digits.length <= 5;

    if (isExt) {
      await _copy(context, raw, label: 'Extension');
      _snack(context, 'Extension copied to clipboard');
      return;
    }
    // final uri = Uri(scheme: 'tel', path: raw);
    // if (await canLaunchUrl(uri)) {
    //   await launchUrl(uri, mode: LaunchMode.externalApplication);
    // } else {
    //   _snack(context, 'Can’t open dialer');
    // }
  }

  Future<void> _onEmail(BuildContext context, String email) async {
    // final uri = Uri(scheme: 'mailto', path: email);
    // if (await canLaunchUrl(uri)) {
    //   await launchUrl(uri, mode: LaunchMode.externalApplication);
    // } else {
    //   await _copy(context, email, label: 'Email');
    //   _snack(context, 'Email copied to clipboard');
    // }
  }

  Future<void> _copy(BuildContext context, String text, {required String label}) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.text,
    this.onTap,
    this.onLongPress,
  });

  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primaryColor.withOpacity(0.06),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: primaryColor, size: 16),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: secondaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap, this.tooltip});
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final btn = InkResponse(
      onTap: onTap,
      radius: 22,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: primaryColor, size: 18),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}

