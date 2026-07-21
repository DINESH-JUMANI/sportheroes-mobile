/// Result wrapper that carries the API envelope `message` with the payload.
class ApiResult<T> {
  const ApiResult({required this.data, required this.message});

  final T data;
  final String message;
}
