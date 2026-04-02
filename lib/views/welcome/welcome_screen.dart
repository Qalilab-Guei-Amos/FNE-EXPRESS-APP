import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/storage_service.dart';
import '../main_layout.dart';
import 'components/mobile_layout.dart';
import 'components/tablet_layout.dart';

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
    Get.find<StorageService>().setHasSeenWelcome();
    Get.off(
      () => const MainLayout(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isTablet = mq.size.shortestSide >= 600;
    final isLandscape = mq.orientation == Orientation.landscape;

    if (isTablet || (isLandscape && mq.size.width >= 700)) {
      return WelcomeTabletLayout(
        heroFade: _heroFade,
        heroScale: _heroScale,
        contentFade: _contentFade,
        contentSlide: _contentSlide,
        onStart: _goHome,
      );
    }

    return WelcomeMobileLayout(
      heroFade: _heroFade,
      heroScale: _heroScale,
      contentFade: _contentFade,
      contentSlide: _contentSlide,
      onStart: _goHome,
    );
  }
}
