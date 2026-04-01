import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../auth/auth_screen.dart';

class SyncActionButton extends StatelessWidget {
  final AuthController authCtrl;

  const SyncActionButton({super.key, required this.authCtrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isLoggedIn = authCtrl.currentUser.value != null;
      return GestureDetector(
        onTap: () => Get.to(() => const AuthScreen()),
        child: Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: isLoggedIn
                ? Colors.white.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
                color: isLoggedIn
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.3),
                width: isLoggedIn ? 1.5 : 1),
          ),
          child: Icon(
            isLoggedIn ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
            color: isLoggedIn
                ? Colors.white
                : Colors.white.withValues(alpha: 0.6),
            size: 18,
          ),
        ),
      );
    });
  }
}
