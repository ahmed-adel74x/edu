import 'package:equatable/equatable.dart';

import '../../../core/network/failure.dart';
import '../data/models/home_summary.dart';

/// Where the dashboard is in its lifecycle.
enum HomeStatus { loading, success, failure }

/// The dashboard screen's own state.
class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.loading,
    this.summary,
    this.failure,
    this.refreshFailure,
  });

  final HomeStatus status;

  /// The loaded payload; null while loading and on a first-load failure.
  final HomeSummary? summary;

  /// Set only when [status] is [HomeStatus.failure].
  final Failure? failure;

  /// Set for exactly one read when a *refresh* failed while old data was kept,
  /// so the screen can report it once (a SnackBar) without losing the data. It
  /// never replaces [summary]; consume it via `HomeCubit.consumeRefreshFailure`.
  final Failure? refreshFailure;

  bool get isLoading => status == HomeStatus.loading;

  bool get hasData => summary != null;

  /// The same state with the one-shot [refreshFailure] cleared.
  HomeState consumeRefreshFailure() =>
      HomeState(status: status, summary: summary, failure: failure);

  @override
  List<Object?> get props => [status, summary, failure, refreshFailure];
}