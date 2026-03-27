import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class StartButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool large;
  const StartButton({super.key, required this.onTap, required this.large});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: large ? 56 : 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppTheme.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'COMMENCER',
              style: TextStyle(
                fontSize: large ? 16 : 14.5,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded,
                size: large ? 18 : 16, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
