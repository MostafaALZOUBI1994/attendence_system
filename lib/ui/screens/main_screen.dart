import 'dart:io' show Platform;
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/constants.dart';
import '../../core/injection.dart';
import '../../features/attendence/presentation/bloc/attendence_bloc.dart';
import '../../features/attendence/presentation/pages/attendence_page.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/reports/presentation/bloc/report_bloc.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/services/presentation/bloc/services_bloc.dart';
import '../../features/services/presentation/pages/services.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _notchController = NotchBottomBarController(index: 0);
  final _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;

  final List<Widget> _pages = [
    TimeScreen(),
    const ServicesScreen(),
    const ReportsScreen(),
    const ProfilePage(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    // Android must be flush; iOS needs the home-indicator inset.
    final insetForBar = Platform.isIOS ? bottomInset : 0.0;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ProfileBloc>()),
        BlocProvider(create: (_) => getIt<AuthBloc>()),
        BlocProvider(create: (_) => getIt<AttendenceBloc>()..add(const AttendenceEvent.loadData())),
        BlocProvider(
          create: (_) => getIt<ReportBloc>()
            ..add(
              ReportEvent.fetchReport(
                fromDate: DateFormat('dd/MM/yyyy', 'en').format(DateTime.now().subtract(const Duration(days: 120))),
                toDate: DateFormat('dd/MM/yyyy', 'en').format(DateTime.now()),
              ),
            ),
        ),
        BlocProvider(create: (_) => getIt<ServicesBloc>()..add(const ServicesEvent.loadData())),
      ],
      child: Scaffold(
        // Body sits above the bar; no bottom SafeArea (we handle it inside the bar)
        body: SafeArea(
          top: true,
          bottom: false,
          child: PageView(
            controller: _pageController,
            physics: const ClampingScrollPhysics(),
            onPageChanged: (i) {
              setState(() => _currentIndex = i);
              _notchController.jumpTo(i); // keep the bar in sync
            },
            children: _pages,
          ),
        ),

        // Bottom bar: flush on Android, inset only on iOS (painted to look seamless)
        bottomNavigationBar: Container(
          color: veryLightGray.withOpacity(1.0), // paint under-bar area
          padding: EdgeInsets.only(bottom: insetForBar),
          child: AnimatedNotchBottomBar(
            notchBottomBarController: _notchController,
            onTap: (i) {
              if (_currentIndex == i) return;
              setState(() => _currentIndex = i);
              _pageController.animateToPage(
                i,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic, // smooth transition
              );
            },
            removeMargins: true,
            bottomBarHeight: kBottomNavigationBarHeight, // 56dp content height
            kIconSize: 20,
            showLabel: true,
            itemLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            color: veryLightGray.withOpacity(1.0),
            notchColor: primaryColor.withOpacity(0.7),
            kBottomRadius: 32.0,
            elevation: 0,
            shadowElevation: 0,
            showShadow: false,
            bottomBarItems: [
              _item(Icons.home, "home".tr()),
              _item(Icons.build, "services".tr()),
              _item(Icons.list_alt, "reports".tr()),
              _item(Icons.person, "profile".tr()),
            ],
          ),
        ),
      ),
    );
  }

  BottomBarItem _item(IconData icon, String label) {
    return BottomBarItem(
      inActiveItem: Icon(icon, color: Colors.grey),
      activeItem: Icon(icon, color: Colors.white),
      itemLabel: label,
    );
  }
}