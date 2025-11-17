import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:parrokit/repositories/user_repository.dart';
import 'package:parrokit/services/firebase_user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:parrokit/config/onboarding_prefs.dart';
import 'package:parrokit/config/pa_config.dart';
import 'package:parrokit/data/local/prefs/user_prefs.dart';
import 'package:parrokit/provider/dashboard_ui_provider.dart';
import 'package:parrokit/provider/iap_provider.dart';
import 'package:parrokit/provider/shorts_provider.dart';
import 'package:parrokit/provider/tag_filter_provider.dart';
import 'package:parrokit/provider/theme_provider.dart';
import 'package:parrokit/provider/user_provider.dart';
import 'package:parrokit/services/ad_service.dart';
import 'package:parrokit/services/firebase_auth_service.dart';
import 'package:parrokit/utils/audio_bg.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/theme/pa_theme.dart';
import 'package:parrokit/pa_router.dart';
import 'package:parrokit/data/local/pa_database.dart';
import 'package:parrokit/provider/media_provider.dart';
import 'package:parrokit/provider/ad_provider.dart';
import 'package:parrokit/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  await ensureAudioHandler();
  final seen = await OnboardingPrefs.isOnboarded();
  final paRouter = buildPaRouter(seenOnboarding: seen);
  // Config/Theme
  await PaConfig.loadFromPrefs();
  final theme = ThemeProvider();
  await theme.loadTheme();

  // 광고 SDK 초기화
  await MobileAds.instance.initialize();
  AdService().loadAd();

  // auth service
  final prefs = await SharedPreferences.getInstance();
  final _userPrefs = UserPrefs(prefs);
  final _authService = FirebaseAuthService();
  final _userService = FirebaseUserService();
  final _userRepository = UserRepository(
    _userPrefs,
    _authService,
    _userService,
  );

  // IAP Provider
  final iap = IapProvider();
  await iap.init();

  // AdProvider (premium 상태 동기화)
  final adProvider = AdProvider(initialPremium: iap.isPremium);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: theme),
        ChangeNotifierProvider<IapProvider>.value(value: iap),
        ChangeNotifierProvider<AdProvider>.value(value: adProvider),
        Provider<PaDatabase>(
          create: (_) => PaDatabase(),
          dispose: (_, db) => db.close(),
        ),
        ChangeNotifierProvider(
          create: (c) => UserProvider(_userRepository)..init(),
        ),
        ChangeNotifierProvider<DashboardUiProvider>(
          lazy: false,
          create: (c) => DashboardUiProvider(c.read<PaDatabase>()),
        ),
        ChangeNotifierProvider<MediaProvider>(
          create: (c) => MediaProvider(c.read<PaDatabase>()),
        ),
        ChangeNotifierProvider<ShortsProvider>(
          create: (c) => ShortsProvider(c.read<PaDatabase>()),
        ),
        ChangeNotifierProvider<TagFilterProvider>(
          create: (c) => TagFilterProvider(c.read<PaDatabase>()),
        ),
      ],
      child: ParoAnime(
        paRouter: paRouter,
      ),
    ),
  );
}

class ParoAnime extends StatelessWidget {
  const ParoAnime({super.key, required this.paRouter});

  final GoRouter paRouter;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return MaterialApp.router(
      title: 'Parrokit',
      theme: PaTheme.light,
      darkTheme: PaTheme.dark,
      themeMode: theme.themeMode,
      routerConfig: paRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
