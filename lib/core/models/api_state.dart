/// Reusable async state for Riverpod notifiers across all features.
///
/// Use with [Notifier] / [AsyncNotifier] patterns so screens can render
/// loading, success, and error consistently.
sealed class ApiState<T> {
  const ApiState();

  bool get isInitial => this is ApiInitial<T>;
  bool get isLoading => this is ApiLoading<T>;
  bool get isSuccess => this is ApiSuccess<T>;
  bool get isError => this is ApiError<T>;

  T? get dataOrNull => switch (this) {
    ApiSuccess<T>(:final data) => data,
    _ => null,
  };

  String? get errorOrNull => switch (this) {
    ApiError<T>(:final message) => message,
    _ => null,
  };

  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) success,
    required R Function(String message) error,
  }) {
    return switch (this) {
      ApiInitial<T>() => initial(),
      ApiLoading<T>() => loading(),
      ApiSuccess<T>(:final data) => success(data),
      ApiError<T>(:final message) => error(message),
    };
  }

  R maybeWhen<R>({
    R Function()? initial,
    R Function()? loading,
    R Function(T data)? success,
    R Function(String message)? error,
    required R Function() orElse,
  }) {
    return switch (this) {
      ApiInitial<T>() => initial?.call() ?? orElse(),
      ApiLoading<T>() => loading?.call() ?? orElse(),
      ApiSuccess<T>(:final data) => success?.call(data) ?? orElse(),
      ApiError<T>(:final message) => error?.call(message) ?? orElse(),
    };
  }
}

final class ApiInitial<T> extends ApiState<T> {
  const ApiInitial();
}

final class ApiLoading<T> extends ApiState<T> {
  const ApiLoading();
}

final class ApiSuccess<T> extends ApiState<T> {
  const ApiSuccess(this.data);
  final T data;
}

final class ApiError<T> extends ApiState<T> {
  const ApiError(this.message);
  final String message;
}
