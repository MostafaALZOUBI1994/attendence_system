import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moet_hub/core/constants/constants.dart';

import '../bloc/services_bloc.dart';

class BaseScreen extends StatelessWidget {
  final String titleKey;
  final Widget child;

  const BaseScreen({
    Key? key,
    required this.titleKey,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Stack(
          fit: StackFit.expand,
          children: [
            // Image.asset(
            //   'assets/c1.png',
            //   fit: BoxFit.cover,
            // ),
            // Container(color: Colors.black.withOpacity(0.7)),
             Container(color: Colors.white.withOpacity(0.90),),
            Scaffold(
              extendBody: true,
              extendBodyBehindAppBar: true,
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Text(titleKey.tr(), style: const TextStyle(color: primaryColor)),
                backgroundColor: Colors.transparent,
                iconTheme: const IconThemeData(color: primaryColor),
              ),
              body: SafeArea(
                top: true,
                bottom: false,
                child: child,
              ),
            ),
          ],
        ),
        // loading overlay
        BlocSelector<ServicesBloc, ServicesState, bool>(
          selector: (state) => state.maybeWhen(loading: () => true, orElse: () => false),
          builder: (context, isLoading) {
            if (!isLoading) return const SizedBox.shrink();
            return Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ],
    );
  }
}