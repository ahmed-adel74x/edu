// The home cubit: the load lifecycle, the pull-to-refresh that keeps old data,
// the one-shot refresh failure, and the double-call guard.

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:test_edu/core/network/failure.dart';
import 'package:test_edu/core/network/result.dart';
import 'package:test_edu/features/home/cubit/home_cubit.dart';
import 'package:test_edu/features/home/cubit/home_state.dart';
import 'package:test_edu/features/home/data/models/home_summary.dart';

import '../../../helpers/home_test_harness.dart';

void main() {
  late HomeSummary summary;
  late FakeHomeRepository repository;
  late int calls;

  setUp(() {
    summary = sampleHomeSummary();
    repository = FakeHomeRepository();
    calls = 0;
  });

  /// Answers the first [succeedTimes] calls with the payload and every later
  /// one with [failure] (a network drop by default).
  void script({required int succeedTimes, Failure? failure}) {
    when(() => repository.getHome()).thenAnswer(
      (_) async => calls++ < succeedTimes
          ? Success<HomeSummary>(summary)
          : Error<HomeSummary>(
              failure ?? const NetworkFailure(message: 'offline'),
            ),
    );
  }

  group('load', () {
    blocTest<HomeCubit, HomeState>(
      'shows the loader, then the payload',
      setUp: () => script(succeedTimes: 1),
      build: () => HomeCubit(repository: repository),
      act: (cubit) => cubit.load(),
      expect: () => [
        const HomeState(status: HomeStatus.loading),
        HomeState(status: HomeStatus.success, summary: summary),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'a failure replaces the body',
      setUp: () => script(
        succeedTimes: 0,
        failure: const ServerFailure(message: 'boom', statusCode: 500),
      ),
      build: () => HomeCubit(repository: repository),
      act: (cubit) => cubit.load(),
      expect: () => [
        const HomeState(status: HomeStatus.loading),
        const HomeState(
          status: HomeStatus.failure,
          failure: ServerFailure(message: 'boom', statusCode: 500),
        ),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'a second load while one is in flight is ignored',
      setUp: () {
        final pending = Completer<Result<HomeSummary>>();
        when(() => repository.getHome()).thenAnswer((_) => pending.future);
        // Resolve on the next microtask, after both loads have been fired.
        scheduleMicrotask(() => pending.complete(Success<HomeSummary>(summary)));
      },
      build: () => HomeCubit(repository: repository),
      act: (cubit) async {
        final first = cubit.load();
        final second = cubit.load();
        await first;
        await second;
      },
      expect: () => [
        const HomeState(status: HomeStatus.loading),
        HomeState(status: HomeStatus.success, summary: summary),
      ],
      verify: (_) => verify(() => repository.getHome()).called(1),
    );
  });

  group('refresh', () {
    blocTest<HomeCubit, HomeState>(
      'reloads the payload without showing the loader again',
      setUp: () => script(succeedTimes: 2),
      build: () => HomeCubit(repository: repository),
      act: (cubit) async {
        await cubit.load();
        await cubit.refresh();
      },
      // The refresh resolved to the same payload, so the state it produces is
      // identical and the cubit does not re-emit it: no loader flicker.
      expect: () => [
        const HomeState(status: HomeStatus.loading),
        HomeState(status: HomeStatus.success, summary: summary),
      ],
      verify: (_) => verify(() => repository.getHome()).called(2),
    );

    blocTest<HomeCubit, HomeState>(
      'a failed refresh keeps the data and reports the failure once',
      setUp: () => script(succeedTimes: 1),
      build: () => HomeCubit(repository: repository),
      act: (cubit) async {
        await cubit.load();
        await cubit.refresh();
      },
      expect: () => [
        const HomeState(status: HomeStatus.loading),
        HomeState(status: HomeStatus.success, summary: summary),
        HomeState(
          status: HomeStatus.success,
          summary: summary,
          refreshFailure: const NetworkFailure(message: 'offline'),
        ),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'a failed refresh with nothing on screen is a full-body failure',
      setUp: () => script(succeedTimes: 0),
      build: () => HomeCubit(repository: repository),
      act: (cubit) => cubit.refresh(),
      expect: () => [
        const HomeState(
          status: HomeStatus.failure,
          failure: NetworkFailure(message: 'offline'),
        ),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'consumeRefreshFailure clears the one-shot failure',
      setUp: () => script(succeedTimes: 1),
      build: () => HomeCubit(repository: repository),
      act: (cubit) async {
        await cubit.load();
        await cubit.refresh();
        cubit.consumeRefreshFailure();
      },
      expect: () => [
        const HomeState(status: HomeStatus.loading),
        HomeState(status: HomeStatus.success, summary: summary),
        HomeState(
          status: HomeStatus.success,
          summary: summary,
          refreshFailure: const NetworkFailure(message: 'offline'),
        ),
        HomeState(status: HomeStatus.success, summary: summary),
      ],
    );
  });
}
