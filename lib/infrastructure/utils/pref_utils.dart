//ignore: unused_import
import 'dart:convert';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'logger.dart';

class PrefUtils {
  static EncryptedSharedPreferences? sharedPreferences;
  static EncryptedSharedPreferences? sharedPreferencesEncypt;

  PrefUtils() {
    if (sharedPreferences == null)
      // SharedPreferences.getInstance().then((value) {
      //   sharedPreferences = value;
      // });
      EncryptedSharedPreferences.initialize(dotenv.env['SP_ENCRPT_KEY'] ?? "").then((value) {
        sharedPreferencesEncypt = EncryptedSharedPreferences.getInstance();
        sharedPreferences = sharedPreferencesEncypt;
      });
  }

  static Future<EncryptedSharedPreferences> intializeEncryptSharedPref() async {
    await EncryptedSharedPreferences.initialize(dotenv.env['SP_ENCRPT_KEY'] ?? "");
    return EncryptedSharedPreferences.getInstance();
  }

  /// Initializes the [SharedPreferences] instance and sets it to the
  /// [sharedPreferences] variable.
  ///
  /// This method should be called at the beginning of the application startup to
  /// ensure that [SharedPreferences] is ready to use.
  ///
  /// Throws an exception if there is an error while initializing the instance.
  Future<void> init() async {
    sharedPreferences ??= await intializeEncryptSharedPref();
    sharedPreferencesEncypt ??= await intializeEncryptSharedPref();
    Logger.log('SharedPreference Initialized');
  }

  Future<void> setUserToken(String token, String refreshToken) async {
    // sharedPreferences ??= await intializeEncryptSharedPref();
    try {
      sharedPreferencesEncypt ??= await intializeEncryptSharedPref();
      await sharedPreferencesEncypt!.setString('userToken', token);
      await sharedPreferencesEncypt!.setString('refreshToken', refreshToken);
    } catch (e) {
      Logger.log(e.toString());
    }
    // if (token.isNotEmpty) {
    //   ApiCalls.refreshTokenProdicaly();
    // } else {
    //   ApiCalls.stopTimer();
    // }
  }

  String getUserToken() {
    return sharedPreferencesEncypt!.getString('deviceToken') ?? '';
  }

  String getUserRefreshToken() {
    return sharedPreferencesEncypt!.getString('refreshToken') ?? '';
  }

  Future<void> setUserDetails(String details) async {
    sharedPreferences ??= await intializeEncryptSharedPref();
    await sharedPreferences!.setString('userDetails', details);
  }

  Future<void> setNotificationSettings(String details) async {
    sharedPreferences ??= await intializeEncryptSharedPref();
    await sharedPreferences!.setString('notificationSetting', details);
  }

  Future<void> setSessionExpire(bool value) async {
    sharedPreferences ??= await intializeEncryptSharedPref();
    await sharedPreferences!.setBool('AppSession', value);
  }

  bool getSession() {
    return sharedPreferences!.getBool('AppSession') ?? false;
  }

  Future<void> setMsg(String msg) async {
    sharedPreferences ??= await intializeEncryptSharedPref();
    List<String> stringList = await getMsg() ?? [];
    stringList.add(msg);
    await sharedPreferences!.setStringList('msgList', stringList);
    dynamic list = await sharedPreferences!.getStringList('msgList');
    Logger.log("In bg the messages list from save prefutils: $list");
  }

  Future<void> setMsgListEmpty() async {
    sharedPreferences ??= await intializeEncryptSharedPref();
    List<String> stringList = [];
    await sharedPreferences!.setStringList('msgList', stringList);
  }

  Future<void> setThirdUserDetails(String details) async {
    await sharedPreferences!.setString('thirdUserDetails', details);
  }

  Future<void> isUserLoggedIn(bool value) async {
    sharedPreferences ??= await intializeEncryptSharedPref();
    await sharedPreferences!.setBool('isUserLoggedIn', value);
  }

  bool? getIsUserLoggedIn() {
    return sharedPreferences!.getBool('isUserLoggedIn');
  }

  Future<void> isAppOpened(bool value) async {
    await sharedPreferences!.setBool('isAppOpened', value);
  }

  bool getIsAppOpened() {
    return sharedPreferences!.getBool('isAppOpened') ?? false;
  }

  Future<void> setIsFaceId(bool value) async {
    await sharedPreferences!.setBool('faceIdEnabled', value);
  }

  bool getIsFaceId() {
    return sharedPreferences!.getBool('faceIdEnabled') ?? false;
  }

  getUserDetails() {
    return sharedPreferences!.getString('userDetails');
  }

  getNotificationSettings() {
    return sharedPreferences!.getString('notificationSetting');
  }

  getThirdUserDetails() {
    return sharedPreferences!.getString('thirdUserDetails');
  }

  Future<List<String>?> getMsg() async {
    return sharedPreferences!.getStringList('msgList');
  }

  /// Clears all data from the SharedPreferences instance.
  Future<void> clearPreferencesData() async {
    await sharedPreferences!.clear();
  }

  Future<void> saveString(String key, String value) async {
    sharedPreferences ??= await intializeEncryptSharedPref();
    await sharedPreferences!.setString(key, value);
  }

  String? getString(String key) {
    return sharedPreferences!.getString(key);
  }

  Future<void> clearKey(String key) async {
    await sharedPreferences!.remove(key);
  }

  static Future<void> setLanguage(String languageCode) async {
    await sharedPreferences?.setString('language_code', languageCode);
  }

  static String? getLanguage() {
    return sharedPreferences?.getString('language_code');
  }
}
