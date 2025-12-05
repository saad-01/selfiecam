class ApiResponse {
  ApiResponse({this.success, this.data, this.message, this.errors});

  factory ApiResponse.fromJson(dynamic json) {
    final ApiResponse model = ApiResponse(
      success: json['success'] as bool?,
      data: json['data'],
      message: json['message'] as String? ?? '',
      errors:
      json['errors'] is Map<String, dynamic>
          ? json['errors'] as Map<String, dynamic>?
          : (json['errors'] is List ? {'general': json['errors']} : null),
    );

    // Handle errors if the result is not true
    if (model.success != true) {
      final String? userError = model.errors?['user'] as String?;
      if (userError != null) {
        model.message = userError;
      } else if (model.errors != null) {
        // Fallback to the first available error message
        final dynamic firstError = model.errors!.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          model.message = firstError.first as String;
        } else if (firstError is String) {
          model.message = firstError;
        }
      }
    }

    return model;
  }
  bool? success;
  dynamic data;
  String? message;
  Map<String, dynamic>? errors;
}
