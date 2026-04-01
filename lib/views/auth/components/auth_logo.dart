import 'package:flutter/material.dart';

class AuthLogo extends StatelessWidget {
  final double size;

  const AuthLogo({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: const DecorationImage(
          image: AssetImage('assets/images/logo.png'),
          fit: BoxFit.cover,
        ),
        color: const Color(0xFFf5f5ed),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 12),
          ),
        ],
      ),
    );
  }
}
