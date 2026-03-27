import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class HeroBlock extends StatelessWidget {
  final bool large;
  const HeroBlock({super.key, required this.large});

  @override
  Widget build(BuildContext context) {
    final logoBox = large ? 180.0 : 140.0;
    final titleSize = large ? 38.0 : 30.0;
    final subtitleSize = large ? 15.0 : 13.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: logoBox,
          height: logoBox,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage('assets/images/logo.png'),
              fit: BoxFit.cover,
            ),
            color: const Color(0xFFf5f5ed),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
              
            ],
          ),
        ),
        SizedBox(height: large ? 28 : 20),
        Text(
          'FNE Express',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1A3828),
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: large ? 10 : 6),
        Text(
          'Factures Normalisées Électroniques',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: subtitleSize,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: large ? 20 : 14),
        // Badge conforme DGI
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: large ? 18 : 14,
            vertical: large ? 7 : 5,
          ),
          decoration: BoxDecoration(
            color: AppTheme.accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.accent.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.storefront_rounded,
                  size: large ? 14 : 12, color: AppTheme.accent),
              SizedBox(width: large ? 7 : 5),
              Text(
                'CONFORME DGI CÔTE D\'IVOIRE',
                style: TextStyle(
                  fontSize: large ? 12 : 10.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accent,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
