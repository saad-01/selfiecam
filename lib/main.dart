import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:selfiecam1/controller/device_controller.dart';
import 'package:selfiecam1/infrastructure/theme/theme.dart';
import 'package:selfiecam1/infrastructure/utils/api_client.dart';
import 'package:selfiecam1/infrastructure/utils/loader.dart';
import 'package:selfiecam1/infrastructure/utils/pref_utils.dart';
import 'package:sizer/sizer.dart';
import 'infrastructure/navigation/navigation.dart';
import 'infrastructure/navigation/routes.dart';

void main() async {
  await dotenv.load(fileName: "assets/config/.env");
  await PrefUtils().init();
  await ApiCalls.initialize();
  await Get.putAsync(() async => LoaderService());
  await Get.putAsync(() async => DeviceController());
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
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
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: appTheme,
          initialRoute: 
          token.isNotEmpty
              ? PrefUtils().getString("eventJoined") == "true"
                    ? Routes.WELCOME1
                    : Routes.JOINEVENT
              : 
              Routes.SIGNIN,
          getPages: Nav.routes,
        );
      },
    );
  }
}
