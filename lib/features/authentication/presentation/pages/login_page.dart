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
      if (state is AuthSuccess) {
        Navigator.pushReplacementNamed(context, '/main');
      }
     },
        child:  Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              _buildBackground(),
              _buildLoginForm(),
            ],
          ),
        )
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          left: -50,
          child: _buildDecorativeCircle(250, primaryColor.withOpacity(0.2)),
        ),
        Positioned(
          bottom: -100,
          right: -100,
          child: _buildDecorativeCircle(300, primaryColor.withOpacity(0.3)),
        ),
 
      ],
    );
  }

  Widget _buildDecorativeCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _buildLoginForm() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/ministry_logo.png"),
            Text(
              "Welcome Back!",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Login to your account",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),
            _buildTextField(_emailController, "Email", Icons.email, false),
            const SizedBox(height: 15),
            _buildTextField(_passwordController, "Password", Icons.lock, true),
            const SizedBox(height: 20),
            _buildLoginButton(),
            const SizedBox(height: 10),
          _buildQRLoginButton(),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {},
              child: const Text("Forgot Password?", style: TextStyle(color: primaryColor)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _isObscured : false,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: primaryColor),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            _isObscured ? Icons.visibility_off : Icons.visibility,
            color: primaryColor,
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
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
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
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 100),
      ),
      child: const Text("Login", style: TextStyle(color: Colors.white, fontSize: 16)),
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
