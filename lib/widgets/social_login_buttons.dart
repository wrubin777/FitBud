import 'package:flutter/material.dart';

class SocialLoginButtons extends StatelessWidget {
  final void Function()? onGoogle;
  final void Function()? onApple;
  final bool isSignUp;
  const SocialLoginButtons({super.key, this.onGoogle, this.onApple, this.isSignUp = false});

  @override
  Widget build(BuildContext context) {
    final googleText = isSignUp ? 'Sign up with Google' : 'Sign in with Google';
    final appleText = isSignUp ? 'Sign up with Apple' : 'Sign in with Apple';
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: Image.asset('assets/google_logo.png', height: 24),
            label: Text(googleText),
            onPressed: onGoogle,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: Icon(Icons.apple, size: 24, color: Colors.black),
            label: Text(appleText),
            onPressed: onApple,
          ),
        ),
      ],
    );
  }
}
