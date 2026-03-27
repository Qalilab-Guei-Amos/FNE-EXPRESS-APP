import 'package:flutter/material.dart';
import '../../../controllers/settings_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';

class DashboardHeader extends StatelessWidget {
  final SettingsController settingsCtrl;
  const DashboardHeader({super.key, required this.settingsCtrl});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppTheme.primary,
      surfaceTintColor: AppTheme.primary,
      toolbarHeight: 64,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour,',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                settingsCtrl.establishmentCtrl.text.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 18),
          ),
        ],
      ),
      titleSpacing: R.hPad(context),
    );
  }
}

