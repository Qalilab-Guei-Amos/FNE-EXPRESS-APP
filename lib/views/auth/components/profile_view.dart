import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../services/sync_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import 'auth_logo.dart';
import 'profile_action_button.dart';

class ProfileView extends StatelessWidget {
  final AuthController ctrl;
  final bool isTablet;

  const ProfileView({
    super.key,
    required this.ctrl,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!isTablet) ...[
          const AuthLogo(size: 110),
          const SizedBox(height: 32),
        ],
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 32,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                'Compte Sécurisé',
                style: TextStyle(
                  fontSize: R.fs(context, 22),
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ctrl.currentUser.value?.email ?? '',
                style: TextStyle(
                  fontSize: R.fs(context, 15),
                  color: AppTheme.textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
              
              GetX<SyncService>(builder: (syncService) {
                return Column(
                  children: [
                    ProfileActionButton(
                      label: syncService.isSyncing.value ? 'Envoi...' : 'Synchroniser le Cloud',
                      icon: syncService.isSyncing.value ? null : Icons.sync_rounded,
                      onPressed: syncService.isSyncing.value ? null : syncService.syncCertifiedRecords,
                      isLoading: syncService.isSyncing.value,
                      primary: true,
                    ),
                    const SizedBox(height: 16),
                    ProfileActionButton(
                      label: 'Restaurer mon historique',
                      icon: Icons.download_for_offline_rounded,
                      onPressed: syncService.isSyncing.value ? null : syncService.restoreFromCloud,
                      isLoading: false,
                      primary: false,
                    ),
                  ],
                );
              }),
              const SizedBox(height: 24),
              ProfileActionButton(
                label: 'Me déconnecter',
                icon: Icons.logout,
                onPressed: ctrl.isLoading.value ? null : ctrl.signOut,
                isLoading: ctrl.isLoading.value,
                isDanger: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
