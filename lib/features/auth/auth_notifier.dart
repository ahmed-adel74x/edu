import 'package:flutter/widgets.dart';

import '../../shared/models/user.dart';
import '../../shared/models/user_role.dart';

/// The app's auth state.
///
/// A plain [ChangeNotifier] on purpose: the router needs a [Listenable] for
/// `GoRouter.refreshListenable` and the screens need to read the current role
/// and to sign in / out, which this covers without pulling a state-management
/// package in before the backend exists. It is deliberately shaped like the
/// `AuthCubit` that will replace it — one role plus `signIn` / `signOut` — so
/// that swap stays mechanical.
class AuthNotifier extends ChangeNotifier {
  /// Starts signed out, which is what the real app does.
  AuthNotifier();

  /// Starts already signed in as [role]: used by tests, and by anyone who wants
  /// the app to boot straight into a role's shell.
  factory AuthNotifier.signedIn([UserRole role = UserRole.student]) =>
      AuthNotifier._(_mockUser(role));

  /// Seeds the session — private, since the two public constructors cover the
  /// cases the app has.
  AuthNotifier._(this._user);

  User? _user;

  User? get user => _user;

  /// The role that decides which shell the app shows, or null while nobody is
  /// signed in.
  UserRole? get role => _user?.role;

  bool get isSignedIn => _user != null;

  /// Mock sign-in: no credentials are checked and nothing is stored yet — the
  /// picked [role] is all the router needs. Swap the body for the real request
  /// (and a token) when the backend lands.
  void signInWithRole(UserRole role) {
    _user = _mockUser(role);
    notifyListeners();
  }

  void signOut() {
    if (_user == null) return;
    _user = null;
    notifyListeners();
  }

  static User _mockUser(UserRole role) => User(
        id: 'mock-${role.name}',
        name: switch (role) {
          UserRole.student => 'أحمد',
          UserRole.teacher => 'منى',
          UserRole.parent => 'والد أحمد',
        },
        role: role,
      );
}

/// Makes the app's [AuthNotifier] reachable from every screen.
///
/// An [InheritedNotifier] rather than a package: it rebuilds its dependents when
/// auth changes (so a screen can react to a sign-out) and `of(context)` is the
/// only API the screens need. When the Cubit arrives this becomes the
/// `BlocProvider` sitting above the router.
class AuthScope extends InheritedNotifier<AuthNotifier> {
  const AuthScope({
    super.key,
    required AuthNotifier super.notifier,
    required super.child,
  });

  static AuthNotifier of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'No AuthScope found above this context.');
    return scope!.notifier!;
  }
}
