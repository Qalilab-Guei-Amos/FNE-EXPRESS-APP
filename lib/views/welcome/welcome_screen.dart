import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _heroCtrl;
  late final AnimationController _contentCtrl;

  late final Animation<double> _heroFade;
  late final Animation<double> _heroScale;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroScale = Tween<double>(
      begin: 0.82,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutBack));

    _contentFade = CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut);
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut));

    _heroCtrl.forward().then((_) => _contentCtrl.forward());
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _goHome() {
    Get.off(
      () => const HomeScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isTablet = mq.size.shortestSide >= 600;
    final isLandscape = mq.orientation == Orientation.landscape;

    // Tablette ou paysage large → layout 2 colonnes
    if (isTablet || (isLandscape && mq.size.width >= 700)) {
      return _TabletLayout(
        heroFade: _heroFade,
        heroScale: _heroScale,
        contentFade: _contentFade,
        contentSlide: _contentSlide,
        onStart: _goHome,
      );
    }

    return _MobileLayout(
      heroFade: _heroFade,
      heroScale: _heroScale,
      contentFade: _contentFade,
      contentSlide: _contentSlide,
      onStart: _goHome,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOBILE — colonne centrée
// ─────────────────────────────────────────────────────────────────────────────
class _MobileLayout extends StatelessWidget {
  final Animation<double> heroFade;
  final Animation<double> heroScale;
  final Animation<double> contentFade;
  final Animation<Offset> contentSlide;
  final VoidCallback onStart;

  const _MobileLayout({
    required this.heroFade,
    required this.heroScale,
    required this.contentFade,
    required this.contentSlide,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fond dégradé
          const _GradientBg(),

          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Bloc hero ──────────────────────────
                FadeTransition(
                  opacity: heroFade,
                  child: ScaleTransition(
                    scale: heroScale,
                    child: const _HeroBlock(large: false),
                  ),
                ),

                const Spacer(flex: 2),

                // ── Contenu animé ──────────────────────
                FadeTransition(
                  opacity: contentFade,
                  child: SlideTransition(
                    position: contentSlide,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: [
                          const _FeatureList(large: false),
                          const SizedBox(height: 36),
                          _StartButton(onTap: onStart, large: false),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TABLETTE — 2 colonnes
// ─────────────────────────────────────────────────────────────────────────────
class _TabletLayout extends StatelessWidget {
  final Animation<double> heroFade;
  final Animation<double> heroScale;
  final Animation<double> contentFade;
  final Animation<Offset> contentSlide;
  final VoidCallback onStart;

  const _TabletLayout({
    required this.heroFade,
    required this.heroScale,
    required this.contentFade,
    required this.contentSlide,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _GradientBg(),

          SafeArea(
            child: Row(
              children: [
                // ── Colonne gauche : branding ──────────
                Expanded(
                  child: FadeTransition(
                    opacity: heroFade,
                    child: ScaleTransition(
                      scale: heroScale,
                      child: const Center(child: _HeroBlock(large: true)),
                    ),
                  ),
                ),

                // Séparateur vertical léger
                Container(
                  width: 1,
                  height: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 48),
                  color: Colors.white.withValues(alpha: 0.12),
                ),

                // ── Colonne droite : features + bouton ─
                Expanded(
                  child: FadeTransition(
                    opacity: contentFade,
                    child: SlideTransition(
                      position: contentSlide,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FeatureList(large: true),
                              const SizedBox(height: 44),
                              _StartButton(onTap: onStart, large: true),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets partagés
// ─────────────────────────────────────────────────────────────────────────────

class _GradientBg extends StatelessWidget {
  const _GradientBg();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E7A45), Color(0xFF165C34), Color(0xFF0D3D22)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

class _HeroBlock extends StatelessWidget {
  final bool large;
  const _HeroBlock({required this.large});

  @override
  Widget build(BuildContext context) {
    final iconSize = large ? 68.0 : 52.0;
    final logoBox = large ? 120.0 : 96.0;
    final titleSize = large ? 38.0 : 30.0;
    final subtitleSize = large ? 15.0 : 13.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo
        Container(
          width: logoBox,
          height: logoBox,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.08),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.receipt_long_rounded,
            size: iconSize,
            color: Colors.white,
          ),
        ),
        SizedBox(height: large ? 28 : 20),

        // Titre
        Text(
          'FNE Express',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.4,
          ),
        ),
        SizedBox(height: large ? 10 : 6),

        // Sous-titre
        Text(
          'Factures Normalisées Électroniques',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: subtitleSize,
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w400,
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: large ? 20 : 14),

        // Badge vendeur
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
              Icon(
                Icons.storefront_rounded,
                size: large ? 14 : 12,
                color: AppTheme.accent,
              ),
              SizedBox(width: large ? 7 : 5),
              Text(
                'AMANI DIGITAL SERVICES',
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

class _FeatureList extends StatelessWidget {
  final bool large;
  const _FeatureList({required this.large});

  @override
  Widget build(BuildContext context) {
    final features = [
      (
        Icons.auto_awesome_rounded,
        'Extraction IA automatique',
        'Gemini analyse vos factures instantanément',
      ),
      (
        Icons.verified_rounded,
        'Certification conforme DGI',
        'Génération de FNE signées électroniquement',
      ),
      (
        Icons.share_rounded,
        'Import depuis toutes vos apps',
        'WhatsApp, Gmail, Fichiers et plus encore',
      ),
    ];

    return Column(
      children: features
          .map(
            (f) => Padding(
              padding: EdgeInsets.only(bottom: large ? 20 : 16),
              child: _FeatureTile(
                icon: f.$1,
                title: f.$2,
                subtitle: f.$3,
                large: large,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool large;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.large,
  });

  @override
  Widget build(BuildContext context) {
    final boxSize = large ? 46.0 : 40.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: boxSize,
          height: boxSize,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: large ? 22 : 19,
            color: Colors.white.withValues(alpha: 0.95),
          ),
        ),
        SizedBox(width: large ? 16 : 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: large ? 15 : 13.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: large ? 13 : 11.5,
                  color: Colors.white.withValues(alpha: 0.55),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StartButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool large;
  const _StartButton({required this.onTap, required this.large});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: large ? 56 : 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Commencer',
              style: TextStyle(
                fontSize: large ? 17 : 15.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_rounded,
              size: large ? 20 : 18,
              color: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
