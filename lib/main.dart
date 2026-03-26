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
import 'views/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Variables d'environnement
  await dotenv.load(fileName: '.env');

  // Hive
  await Hive.initFlutter();

  // Enregistrement des services GetX (permanents pour toute la durée de l'app)
  await Get.putAsync<StorageService>(() => StorageService().init());
  Get.put<GeminiService>(GeminiService());
  Get.put<FneApiService>(FneApiService());

  await initializeDateFormatting('fr_FR', null);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  runApp(const FneExpressApp());
}

class FneExpressApp extends StatelessWidget {
  const FneExpressApp({super.key});

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
          transitionDuration: const Duration(milliseconds: 200),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('fr', 'FR')],
          theme: AppTheme.lightTheme,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
