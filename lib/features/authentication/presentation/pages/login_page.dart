import 'package:attendence_system/features/services/presentation/pages/base_screen.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/constants.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/qr_code_scanner.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.maybeWhen(
          success: (_) => Navigator.pushReplacementNamed(context, '/main'),
          error: (message) {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.rightSlide,
                title: 'Oops'.tr(),
              desc: message,
              btnOkOnPress: () {},
              btnOkColor: primaryColor
            ).show();
          },
          orElse: () {},
        );
     },
        child:  BaseScreen(
          titleKey: "",
          child: _buildLoginForm(),
        )
    );
  }





  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          SizedBox(height: 40,),
          Image.asset("assets/ministry_logo.png"),
          Text(
            "wlcmBck".tr(),
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "lgnAcc".tr(),
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 30),
          _buildTextField(_emailController, "email".tr(), Icons.email, false),
          const SizedBox(height: 15),
          _buildTextField(_passwordController, "password".tr(), Icons.lock, true),
          const SizedBox(height: 20),
          _buildLoginButton(),
          const SizedBox(height: 10),
      //  _buildQRLoginButton(),
      //    const SizedBox(height: 10),
          // TextButton(
          //   onPressed: () {},
          //   child: const Text("Forgot Password?", style: TextStyle(color: primaryColor)),
          // ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _isObscured : false,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: primaryColor.withOpacity(0.8)),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            _isObscured ? Icons.visibility_off : Icons.visibility,
            color: primaryColor.withOpacity(0.8),
          ),
          onPressed: () {
            setState(() {
              _isObscured = !_isObscured;
            });
          },
        )
            : null,
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[200]?.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.5)), // Reduced opacity border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.5)), // Reduced opacity border when enabled
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.8), width: 2), // Slightly more opaque when focused
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: () {
        final email = _emailController.text;
        final password = _passwordController.text;
        context.read<AuthBloc>().add(
          AuthEvent.loginSubmitted(email: email, password: password),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor.withOpacity(0.8), // Reduced opacity button background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: primaryColor.withOpacity(0.8)), // Reduced opacity border
        ),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 100),
      ),
      child:  Text("login".tr(), style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }

  Widget _buildQRLoginButton() {
    return ElevatedButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Scan Your Access Card",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                   QRCodeScanner(),
                ],
              ),
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shadowColor: Colors.grey.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.qr_code_scanner, color: primaryColor, size: 24),
          SizedBox(width: 10),
          Text(
            "Sign in with QR Code",
            style: TextStyle(color: primaryColor, fontSize: 16),
          ),
        ],
      ),
    );
  }

}
