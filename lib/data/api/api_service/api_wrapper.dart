import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import '../../../infrastructure/constants/api_endpoints.dart';
import '../../../infrastructure/constants/shared_pref_keys.dart';
import '../../../infrastructure/utils/logger_util.dart';
import '../../../infrastructure/utils/utilities.dart';
import '../../services/shared_preferences_service.dart';
import 'api_response.dart';

class ApiWrapper {
  final JsonDecoder _decoder = const JsonDecoder();

  Future<ApiResponse?> postApiWithoutToken({required String url, required dynamic param}) async {
    final String urlString = '${ApiEndpoints.baseUrl}$url';

    debugPrint('URL $urlString');

    // Step 2: Check active internet access
    if (!await Utilities.isInternetAvailable()) {
      LogUtil.logError('No active internet connection');
      return null; // No active internet connection
    }

    // Step 3: Make the API call if internet is available
    try {
      final sanitizedParam = sanitizeParam(param);

      final http.Response response = await http.post(
        Uri.parse(urlString),
        body: jsonEncode(sanitizedParam),
        headers: <String, String>{'Content-Type': 'application/json'},
      );

      // Log and decode response

      final dynamic data = jsonDecode(response.body);
      LogUtil.logDebug('DATA ${data.toString()}');

      LogUtil.logTrace(
        'postApiWithoutToken hit URL: $url \nsuccess: ${data['success']} \nmessage: ${data['message']} \ndata: ${data['data']}',
      );

      return ApiResponse.fromJson(data);
    } catch (e) {
      // Handle network or parsing errors
      LogUtil.logError('Error in postApiWithoutToken: $e');
      return null;
    }
  }

  Future<ApiResponse?> postApi({required String url, dynamic param}) async {
    try {
      final String? authKey = SharedPreferencesService.getString(SharedPrefKeys.authToken);

      final String urlString = '${ApiEndpoints.baseUrl}$url';

      // Step 2: Verify active internet access
      if (!await Utilities.isInternetAvailable()) {
        LogUtil.logError('No active internet connection.');
        return null; // No active internet connection
      }

      // Step 3: Perform HTTP POST request
      final http.Response response = await http.post(
        Uri.parse(urlString),
        // body: jsonEncode(param),
        body: param != null ? jsonEncode(param) : null,
        headers: <String, String>{
          'Authorization': 'Bearer ${authKey ?? ""}',
          'Content-Type': 'application/json',
        },
      ); // Add timeout to avoid long hangs

      // Step 4: Log and parse the response
      LogUtil.logInfo('URL $url Response postApi: ${response.body}');
      final Map<String, dynamic> data = _decoder.convert(response.body) as Map<String, dynamic>;

      // if (response.statusCode == 401) {
      //   ForceLogoutDialog.show();
      //   return null;
      // }

      return ApiResponse.fromJson(data);
    } catch (e) {
      // Log exceptions and return null
      LogUtil.logError('Error in postApi: $e');
      return null;
    }
  }

  Future<ApiResponse?> getApi({required String url}) async {
    try {
      final String? authKey = SharedPreferencesService.getString(SharedPrefKeys.authToken);

      final String urlString = '${ApiEndpoints.baseUrl}$url';

      // Step 2: Verify active internet access
      if (!await Utilities.isInternetAvailable()) {
        LogUtil.logError('No active internet connection.');
        return null;
      }

      // Step 3: Perform HTTP GET request
      final http.Response response = await http.get(
        Uri.parse(urlString),
        headers: <String, String>{
          'Authorization': 'Bearer ${authKey ?? ""}',
          'Content-Type': 'application/json',
        },
      );

      // Step 4: Log and parse the response
      LogUtil.logInfo('URL $url Response getApi: ${response.body}');
      final Map<String, dynamic> data = _decoder.convert(response.body) as Map<String, dynamic>;

      // if (response.statusCode == 401) {
      //   ForceLogoutDialog.show();
      //   return null;
      // }

      return ApiResponse.fromJson(data);
    } catch (e) {
      LogUtil.logError('Error in getApi: $e');
      return null;
    }
  }

  Future<ApiResponse?> putApi({required String url, dynamic param}) async {
    try {
      final String? authKey = SharedPreferencesService.getString(SharedPrefKeys.authToken);

      final String urlString = '${ApiEndpoints.baseUrl}$url';

      log('PUT URL: $urlString');

      // Step 1: Check for internet connectivity
      if (!await Utilities.isInternetAvailable()) {
        LogUtil.logError('No active internet connection.');
        return null;
      }

      // Step 2: Perform HTTP PUT request
      final http.Response response = await http.put(
        Uri.parse(urlString),
        body: param != null ? jsonEncode(param) : null,
        headers: <String, String>{
          'Authorization': 'Bearer ${authKey ?? ""}',
          'Content-Type': 'application/json',
        },
      );

      // Step 3: Log and parse the response
      LogUtil.logInfo('URL $url Response putApi: ${response.body}');
      final Map<String, dynamic> data = _decoder.convert(response.body) as Map<String, dynamic>;

      // if (response.statusCode == 401) {
      //   ForceLogoutDialog.show();
      //   return null;
      // }
      return ApiResponse.fromJson(data);
    } catch (e) {
      // Step 4: Log any errors
      LogUtil.logError('Error in putApi: $e');
      return null;
    }
  }

  Future<ApiResponse?> deleteApi({required String url}) async {
    try {
      final String? authKey = SharedPreferencesService.getString(SharedPrefKeys.authToken);

      final String urlString = '${ApiEndpoints.baseUrl}$url';

      // Step 1: Check for internet connectivity
      if (!await Utilities.isInternetAvailable()) {
        LogUtil.logError('No active internet connection.');
        return null;
      }

      // Step 2: Perform HTTP DELETE request
      final http.Response response = await http.delete(
        Uri.parse(urlString),
        headers: <String, String>{
          'Authorization': 'Bearer ${authKey ?? ""}',
          'Content-Type': 'application/json',
        },
      );

      // Step 3: Log and parse the response
      LogUtil.logInfo('URL $url Response deleteApi: ${response.body}');
      final Map<String, dynamic> data = _decoder.convert(response.body) as Map<String, dynamic>;

      // if (response.statusCode == 401) {
      //   ForceLogoutDialog.show();
      //   return null;
      // }

      return ApiResponse.fromJson(data);
    } catch (e) {
      // Step 4: Log any errors
      LogUtil.logError('Error in deleteApi: $e');
      return null;
    }
  }

  dynamic sanitizeParam(dynamic input) {
    if (input is Set) {
      return input.toList(); // Convert Set to List
    } else if (input is Map) {
      // Recursively sanitize Map values
      return input.map((dynamic key, dynamic value) => MapEntry(key, sanitizeParam(value)));
    } else if (input is List) {
      // Recursively sanitize List elements
      return input.map(sanitizeParam).toList();
    }
    return input; // Return value as is if it's already encodable
  }
}
