import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../app_images.dart';
import '../../../generated/l10n.dart';
import '../../../utils/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isButtonDisabled = true;
  bool _obscureText = true;
  String? _emailError;
  String? _passwordError;

  void _validateInputs() {
    final emailValid = RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9_-]+').hasMatch(_emailController.text);
    final passwordValid = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[!-~]{8,}$').hasMatch(_passwordController.text);

    setState(() {
      _emailError = emailValid ? null : S.of(context).enter_correct_email;
      _passwordError = passwordValid ? null : S.of(context).password_invalid;
      _isButtonDisabled = _emailController.text.isEmpty || _passwordController.text.isEmpty || !emailValid || !passwordValid;
    });
  }

  Future<void> _signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.pushReplacementNamed(context, Routes.modeSelection);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).login_failed,
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Color.lerp(Theme.of(context).colorScheme.tertiary, Colors.white, 0.7),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Image(image: AppImages.catWalking, height: 250),
                _TitleText(S.of(context).app_name),
                const SizedBox(height: 30),
                _InputField(
                  controller: _emailController,
                  label: S.of(context).email,
                  errorText: _emailError,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => _validateInputs(),
                ),
                const SizedBox(height: 10),
                _InputField(
                  controller: _passwordController,
                  label: S.of(context).password,
                  errorText: _passwordError,
                  obscureText: _obscureText,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  ),
                  onChanged: (_) => _validateInputs(),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, Routes.forgetPassword),
                  child: _ClickableText(S.of(context).forget_password, fontSize: 22),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    minimumSize: const Size(350, 50),
                  ),
                  onPressed: _isButtonDisabled ? null : _signIn,
                  child: Text(S.of(context).login, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 24)),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, Routes.register),
                  child: _ClickableText(S.of(context).registration, fontSize: 22, underline: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TitleText extends StatelessWidget {
  final String text;
  const _TitleText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 42));
  }
}

class _ClickableText extends StatelessWidget {
  final String text;
  final double fontSize;
  final bool underline;

  const _ClickableText(this.text, {this.fontSize = 18, this.underline = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: Theme.of(context).colorScheme.surface,
        decoration: underline ? TextDecoration.underline : TextDecoration.none,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? errorText;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const _InputField({
    required this.controller,
    required this.label,
    this.errorText,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontSize: 20),
          errorText: errorText,
          border: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.surface)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary, width: 2)),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
