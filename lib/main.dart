import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_strings.dart';
import 'core/di/injection.dart';
import 'core/network/interceptors/language_interceptor.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_colors_extension.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'features/auth/cubit/auth_cubit.dart';

/// Where the translations live (`assets/translations/<lang>.json`).
const translationsPath = 'assets/translations';

/// The languages the app ships in, Arabic first.
const appSupportedLocales = <Locale>[Locale('ar'), Locale('en')];

/// Arabic: the app's primary market, so it is also what a first launch opens in.
const appFallbackLocale = Locale('ar');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  // The network layer's singletons are ready before the first frame.
  final auth = await initInjection();
  // Read the saved session before the first frame, so the app starts directly in
  // the right state instead of showing a splash and then flipping.
  await auth.restore();
  // Read the saved appearance before the first frame, so the app never opens in
  // the wrong theme and then flips.
  final themeMode = await ThemeNotifier.loadSaved();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MyApp(auth: auth, initialThemeMode: themeMode));
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.auth,
    this.assetLoader,
    this.initialThemeMode = ThemeMode.system,
  });

  /// The app's session cubit. `main()` builds and restores it before the first
  /// frame and owns it; tests pass their own so the app boots already signed in.
  final AuthCubit auth;

  /// How the translations are read. Tests pass one that answers from memory, so
  /// the first frame is already localized instead of waiting on the asset
  /// bundle; the app itself reads the bundle.
  final AssetLoader? assetLoader;

  /// Appearance to start the app with — the mode main() read from the device.
  final ThemeMode initialThemeMode;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// The router owns the app's current location and the theme notifier owns the
  /// appearance. The session cubit is owned by `main()`, not by this widget.
  late final ThemeNotifier _theme = ThemeNotifier(widget.initialThemeMode);
  late final GoRouter _router = createAppRouter(auth: widget.auth);

  @override
  void dispose() {
    _theme.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      supportedLocales: appSupportedLocales,
      path: translationsPath,
      fallbackLocale: appFallbackLocale,
      startLocale: appFallbackLocale,
      useOnlyLangCode: true,
      assetLoader: widget.assetLoader ?? const RootBundleAssetLoader(),
      child: ThemeScope(
        notifier: _theme,
        // The mode lives on the notifier, so the app rebuilds — and the
        // system bars with it — the moment it changes.
        child: ListenableBuilder(
          listenable: _theme,
          builder: (context, child) => ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) => Builder(
              // A context below EasyLocalization, so the localizations it
              // installs can be handed to MaterialApp.
              builder: (context) {
                // Keep the network layer's language in step with the live
                // locale, so Accept-Language follows `context.setLocale`
                // without the interceptor ever touching a BuildContext.
                LocaleHolder.instance.languageCode =
                    context.locale.languageCode;
                // The session cubit sits above the navigator, so every screen
                // (and the temporary logout buttons) can read it.
                return BlocProvider<AuthCubit>.value(
                  value: widget.auth,
                  child: MaterialApp.router(
                    onGenerateTitle: (context) => AppStrings.appTitle,
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.light(),
                    darkTheme: AppTheme.dark(),
                    themeMode: _theme.mode,
                    localizationsDelegates: context.localizationDelegates,
                    supportedLocales: context.supportedLocales,
                    locale: context.locale,
                    routerConfig: _router,
                    builder: (context, child) =>
                        _SystemUi(colors: context.colors, child: child!),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints the status and navigation bars in the app's own colors: the region is
/// what the framework reads to style the system chrome, so it follows the theme
/// without an imperative call.
class _SystemUi extends StatelessWidget {
  const _SystemUi({required this.colors, required this.child});

  final AppColorsExtension colors;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final iconBrightness = dark ? Brightness.light : Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: iconBrightness,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: colors.surface,
        systemNavigationBarDividerColor: colors.border,
        systemNavigationBarIconBrightness: iconBrightness,
      ),
      child: child,
    );
  }
}
