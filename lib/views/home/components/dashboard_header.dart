import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/settings_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../services/sync_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../auth/auth_screen.dart';

class DashboardHeader extends StatelessWidget {
  final SettingsController settingsCtrl;
  const DashboardHeader({super.key, required this.settingsCtrl});

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();

    if (R.isTablet(context)) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppTheme.primary,
      surfaceTintColor: AppTheme.primary,
      toolbarHeight: 64,
      title: Obx(() {
        final user = authCtrl.currentUser.value;
        final bool isLoggedIn = user != null;
        final bool isSyncing = Get.isRegistered<SyncService>() ? Get.find<SyncService>().isSyncing.value : false;

        return Row(
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
                  isLoggedIn ? authCtrl.displayName : 'FNE EXPRESS',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                if (isLoggedIn) {
                  if (Get.isRegistered<SyncService>()) {
                    Get.find<SyncService>().syncAll();
                  }
                } else {
                  Get.to(() => const AuthScreen());
                }
              },
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: isLoggedIn 
                      ? Colors.white.withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: isLoggedIn ? Colors.white : Colors.white.withValues(alpha: 0.3),
                      width: isLoggedIn ? 1.5 : 1),
                ),
                child: isSyncing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Icon(
                        isLoggedIn ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                        color: isLoggedIn ? Colors.white : Colors.white.withValues(alpha: 0.6), 
                        size: 18
                      ),
              ),
            ),
          ],
        );
      }),
      titleSpacing: R.hPad(context),
    );
  }
}
