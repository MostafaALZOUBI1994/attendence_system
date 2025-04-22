import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';


class QRCodeScanner extends StatefulWidget {
  const QRCodeScanner({super.key});

  @override
  _QRCodeScannerState createState() => _QRCodeScannerState();
}

class _QRCodeScannerState extends State<QRCodeScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: QRView(
        key: qrKey,
        onQRViewCreated: (QRViewController controller) {
          this.controller = controller;
          controller.scannedDataStream.listen((scanData) {
            final qrLines = scanData.code?.split('\n');
            String? email;
            qrLines?.forEach((line) {
              if (line.startsWith('EMAIL')) {
                email = line.split(':').last.trim().split('@').first;
              }
            });
            if (email != null) {
              context.read<AuthBloc>()
                ..add(AuthEvent.qrScanned(email!))
                ..add(
                    AuthEvent.loginSubmitted(email: email!, password: "123"));
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              controller.pauseCamera();
            }
          });
        },
      ),
    );
  }
}
