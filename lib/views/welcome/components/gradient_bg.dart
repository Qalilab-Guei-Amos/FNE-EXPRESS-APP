import 'package:flutter/material.dart';

class WelcomeGradientBg extends StatelessWidget {
  const WelcomeGradientBg({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF7F9F7),
            Color(0xFFEEF3EE),
          ],
        ),
      ),
    );
  }
}
