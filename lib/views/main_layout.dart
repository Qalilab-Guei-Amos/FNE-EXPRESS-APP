import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/responsive.dart';
import '../controllers/auth_controller.dart';
import 'home/home_screen.dart';
import 'history/history_screen.dart';
import 'settings/settings_screen.dart';
import 'auth/auth_screen.dart';
import '../controllers/history_controller.dart';
import '../models/fne_record.dart';

class MainLayoutController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  String get currentTitle {
    switch (currentIndex.value) {
      case 0:
        return 'Tableau de Bord';
      case 1:
        return 'Historique des Factures';
      case 2:
        return 'Paramètres';
      default:
        return 'FNE Express';
    }
  }
}

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainLayoutController());
    final authCtrl = Get.find<AuthController>();
    final isTablet = R.isTablet(context);

    final List<Widget> _screens = [
      const HomeScreen(),
      const HistoryScreen(),
      const SettingsScreen(),
    ];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: isTablet
            ? AppBar(
                toolbarHeight: 80,
                elevation: 0,
                backgroundColor: AppTheme.primary,
                automaticallyImplyLeading: false,
                title: Obx(() {
                  final isHome = controller.currentIndex.value == 0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHome ? 'Bonjour,' : controller.currentTitle,
                        style: TextStyle(
                          fontWeight: isHome
                              ? FontWeight.w400
                              : FontWeight.w800,
                          fontSize: isHome ? 13 : 20,
                          color: Colors.white.withValues(
                            alpha: isHome ? 0.7 : 1.0,
                          ),
                        ),
                      ),
                      if (isHome) ...[
                        const SizedBox(height: 2),
                        Text(
                          authCtrl.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ],
                  );
                }),
                actions: [
                  Obx(() {
                    final isLoggedIn = authCtrl.currentUser.value != null;
                    return InkWell(
                      onTap: () => Get.to(() => const AuthScreen()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isLoggedIn
                                  ? Icons.cloud_done_rounded
                                  : Icons.cloud_off_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isLoggedIn ? 'Synchronisé' : 'Hors ligne',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 16),
                ],
              )
            : null,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
              if (isTablet)
                Obx(() {
                  if (controller.currentIndex.value == 1) {
                    final histCtrl = Get.find<HistoryController>();
                    return Container(
                      width: double.infinity,
                      color: AppTheme.primary,
                      child: TabBar(
                        indicatorColor: Colors.white,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white60,
                        tabs: [
                          Obx(
                            () => Tab(
                              text:
                                  'Certifiées (${histCtrl.filteredRecordsByStatus(FneStatus.certifiee).length})',
                            ),
                          ),
                          Obx(
                            () => Tab(
                              text:
                                  'Brouillons (${histCtrl.filteredRecordsByStatus(FneStatus.brouillon).length})',
                            ),
                          ),
                          Obx(
                            () => Tab(
                              text:
                                  'Échecs (${histCtrl.filteredRecordsByStatus(FneStatus.echec).length})',
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

              Expanded(
                child: Row(
                  children: [
                    if (isTablet)
                      _buildSideDrawer(context, controller, authCtrl),
                    Expanded(
                      child: Obx(
                        () => IndexedStack(
                          index: controller.currentIndex.value,
                          children: _screens,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: isTablet
            ? null
            : Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Obx(
                    () => BottomNavigationBar(
                      currentIndex: controller.currentIndex.value,
                      onTap: (i) => controller.changeTab(i),
                      selectedItemColor: AppTheme.primary,
                      unselectedItemColor: AppTheme.textGrey.withValues(
                        alpha: 0.5,
                      ),
                      type: BottomNavigationBarType.fixed,
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.dashboard_rounded),
                          label: 'Accueil',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.history_rounded),
                          label: 'Historique',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.settings_outlined),
                          label: 'Paramètres',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSideDrawer(
    BuildContext context,
    MainLayoutController controller,
    AuthController authCtrl,
  ) {
    return Container(
      width: 100,
      margin: const EdgeInsets.fromLTRB(16, 16, 0, 16),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),
          const Spacer(),
          _sideDrawerItem('Tableau', Icons.dashboard_rounded, 0, controller),
          _sideDrawerItem('Historique', Icons.history_rounded, 1, controller),
          _sideDrawerItem('Paramètres', Icons.settings_rounded, 2, controller),
          const Spacer(),
          Obx(() {
            if (authCtrl.currentUser.value == null) {
              return const SizedBox.shrink();
            }
            return InkWell(
              onTap: () => authCtrl.signOut(),
              child: const Column(
                children: [
                  Icon(
                    Icons.power_settings_new_rounded,
                    color: Colors.white70,
                    size: 24,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Déconnexion',
                    style: TextStyle(color: Colors.white60, fontSize: 9),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _sideDrawerItem(
    String label,
    IconData icon,
    int index,
    MainLayoutController controller,
  ) {
    return Obx(() {
      final isSelected = controller.currentIndex.value == index;
      return GestureDetector(
        onTap: () => controller.changeTab(index),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? AppTheme.primary
                      : Colors.white.withValues(alpha: 0.6),
                  size: 26,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: isSelected ? 1 : 0.6),
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
