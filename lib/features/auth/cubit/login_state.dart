import 'package:equatable/equatable.dart';

import '../../../core/network/failure.dart';

/// Where a login submission is in its lifecycle.
enum LoginStatus { idle, loading, success, failure }

/// The login screen's own state.
class LoginState extends Equatable {
  const LoginState({this.status = LoginStatus.idle, this.failure});

  final LoginStatus status;

  /// Set only when [status] is [LoginStatus.failure].
  final Failure? failure;

  bool get isLoading => status == LoginStatus.loading;

  /// Per-field messages a 422 carried, so the screen can show each under its
  /// matching input instead of a generic banner.
  Map<String, List<String>> get fieldErrors =>
      failure is ValidationFailure
      ? (failure! as ValidationFailure).fieldErrors
      : const {};

  @override
  List<Object?> get props => [status, failure];
}
