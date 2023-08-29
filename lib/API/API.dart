class APIResponse<T> {
  T? data;
  bool hasError;
  String errorMessage;

  APIResponse({this.data, this.hasError = false, this.errorMessage = ""});
}
