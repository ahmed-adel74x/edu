import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.auth});

  /// Auth state to start the app with. Tests pass a signed-in [AuthNotifier] so
  /// they begin inside a role's shell instead of walking through login; the app
  /// builds its own (signed-out) one when this is null.
  final AuthNotifier? auth;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// Both live in state — never as globals: the router owns the app's current
  /// location and the notifier owns the session.
  late final AuthNotifier _auth = widget.auth ?? AuthNotifier();
  late final GoRouter _router = createAppRouter(auth: _auth);

  @override
  void dispose() {
    // Only the notifier this widget created belongs to it.
    if (widget.auth == null) _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The scope sits above the router so every route — and the route helpers —
    // can read the current role and sign in / out.
    return AuthScope(
      notifier: _auth,
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp.router(
            title: 'استكشاف الدورات',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.data(),
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
