import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as G;
import 'package:get/get.dart' hide FormData;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../constants/api_endpoints.dart';
import 'loader.dart';
import 'logger.dart';
import 'pref_utils.dart';
import 'response_model.dart';

class ApiCalls {
  // static final DioClient _dioClient = DioClient();
  static late Dio dioClient;
  // static Dio dioClient = Dio(
  //     BaseOptions(baseUrl: ApiUrls.baseUrl, connectTimeout: Duration(seconds: 100), receiveTimeout: Duration(seconds: 100)));
  // ..interceptors.add(SSLPinningInterceptor.fromCertFiles([File("assets/certificate.pem")]));
  static Future<void> initialize() async {
    // Load the certificate as bytes from the asset bundle

    // Set up the Dio instance with SSL pinning
    dioClient = Dio();
  }

  static Options getAuth(bool isAuth, {bool eventJoined = false}) {
    //  'Co-RelationID': AccountService.getCorelationID()
    return eventJoined
        ? isAuth
              ? Options(
                  headers: {
                    "Content-Type": "application/json",
                    'Authorization': 'Bearer ${PrefUtils().getString("deviceToken")}',
                    'x-auth-event': '${PrefUtils().getString("eventToken")}',
                    "x-app-secret": "e7053b3b07076b7e9949faa0c6978697721b0995",
                  },
                )
              : Options()
        : isAuth
        ? Options(
            headers: {
              "Content-Type": "application/json",
              'Authorization': 'Bearer ${PrefUtils().getString("deviceToken")}',
              "x-app-secret": "e7053b3b07076b7e9949faa0c6978697721b0995",
            },
          )
        : Options(headers: {"Content-Type": "application/json", "x-app-secret": "e7053b3b07076b7e9949faa0c6978697721b0995"});
  }

  ///
  ///Url : pass end point without base url
  ///isAuth : pass false if you want to call post API without auth token true is set as defualt
  ///
  static Future<ResponseModel> getAPICall({required String url, bool isAuth = true, bool showError = true, bool eventJoined = false}) async {
    // addInterceptor(isAuth: isAuth);
    try {
      log('this is my userToken ${PrefUtils().getUserToken()}');
      Logger.log("This is my Token: ${PrefUtils().getUserToken()}");
      Logger.log("API URL: ${ApiUrls.baseUrl + url}");
      var options = getAuth(isAuth, eventJoined: eventJoined);
      Logger.log("Request Headers: ${options.headers}");
      final response = await dioClient.get(ApiUrls.baseUrl + url, options: options);
      if (response.statusCode == 200) {
        Logger.log("Response: ${jsonEncode(response.data)}");
        return ResponseModel(statusCode: 200, data: response.data);
      } else {
        return ResponseModel(statusCode: response.statusCode ?? -1, data: response.data);
      }
      // return response.data;
    } on DioException catch (error) {
      Logger.log("Error: ${error.response?.data}");
      return handleErrorResponses(error, isShowError: showError);
    } catch (error) {
      return ResponseModel(statusCode: -1, data: error.toString());
    }
  }

  ///
  ///Url : pass end point without base url
  ///bodyParams : pass body params
  ///isAuth : pass false if you want to call post API without auth token true is set as defualt
  ///
  static Future<ResponseModel> multipartRequest() {
    return Future.value(ResponseModel(statusCode: 200, data: ''));
  }

  static Future putAPICall({
    required String url,
    required dynamic bodyParams,
    bool isShowError = true,
    bool isAuth = true,
  }) async {
    Logger.log('toke ${PrefUtils().getUserToken()}');
    Logger.log("API URL: ${ApiUrls.baseUrl + url}");

    try {
      final response = await dioClient.put(ApiUrls.baseUrl + url, data: bodyParams, options: getAuth(isAuth));
      Logger.log("Status Code: ${response.statusCode}");
      Logger.log("Response: ${response.data}");
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        return ResponseModel(data: response.data, statusCode: 200);
      } else if (response.statusCode == 400) {
        showCustomDialog();
      } else if (response.statusCode == 400) {
        showCustomDialog();
        return ResponseModel(data: response.data, statusCode: 400);
      } else if (response.statusCode == 501) {
        return ResponseModel(data: response.data, statusCode: 501);
      } else {
        return ResponseModel(data: response.data, statusCode: -1);
      }
      return response.data;
    } on DioException catch (error, stackTrace) {
      Logger.log("Error: ${error.response?.data}");
      Logger.log("Stack Trace: $stackTrace");
      return handleErrorResponses(error, isShowError: isShowError);
    } catch (error) {
      return ResponseModel(statusCode: -1, data: error.toString());
    }
  }

  // static Future<ResponseModel> PutApiCallWithoutBodyParams({
  //     required String url,
  //     bool isAuth = true,
  //   }) async {
  //     Logger.log('token ${PrefUtils().getUserToken()}');
  //     try {
  //       final response = await dioClient.put(
  //         ApiUrls.baseUrl + url,
  //         options: isAuth
  //             ? Options(headers: {
  //                 'Content-Type': 'application/json',
  //                 'Authorization': 'Bearer ${PrefUtils().getUserToken()}'
  //               })
  //             : null,
  //       );
  //       Logger.log("Status Code: ${response.statusCode}");
  //       Logger.log("Response: ${response.data}");

  //       if (response.statusCode == 200 ||
  //           response.statusCode == 201 ||
  //           response.statusCode == 204) {
  //         return ResponseModel(
  //             data: response.data, statusCode: 200);
  //       } else if (response.statusCode == 400) {
  //         showCustomDialog();
  //       } else {
  //         return ResponseModel(data: response.data, statusCode: -1);
  //       }
  //       return ResponseModel(
  //           data: response.data, statusCode: 400);
  //     } on DioException catch (error) {
  //       Logger.log("Error: ${error.response?.data}");
  //       return handleErrorResponses(error);
  //     } catch (error) {
  //       return ResponseModel(statusCode: -1, data: error.toString());
  //     }
  //   }

  // static Future DELETEAPICall({required String url ,bool isAuth = true }) async {
  //   try{
  //   final response = await dioClient.put(ApiUrls.baseUrl + url,
  //       options: isAuth
  //           ? Options(headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer ${PrefUtils().getUserToken()}'
  //       })
  //           : null);
  //   Logger.log("Status Code: ${response.statusCode}");
  //   Logger.log("Response: ${response.data}");
  //   if (response.statusCode == 200 ||
  //       response.statusCode == 201 ||
  //       response.statusCode == 204) {
  //     return ResponseModel(data: response.data, statusCode: 200);
  //   } else
  //   if (response.statusCode == 400) {
  //     showCustomDialog();
  //   } else if (response.statusCode == 400) {
  //     showCustomDialog();
  //     return ResponseModel(data: response.data, statusCode: 400);
  //   } else {
  //     return ResponseModel(data: response.data, statusCode: -1);
  //   }
  //   return response.data;
  // } on DioException catch (error) {
  // Logger.log("Error: ${error.response?.data}");
  // return handleErrorResponses(error);
  // } catch (error) {
  // return ResponseModel(statusCode: -1, data: error.toString());
  // }
  // }

  ///
  ///Url : pass end point without base url
  ///bodyParams : pass body params
  ///isAuth : pass false if you want to call post API without auth token true is set as defualt
  ///
  static Future<ResponseModel> postAPICall({
    required String url,
    required dynamic bodyParams,
    bool isAuth = true,
    bool isShowError = true,
    bool eventJoined = false,
  }) async {
    Logger.log("API URL: ${ApiUrls.baseUrl + url}");

    try {
      try {
        Logger.log(jsonEncode(bodyParams));
      } catch (e) {
        Logger.log(bodyParams);
      }
      if (isAuth) {
        Logger.log('Bearer ${PrefUtils().getUserToken()}');
      }
      Logger.log("header: ${getAuth(isAuth, eventJoined: eventJoined).headers}");
      final response = await dioClient.post(
        ApiUrls.baseUrl + url,
        data: bodyParams,
        options: getAuth(isAuth, eventJoined: eventJoined),
      );
      Logger.log("Status Code: ${response.statusCode}");

      Logger.log("Response: ${response.data}");
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        return ResponseModel(data: response.data, statusCode: 200);
      } else if (response.statusCode == 400) {
        showCustomDialog();
        return ResponseModel(data: response.data, statusCode: 400);
      } else if (response.statusCode == 403) {
        return ResponseModel(data: response.data, statusCode: 403);
      } else if (response.statusCode == 409) {
        return ResponseModel(data: response.data, statusCode: 409);
      } else {
        return ResponseModel(data: response.data, statusCode: -1);
      }
    } on DioException catch (error) {
      if (error.error is TlsException) {
        // Recieved certificate is different from trusted certificates
        Logger.log("Error: ${error.error}");
      }
      Logger.log("Error: ${error.response?.data}");
      return handleErrorResponses(error, isShowError: isShowError);
    } catch (error) {
      return ResponseModel(statusCode: -1, data: error.toString());
    }
  }

  // static addInterceptor({bool isAuth = true}) {
  //   dioClient.interceptors.add(
  //     InterceptorsWrapper(
  //       onRequest: (options, handler) {
  //         // Add the access token to the request header
  //         if (isAuth) {
  //           options.headers['Authorization'] = 'Bearer ${PrefUtils().getUserToken()}';
  //         }
  //         return handler.next(options);
  //       },
  //       onError: (DioException e, handler) async {
  //         if (e.response?.statusCode == 401) {
  //           // If a 401 response is received, refresh the access token
  //           String newAccessToken = await refreshToken();
  //           //Handle expcetion
  //           if (newAccessToken == "") {
  //             return handler.reject(e);
  //           }

  //           // Update the request header with the new access token
  //           e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

  //           // Repeat the request with the updated header
  //           return handler.resolve(await dioClient.fetch(e.requestOptions));
  //         }
  //         return handler.next(e);
  //       },
  //     ),
  //   );
  // }

  static Timer? timer;
  static bool isTimerRunning = false;
  // static refreshTokenProdicaly() {
  //   if (isTimerRunning) return;
  //   isTimerRunning = true;
  //   Logger.log("Timer Started Running");
  //   timer = Timer.periodic(Duration(minutes: 14), (timer) async {
  //     String newAccessToken = await refreshToken();
  //     if (newAccessToken == "") {
  //       isTimerRunning = false;
  //       timer.cancel();
  //     }
  //   });
  // }

  // static refreshTokenManualy() async {
  //   await refreshToken();
  // }

  static stopTimer() {
    if (timer != null) {
      timer!.cancel();
    }
  }

  // static refreshToken() async {
  //   // Implement the logic to refresh the access token
  //   Logger.log("Called This on Token Expired");
  //   var headers = {'Accept': 'application/json'};
  //   Logger.log(PrefUtils().getUserRefreshToken());
  //   Logger.log(PrefUtils().getUserToken());
  //   var data = PrefUtils().getUserRefreshToken();
  //   Logger.log("Called This on Token Expired $data");
  //   var response = await dioClient.request(
  //     '${ApiUrls.baseUrl}${ApiUrls.refreshToken}?refresh_token=$data',
  //     options: Options(method: 'POST', headers: headers),
  //   );

  //   if (response.statusCode == 200) {
  //     Logger.log("Token Refreshed Successfully");
  //     PrefUtils().setUserToken(response.data['access_token'], response.data['refresh_token']);
  //     return response.data['access_token'];
  //   } else {
  //     return "";
  //   }
  //   // if (response.statusCode == 200) {
  //   //   PrefUtils().setUserToken(
  //   //       response.data['accessToken'], response.data['refreshToken']);
  //   //   return response.data['accessToken'];
  //   // } else {
  //   //   return "";
  //   // }
  // }

  static Future<ResponseModel> postAPICallWithFormData({required String url, required FormData formData}) async {
    try {
      final response = await dioClient.post(ApiUrls.baseUrl + url, data: formData);

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        return ResponseModel(statusCode: 200, data: response.data);
      } else if (response.statusCode == 400) {
        showCustomDialog();
        return ResponseModel(statusCode: 400, data: response.data);
      }
      return response.data;
    } on DioException catch (error) {
      return handleErrorResponses(error);
    } catch (error) {
      rethrow;
    }
  }

  static Future deleteAPICall({
    required String url,
    bool isAuth = true,
    bool isShowError = true,
    required dynamic bodyParams,
  }) async {
    Logger.log("API URL: ${ApiUrls.baseUrl + url}");

    try {
      final response = await dioClient.delete(ApiUrls.baseUrl + url, data: bodyParams, options: getAuth(isAuth));
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        return ResponseModel(data: response.data, statusCode: 200);
      } else if (response.statusCode == 400) {
        showCustomDialog();
        return ResponseModel(data: response.data, statusCode: 400);
      } else if (response.statusCode == 409) {
        showCustomDialog();
        return ResponseModel(data: response.data, statusCode: 409);
      } else if (response.statusCode == 501) {
        // showCustomDialog();
        return ResponseModel(data: response.data, statusCode: 501);
      } else {
        return ResponseModel(data: response.data, statusCode: -1);
      }
    } on DioException catch (error) {
      Logger.log("Error: ${error.response?.data}");
      return handleErrorResponses(error, isShowError: isShowError);
    } catch (error) {
      // Logger.log("data: ")
      return ResponseModel(statusCode: -1, data: error.toString());
    }
  }

  static Future patchAPICall({required String url, required dynamic bodyParams, bool? fromEditProfile}) async {
    try {
      final response = await dioClient.patch(url, data: bodyParams);
      Logger.log("Status Code: ${response.statusCode}");
      Logger.log("Response: ${response.data}");
      if (response.statusCode == 400) {
        showCustomDialog();
      }
      if (response.statusCode == 200) {
        final loader = Get.find<LoaderService>();
        loader.hide();
        if (fromEditProfile == true) {
          await PrefUtils().setUserDetails(jsonEncode(response.data));
          Logger.log('msg_profile_updated');
        }

        return response.data;
      }
      return response.data;
    } on DioException catch (error) {
      return handleErrorResponses(error);
    } catch (error) {
      rethrow;
    }
  }

  static Future<ResponseModel> handleErrorResponses(DioException error, {bool? fromEditProfile, bool isShowError = true}) async {
    try {
      final loader = Get.find<LoaderService>();
      loader.hide();
    } catch (e) {}

    if (error.response?.statusCode == 401) {
      //Logger.log(error.response?.data?['message'] ?? '');

      return ResponseModel(statusCode: 401, data: error.response?.data['message']);
    } else if (error.response?.statusCode == 403) {
      return ResponseModel(statusCode: 403, data: error.response?.data['message']);
    } else if (error.response?.statusCode == 400) {
      // G.CustomSnackbar.showError( error.response?.data?['errors'][0]??'');
      if (isShowError) Logger.log(error.response?.data['message'] ?? '');

      return ResponseModel(statusCode: 400, data: error.response?.data['message'] ?? '');
    } else if (error.response?.statusCode == 500) {
      if (isShowError) Logger.log(error.response?.data['message'] ?? error.response?.data);
      Logger.log("status code: ${error.response}");
      return ResponseModel(statusCode: 500, data: error.response?.data);
    } else if (error.response?.statusCode == 501) {
      Logger.log("status code: ${error.response}");
      if (isShowError) Logger.log(error.response?.data['message']);

      return ResponseModel(statusCode: 501, data: error.response?.data['message']);
    } else if (error.response?.statusCode == 502) {
      if (isShowError) Logger.log(error.response?.data['message']);

      Logger.log("status code: ${error.response}");
      return ResponseModel(statusCode: 502, data: error.response?.data['message']);
    } else if (error.response?.statusCode == 404) {
      if (isShowError) Logger.log(error.response?.data['message'] ?? '');
      return ResponseModel(statusCode: -1, data: error.response?.data['message'] ?? '');
      // throw ApiResponseException(error.response?.data?['errors'][0] ?? '');
    } else if (error.response?.statusCode == 409) {
      if (isShowError) {
        if (error.response?.data?['message'] == "You can't leave the circle. You have bills that you haven't settled.") {
        } else {
          Logger.log(error.response?.data?['message'] ?? '');
        }
      }

      return ResponseModel(statusCode: 409, data: error.response?.data?['message'] ?? '');
    } else if (error.response?.statusCode == 413) {
      if (isShowError) Logger.log((error.response?.data ?? "").toString());

      return ResponseModel(statusCode: -1, data: error.response?.data?['message'] ?? '');
    } else if (error.response?.statusCode == 422) {
      if (isShowError) Logger.log(error.response?.data?['message'] ?? '');
      return ResponseModel(statusCode: -1, data: error.response?.data['detail'] ?? '');
    } else {
      if (isShowError) Logger.log("msg_something_wrong");
      return ResponseModel(statusCode: -1, data: error.response?.data ?? "");
    }
  }

  static Future<dynamic> downloadFile({required String downLoadFileUrl}) async {
    try {
      String dir = "";
      if (Platform.isAndroid) {
        dir = "/storage/emulated/0/Download";
      } else if (Platform.isIOS) {
        dir = (await getApplicationDocumentsDirectory()).path;
      }
      final String uniqueFilename = DateTime.now().millisecondsSinceEpoch.toString();
      final fileExtension = getFileExtensionFromUrl(downLoadFileUrl);
      String locationPath = "$dir/myipr_file_$uniqueFilename.$fileExtension";
      Logger.log('location: $locationPath');
      Dio dio = Dio();
      await dio.download(downLoadFileUrl, locationPath);
      Logger.log('filepath: $downLoadFileUrl');
      return locationPath;
    } on DioException catch (error) {
      return handleErrorResponses(error);
    } catch (error) {
      rethrow;
    }
  }

  static String getFileExtensionFromUrl(String fileUrl) {
    final Uri uri = Uri.parse(fileUrl);
    final String path = uri.path;
    final String extension = p.extension(path);
    return extension.isNotEmpty ? extension.substring(1) : '';
  }

  static void showCustomDialog() {
    G.Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // This makes the dialog rectangular
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Session Expired", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              SizedBox(height: 16),
              Text("Your session has expired. Please login again."),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 8.0, right: 30, bottom: 8.0, left: 30),
                      child: ElevatedButton(
                        onPressed: () {
                          // G.Get.offAll(LoginScreen());
                          // Button 2 action
                          Logger.log("Button 2 pressed");
                        },
                        child: Text('Login Again', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false, // Set to true if you want the dialog to be dismissible by tapping outside of it.
    );
  }
}
