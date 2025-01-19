class ApiResponse<T> {
  final T? data;
  final String? errorMessage;
  final bool isLoading;

  ApiResponse({
    this.data,
    this.errorMessage,
    this.isLoading = false,
  });

  factory ApiResponse.loading() => ApiResponse(isLoading: true);

  factory ApiResponse.success(T data) => ApiResponse(data: data);

  factory ApiResponse.error(String message) => ApiResponse(errorMessage: message);

  bool get hasError => errorMessage != null;
  bool get hasData => data != null;
}