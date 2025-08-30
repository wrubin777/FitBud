import 'package:flutter/material.dart';

class PostRegisterSplash extends StatelessWidget {
  const PostRegisterSplash({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/personalinfo');
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text('Setting up your FitBud experience...', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}