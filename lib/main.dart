import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'services/storage_service.dart';
import 'services/gemini_service.dart';
import 'services/fne_api_service.dart';
import 'services/share_intent_service.dart';
import 'services/export_service.dart';
import 'views/welcome/welcome_screen.dart';
import 'views/main_layout.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_service.dart';
import 'services/sync_service.dart';
import 'controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Variables d'environnement
  await dotenv.load(fileName: '.env');

  // Initialisation Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // Hive
  await Hive.initFlutter();

  // Enregistrement des services GetX (permanents pour toute la durée de l'app)
  final storage = await Get.putAsync<StorageService>(
    () => StorageService().init(),
  );
  Get.put<GeminiService>(GeminiService());
  Get.put<FneApiService>(FneApiService());
  Get.put<ShareIntentService>(ShareIntentService());
  Get.put<ExportService>(ExportService());
  Get.put<SupabaseService>(SupabaseService());
  Get.put<SyncService>(SyncService());
  Get.put<AuthController>(AuthController());

  await initializeDateFormatting('fr_FR', null);

  final bool hasSeenWelcome = storage.hasSeenWelcome;

  runApp(FneExpressApp(showWelcome: !hasSeenWelcome));
}

class FneExpressApp extends StatelessWidget {
  final bool showWelcome;
  const FneExpressApp({super.key, required this.showWelcome});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, _) => ToastificationWrapper(
        child: GetMaterialApp(
          title: 'FNE Express',
          locale: const Locale('fr', 'FR'),
          debugShowCheckedModeBanner: false,
          defaultTransition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 100),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('fr', 'FR')],
          theme: AppTheme.lightTheme,
          home: showWelcome ? const WelcomeScreen() : const MainLayout(),
        ),
      ),
    );
  }
}
