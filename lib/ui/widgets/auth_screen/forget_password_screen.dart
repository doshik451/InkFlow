import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isButtonDisabled = true;
  String? _emailError;

  void _validateInputs() {
    final emailValid = RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9_-]+').hasMatch(_emailController.text);

    setState(() {
      _emailError = emailValid ? null : S.of(context).enter_correct_email;
      _isButtonDisabled = _emailController.text.isEmpty || !emailValid;
    });
  }

  Future<void> _resetPassword() async {
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).password_reset_email_sent)),
      );
      Navigator.pop(context);
    }
    catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).an_error_occurred)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      resizeToAvoidBottomInset: true,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _TitleText(S.of(context).reset_password),
                const SizedBox(height: 20,),
                _InputField(
                  controller: _emailController,
                  label: S.of(context).email,
                  errorText: _emailError,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => _validateInputs(),
                ),
                const SizedBox(height: 20,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    minimumSize: const Size(320, 50),
                  ),
                  onPressed: _isButtonDisabled ? null : _resetPassword,
                  child: Text(S.of(context).send_email_to_reset, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 24)),
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
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 20),
          errorText: errorText,
          border: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.surface)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary, width: 2)),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}