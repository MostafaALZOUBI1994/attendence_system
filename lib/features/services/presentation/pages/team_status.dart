import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/injection.dart'; // ⬅️ getIt lives here
import '../../domain/entities/employee_details_entity.dart';
import '../../domain/usecases/get_employee_details.dart';
import '../employees/cubit/employees_cubit.dart';
import 'base_screen.dart';

class TeamContactScreen extends StatelessWidget {
  const TeamContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      titleKey: 'tm'.tr(),
      child: BlocProvider(

        create: (_) => EmployeesCubit(
          getIt<GetEmployeeDetailsUseCase>(),
        )..loadForMyDepartment(),
        child: BlocBuilder<EmployeesCubit, EmployeesState>(
          builder: (context, state) => state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (m) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(m, textAlign: TextAlign.center),
              ),
            ),
            loaded: (employees) => _EmployeesGrid(employees: employees),
          ),
        ),
      ),
    );
  }
}

class _EmployeesGrid extends StatelessWidget {
  final List<EmployeeDetailsEntity> employees;
  const _EmployeesGrid({required this.employees});

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
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: employees.length,
        itemBuilder: (_, i) => _TeamMemberCard(member: employees[i]),
      ),
    );
  }
}

class _TeamMemberCard extends StatelessWidget {
  final EmployeeDetailsEntity member;
  const _TeamMemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    final displayName =
    member.displayNameEn.isNotEmpty ? member.displayNameEn : member.displayNameAr;
    final title =
    member.titleEn.isNotEmpty ? member.titleEn : member.titleAr;
    final ext = member.phoneNumber;
    final avatar = _decodeBase64(member.photoBase64);
    final mail = member.email;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: lightGray.withOpacity(0.3), width: 2),
      ),
      color: Colors.white.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: avatar,
              backgroundColor: lightGray,
              child: avatar == null ? _Initials(displayName) : null,
            ),
            const SizedBox(height: 8),
            Text(
              displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, color: secondaryColor),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: secondaryColor),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.phone, color: primaryColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  ext.isNotEmpty ? 'Ext: $ext' : '—',
                  style: const TextStyle(fontSize: 12, color: secondaryColor),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.email, color: primaryColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  mail.isNotEmpty ? 'Email: $mail' : '—',
                  style: const TextStyle(fontSize: 12, color: secondaryColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider? _decodeBase64(String? b64) {
    if (b64 == null || b64.isEmpty) return null;
    try {
      final cleaned = b64.contains(',') ? b64.substring(b64.indexOf(',') + 1) : b64;
      return MemoryImage(base64Decode(cleaned));
    } catch (_) {
      return null;
    }
  }
}

class _Initials extends StatelessWidget {
  final String name;
  const _Initials(this.name);

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials =
    parts.take(2).map((p) => p.isNotEmpty ? p[0] : '').join().toUpperCase();
    return Text(
      initials.isEmpty ? '👤' : initials,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: secondaryColor),
    );
  }
}
