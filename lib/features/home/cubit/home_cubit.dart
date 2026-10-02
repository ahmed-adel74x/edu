import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/result.dart';
import '../data/repositories/home_repository.dart';
import 'home_state.dart';

/// Drives the home dashboard.
///
/// A factory-provided cubit — a fresh one per screen (and therefore a fresh one
/// per session), so a new sign-in never sees the previous user's data. Calls
/// that arrive while a load/refresh is already in flight are ignored.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required this.repository}) : super(const HomeState());

  final HomeRepository repository;

  /// Guards against overlapping calls. It is set synchronously, before the
  /// first `await`, so a double tap can't fire two requests.
  bool _inFlight = false;

  /// Loads the dashboard. Shows the loader, then either the payload or a
  /// full-screen failure.
  Future<void> load() async {
    if (_inFlight) return;
    _inFlight = true;
    emit(const HomeState(status: HomeStatus.loading));
    try {
      await _fetch(isRefresh: false);
    } finally {
      _inFlight = false;
    }
  }

  /// Reloads in the background (pull-to-refresh). A failure keeps the data that
  /// is already on screen and reports the error once instead of replacing it.
  Future<void> refresh() async {
    if (_inFlight) return;
    _inFlight = true;
    try {
      await _fetch(isRefresh: true);
    } finally {
      _inFlight = false;
    }
  }

  /// The screen reports the one-shot [HomeState.refreshFailure] and clears it.
  void consumeRefreshFailure() {
    if (state.refreshFailure == null) return;
    emit(state.consumeRefreshFailure());
  }

  Future<void> _fetch({required bool isRefresh}) async {
    switch (await repository.getHome()) {
      case Success(:final data):
        emit(HomeState(status: HomeStatus.success, summary: data));
      case Error(:final failure):
        final previous = state.summary;
        if (isRefresh && previous != null) {
          emit(
            HomeState(
              status: HomeStatus.success,
              summary: previous,
              refreshFailure: failure,
            ),
          );
        } else {
          emit(HomeState(status: HomeStatus.failure, failure: failure));
        }
    }
  }
}
