import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/result.dart';
import '../data/repositories/auth_repository.dart';
import 'auth_cubit.dart';
import 'login_state.dart';

/// Drives one login screen.
///
/// A factory-provided cubit — a fresh one per screen — that calls the repository
/// and, on success, hands the account to the global [AuthCubit].
class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required this.repository, required this.authCubit})
    : super(const LoginState());

  final AuthRepository repository;
  final AuthCubit authCubit;

  /// Submits the credentials. Calls that arrive while a submission is in flight
  /// are ignored, so a double tap can't fire two requests.
  Future<void> submit({required String email, required String password}) async {
    if (state.isLoading) return;
    emit(const LoginState(status: LoginStatus.loading));

    switch (await repository.login(email: email, password: password)) {
      case Success(:final data):
        emit(const LoginState(status: LoginStatus.success));
        authCubit.onLoggedIn(data);
      case Error(:final failure):
        emit(LoginState(status: LoginStatus.failure, failure: failure));
    }
  }
}
