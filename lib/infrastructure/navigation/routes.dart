// ignore_for_file: constant_identifier_names

class Routes {
  static Future<String> get initialRoute async {
    return SIGNIN;
  }

  static const SIGNIN = '/signInScreen';
  static const AUTHMENU = '/adminMenuScreen';
  static const WELCOME1 = '/welcome1Screen';
  static const WELCOME2 = '/welcome2Screen';
  static const EXPERIENCESELECTION1 = '/experienceSelectionScreen1';
  static const EXPERIENCESELECTION2 = '/experienceSelectionScreen2';
  static const COUNTDOWN = '/countdownScreen';
  static const PREVIEW = '/previewScreen';
}
