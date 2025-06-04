import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../app_images.dart';
import '../../../generated/l10n.dart';
import '../../../utils/routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isButtonEnabled = false;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  void _validateInputs() {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9_-]+');
    final passwordRegExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[!-~]{8,}$');

    setState(() {
      emailError = emailRegExp.hasMatch(emailController.text.trim()) ? null : S.of(context).enter_correct_email;
      passwordError = passwordRegExp.hasMatch(passwordController.text.trim())
          ? null
          : S.of(context).password_invalid;
      confirmPasswordError = (passwordController.text == confirmPasswordController.text)
          ? null
          : S.of(context).passwords_do_not_match;

      isButtonEnabled = usernameController.text.trim().isNotEmpty &&
          emailController.text.trim().isNotEmpty &&
          passwordController.text.trim().isNotEmpty &&
          confirmPasswordController.text.trim().isNotEmpty &&
          emailError == null &&
          passwordError == null &&
          confirmPasswordError == null;
    });
  }

  @override
  void initState() {
    super.initState();
    usernameController.addListener(_validateInputs);
    emailController.addListener(_validateInputs);
    passwordController.addListener(_validateInputs);
    confirmPasswordController.addListener(_validateInputs);
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
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
                const Image(image: AppImages.catWashing, height: 250),
                _TitleText(S.of(context).app_name),
                const SizedBox(height: 30),
                UsernameInputWidget(controller: usernameController),
                const SizedBox(height: 10),
                EmailInputWidget(controller: emailController, errorText: emailError),
                const SizedBox(height: 10),
                PasswordInputWidget(controller: passwordController, errorText: passwordError),
                const SizedBox(height: 10),
                ConfirmPasswordInputWidget(passwordController: passwordController, controller: confirmPasswordController, errorText: confirmPasswordError),
                const SizedBox(height: 20),
                _RegisterButton(
                  emailController: emailController,
                  passwordController: passwordController,
                  usernameController: usernameController,
                  isButtonEnabled: isButtonEnabled,
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, Routes.login),
                  child: _ClickableText(S.of(context).login, fontSize: 22, underline: true),
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

class UsernameInputWidget extends StatefulWidget {
  final TextEditingController controller;
  const UsernameInputWidget({super.key, required this.controller});

  @override
  State<UsernameInputWidget> createState() => _UsernameInputWidgetState();
}

class _UsernameInputWidgetState extends State<UsernameInputWidget> {
  @override
  Widget build(BuildContext context) {
    return _InputField(
      controller: widget.controller,
      label: S.of(context).username,
    );
  }
}

class PasswordInputWidget extends StatefulWidget {
  String? errorText;
  PasswordInputWidget({super.key, required this.controller, required this.errorText});

  final TextEditingController controller;

  @override
  State<PasswordInputWidget> createState() => _PasswordInputWidgetState();
}

class _PasswordInputWidgetState extends State<PasswordInputWidget> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return _InputField(
      controller: widget.controller,
      errorText: widget.errorText,
      label: S.of(context).password,
      obscureText: _obscureText,
      suffixIcon: IconButton(
        icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
        onPressed: () => setState(() => _obscureText = !_obscureText),
      ),
    );
  }
}

class ConfirmPasswordInputWidget extends StatefulWidget {
  ConfirmPasswordInputWidget({super.key, required this.passwordController, required this.errorText, required this.controller});

  final TextEditingController passwordController;
  final TextEditingController controller;
  String? errorText;

  @override
  State<ConfirmPasswordInputWidget> createState() => _ConfirmPasswordInputWidgetState();
}

class _ConfirmPasswordInputWidgetState extends State<ConfirmPasswordInputWidget> {
  bool _obscureText = true;

  void _validatePassword(String value) {
    setState(() {
      widget.errorText = value == widget.passwordController.text ? null : S.of(context).passwords_do_not_match;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _InputField(
      controller: widget.controller,
      label: S.of(context).confirm_password,
      obscureText: _obscureText,
      suffixIcon: IconButton(
        icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
        onPressed: () => setState(() => _obscureText = !_obscureText),
      ),
      errorText: widget.errorText,
      onChanged: _validatePassword,
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

class _RegisterButton extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController usernameController;
  final bool isButtonEnabled;

  const _RegisterButton({
    required this.emailController,
    required this.passwordController,
    required this.usernameController,
    required this.isButtonEnabled,
  });

  Future<void> _register(BuildContext context) async {
    try {
      final auth = FirebaseAuth.instance;
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await userCredential.user?.updateDisplayName(usernameController.text.trim());
      await userCredential.user?.reload();
      Navigator.pushReplacementNamed(context, Routes.modeSelection);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).registration_failed,
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
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        minimumSize: const Size(350, 50),
      ),
      onPressed: isButtonEnabled ? () => _register(context) : null,
      child: Text(S.of(context).registration, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 24)),
    );
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

class EmailInputWidget extends StatefulWidget {
  final TextEditingController controller;
  String? errorText;
  EmailInputWidget({super.key, required this.controller, required this.errorText});

  @override
  State<EmailInputWidget> createState() => _EmailInputWidgetState();
}

class _EmailInputWidgetState extends State<EmailInputWidget> {
  void _validateEmail(String value) {
    final regExp = RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9_-]+');
    setState(() => widget.errorText = regExp.hasMatch(value) ? null : S.of(context).enter_correct_email);
  }

  @override
  Widget build(BuildContext context) {
    return _InputField(
      controller: widget.controller,
      label: S.current.email,
      errorText: widget.errorText,
      onChanged: _validateEmail,
      keyboardType: TextInputType.emailAddress,
    );
  }
}