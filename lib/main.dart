import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:selfiecam1/infrastructure/theme/theme.dart';
import 'infrastructure/navigation/navigation.dart';
import 'infrastructure/navigation/routes.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: Routes.SIGNIN,
      getPages: Nav.routes,
    );
  }
}
