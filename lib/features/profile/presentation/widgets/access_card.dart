
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/constants/constants.dart';
import '../../../authentication/domain/entities/employee.dart';

class AccessCard extends StatefulWidget {
  final Employee employee;
  final bool isArabic;
  const AccessCard({super.key, required this.employee, required this.isArabic});

  @override
  State<AccessCard> createState() => _AccessCardState();
}

class _AccessCardState extends State<AccessCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFrontVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _toggleCard() {
    if (_isFrontVisible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _isFrontVisible = !_isFrontVisible);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final rotation = _animation.value * pi;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(rotation);

          return Stack(
            children: [
              Transform(
                transform: transform,
                alignment: Alignment.center,
                child: rotation > pi / 2
                    ? Transform(
                  transform: Matrix4.identity()..rotateY(pi),
                  alignment: Alignment.center,
                  child: _buildBack(),
                )
                    : _buildFront(),
              ),
              // Flip Button at the Top Right Corner
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  onPressed: _toggleCard,
                  icon: const Icon(Icons.flip),
                  color: Colors.white,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.6),
                  ),
                ),
              ),
              // Wallet Button at the Bottom Left Corner
              Positioned(
                bottom: 8,
                left: 8,
                child: ElevatedButton.icon(
                  onPressed: () => _addToWallet(context),
                  icon: const Icon(Icons.credit_card),
                  label: const Text("Wallet"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    final name = widget.isArabic
        ? widget.employee.employeeNameInAr
        : widget.employee.employeeNameInEn;
    final role = widget.isArabic
        ? widget.employee.employeeTitleInAr
        : widget.employee.employeeTitleInEn;
    return _buildCard(
      child: Column(
        children: [
          Image.asset(
            "assets/ministry_logo.png",
            height: 50,
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
               Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.employee.employeeNameInAr,
                      style: TextStyle(color: primaryColor, fontSize: 10),
                    ),
                    Text(
                      role,
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                    SizedBox(height: 15),
                    Text(
                      widget.employee.employeeNameInEn,
                      style: TextStyle(color: primaryColor, fontSize: 10),
                    ),
                    Text(
                      widget.employee.employeeTitleInEn,
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                    SizedBox(height: 15),
                    Text(
                      widget.employee.id,
                      style: TextStyle(color: Colors.black, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 25),
              Image.asset(
                "assets/user_profile.jpg",
                height: 100,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return _buildCard(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            QrImageView(
              data: 'This is a simple QR code',
              version: QrVersions.auto,
              size: 50,
              gapless: false,
            ),
            const SizedBox(height: 10),
            const Text(
              "هذه البطاقة التعريفية ملك وزارة الاقتصاد.\n في حال العثور على هذه البطاقة، يرجى ارسالها الى ص.ب 3625\n دبي الامارات العربية المتحدة او الاتصال على الرقم 800-1222",
              style: TextStyle(
                color: Colors.black,
                fontSize: 10,
              ),
              textAlign: TextAlign.end,
            ),

            const Text(
              "Valid until\n2025",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),

            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.nfc, color: lightGray),
                  SizedBox(width: 8),
                  Text(
                    "Tap to use",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return SizedBox(
      width: 400,
      height: 230,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 12, spreadRadius: 2),
          ],
          border: Border.all(color: primaryColor, width: 2),
        ),
        child: child,
      ),
    );
  }

  void _addToWallet(BuildContext context) {
    // Wallet integration implementation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}