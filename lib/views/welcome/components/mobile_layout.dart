import 'package:flutter/material.dart';
import 'gradient_bg.dart';
import 'hero_block.dart';
import 'feature_list.dart';
import 'start_button.dart';

class WelcomeMobileLayout extends StatelessWidget {
  final Animation<double> heroFade;
  final Animation<double> heroScale;
  final Animation<double> contentFade;
  final Animation<Offset> contentSlide;
  final VoidCallback onStart;

  const WelcomeMobileLayout({
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
            child: Column(
              children: [
                const Spacer(flex: 2),
                FadeTransition(
                  opacity: heroFade,
                  child: ScaleTransition(
                    scale: heroScale,
                    child: const HeroBlock(large: false),
                  ),
                ),
                const Spacer(flex: 2),
                FadeTransition(
                  opacity: contentFade,
                  child: SlideTransition(
                    position: contentSlide,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: [
                          FeatureList(large: false),
                          const SizedBox(height: 36),
                          StartButton(onTap: onStart, large: false),
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
