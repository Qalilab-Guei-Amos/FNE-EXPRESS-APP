import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import 'components/auth_form.dart';
import 'components/auth_logo.dart';
import 'components/profile_view.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  void dispose() {
    if (Get.isRegistered<AuthController>()) {
      Get.find<AuthController>().resetForm();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AuthController());
    final isTablet = R.isTablet(context);

    // Couleur de fond uniforme pour assurer la transition
    const bgColor = Color(0xFFf5f5ed);

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isTablet ? Colors.white : AppTheme.textDark),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isTablet ? Brightness.light : Brightness.dark,
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: isTablet 
            ? _buildTabletView(context, ctrl)
            : _buildMobileView(context, ctrl),
      ),
    );
  }

  // ── VUE TABLETTE (Split Screen) ──────────────────────────────────────────
  Widget _buildTabletView(BuildContext context, AuthController ctrl) {
    return Row(
      children: [
        // Côté Gauche : Visuel & Branding
        Expanded(
          flex: 4,
          child: Container(
            color: AppTheme.primary,
            child: Stack(
              children: [
                // Cercles décoratifs
                Positioned(
                  top: -100,
                  left: -100,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  right: -50,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)),
                  ),
                ),
                // Contenu Branding
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(60.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AuthLogo(size: 100),
                        const SizedBox(height: 40),
                        const Text(
                          'Simplifiez la gestion\nde vos factures.',
                          style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: -1.0),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'FNE Express vous permet de numériser, certifier et synchroniser vos documents en un clin d\'œil.',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 18, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Côté Droit : Formulaire
        Expanded(
          flex: 5,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(60),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Obx(() => ctrl.isAuthenticated 
                    ? ProfileView(ctrl: ctrl, isTablet: true) 
                    : AuthForm(ctrl: ctrl, isTablet: true)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── VUE MOBILE ─────────────────────────────────────────────────────────────
  Widget _buildMobileView(BuildContext context, AuthController ctrl) {
    return SafeArea(
      top: false,
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: R.hPad(context), vertical: 40),
          child: Obx(() => ctrl.isAuthenticated 
              ? ProfileView(ctrl: ctrl, isTablet: false) 
              : AuthForm(ctrl: ctrl, isTablet: false)),
        ),
      ),
    );
  }
}
