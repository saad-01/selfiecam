import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new/log_redirection_strategy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:selfiecam1/controller/device_controller.dart';
import 'package:selfiecam1/infrastructure/theme/theme.dart';
import 'package:selfiecam1/infrastructure/utils/api_client.dart';
import 'package:selfiecam1/infrastructure/utils/loader.dart';
import 'package:selfiecam1/infrastructure/utils/pref_utils.dart';
import 'package:sizer/sizer.dart';
import 'infrastructure/navigation/navigation.dart';
import 'infrastructure/navigation/routes.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const MyApp());
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/config/.env");
  await PrefUtils().init();
  await ApiCalls.initialize();
  await Get.putAsync(() async => LoaderService());
  await Get.putAsync(() async => DeviceController());
  FFmpegKitConfig.setLogRedirectionStrategy(LogRedirectionStrategy.neverPrintLogs);
  await clearTempDirectory();
  // await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

Future<void> clearTempDirectory() async {
  final tempDir = await getTemporaryDirectory();

  if (tempDir.existsSync()) {
    tempDir.listSync().forEach((file) {
      if (file is File) {
        file.deleteSync();
      } else if (file is Directory) {
        file.deleteSync(recursive: true);
      }
    });
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String get token => PrefUtils().getUserToken();

  @override
  Widget build(BuildContext context) {
    // Get.put(AppInitController(), permanent: true);
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: appTheme,
          initialRoute:
              // Routes.JOINEVENT,
              Routes.SPLASH,
          // token.isNotEmpty
          // ? PrefUtils().getString("eventJoined") == "true"
          //       ? Routes.WELCOME1
          //       : Routes.JOINEVENT
          // :
          // Routes.SIGNIN,
          getPages: Nav.routes,
        );
      },
    );
  }
}
