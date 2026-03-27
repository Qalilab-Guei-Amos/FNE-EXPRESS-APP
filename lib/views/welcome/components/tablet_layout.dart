import 'package:flutter/material.dart';
import 'gradient_bg.dart';
import 'hero_block.dart';
import 'feature_list.dart';
import 'start_button.dart';

class WelcomeTabletLayout extends StatelessWidget {
  final Animation<double> heroFade;
  final Animation<double> heroScale;
  final Animation<double> contentFade;
  final Animation<Offset> contentSlide;
  final VoidCallback onStart;

  const WelcomeTabletLayout({
    super.key,
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
          const WelcomeGradientBg(),
          SafeArea(
            child: Row(
              children: [
                // Colonne gauche : branding
                Expanded(
                  child: FadeTransition(
                    opacity: heroFade,
                    child: ScaleTransition(
                      scale: heroScale,
                      child: const Center(child: HeroBlock(large: true)),
                    ),
                  ),
                ),
                // Séparateur
                Container(
                  width: 1,
                  height: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 48),
                  color: Colors.white.withValues(alpha: 0.12),
                ),
                // Colonne droite : features + bouton
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
                              FeatureList(large: true),
                              const SizedBox(height: 44),
                              StartButton(onTap: onStart, large: true),
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
