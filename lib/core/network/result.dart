import 'failure.dart';

/// The outcome of an operation that can fail: [Success] with data, or [Error]
/// with a [Failure].
///
/// A tiny sealed type of our own — [fold] / [when] are everything a repository
/// caller needs, so no functional-programming package is pulled in.
sealed class Result<T> {
  const Result();

  /// Collapses the result to a single value.
  R fold<R>(
    R Function(T data) onSuccess,
    R Function(Failure failure) onError,
  ) => switch (this) {
    Success<T>(:final data) => onSuccess(data),
    Error<T>(:final failure) => onError(failure),
  };

  /// Like [fold], with named callbacks.
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) error,
  }) => fold(success, error);

  /// Keeps a failure as-is and transforms the value of a success.
  Result<R> map<R>(R Function(T data) transform) => switch (this) {
    Success<T>(:final data) => Success<R>(transform(data)),
    Error<T>(:final failure) => Error<R>(failure),
  };
}

/// A successful result carrying [data].
final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

/// A failed result carrying its [failure].
final class Error<T> extends Result<T> {
  const Error(this.failure);

  final Failure failure;
}
