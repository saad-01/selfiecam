import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:selfiecam1/infrastructure/constants/app_assets.dart';
import 'package:selfiecam1/infrastructure/navigation/routes.dart';
import 'package:selfiecam1/presentation/component/button_component.dart';
import 'package:selfiecam1/presentation/component/textfield_component.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sizer/sizer.dart';
import '../../../controller/sign_in_controller.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final controller = Get.put(SignInController());
  bool _isImagePrecached = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isImagePrecached) {
      precacheImage(AssetImage(AppAssets.background1), context);
      precacheImage(AssetImage(AppAssets.logo2), context);
      precacheImage(AssetImage(AppAssets.logo1), context);
      _isImagePrecached = true;
    }
  }

  @override
  void initState() {
    super.initState();

    unawaited(controller.loadAllInfo());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Stack(
          children: [
            /// Background
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
                child: FadeInImage(
                  placeholder: AssetImage(AppAssets.background1), // same image
                  image: AssetImage(AppAssets.background1),
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 150),
                ),
              ),
            ),

            /// Content
            SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 100.h, // 🔥 full screen height
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Top Logo
                      SizedBox(
                        height: 18.h,
                        child: Center(
                          child: Image.asset(AppAssets.logo1, width: 60.w, fit: BoxFit.contain),
                        ),
                      ),

                      /// Center Form
                      Column(
                        children: [
                          Text('LOGIN', style: textTheme.displayLarge),

                          SizedBox(height: 3.h),

                          TextfieldComponent(hintText: 'ACCOUNT EMAIL', controller: controller.emailcontroller, keyboardType: TextInputType.emailAddress,),
                          SizedBox(height: 2.h),

                          TextfieldComponent(hintText: 'PASSWORD', isObscure: true, controller: controller.passwordcontroller),
                          SizedBox(height: 2.h),

                          InkWell(
                            onTap: () {
                              Get.toNamed(Routes.FORGETWEBVIEW);
                            },
                            child: Text('Forgot user or password?', style: textTheme.labelMedium),
                          ),

                          SizedBox(height: 2.h),

                          ButtonComponent(
                            text: 'GO',
                            borderRadius: 0.0,
                            onPressed: () async {
                              FocusScope.of(context).unfocus();
                              controller.loginApi();
                            },
                          ),

                          SizedBox(height: 4.h),

                          Divider(color: Colors.white, thickness: 0.3.h),

                          SizedBox(height: 3.h),

                          InkWell(
                            onTap: () {
                              Get.toNamed(Routes.SIGNUP);
                            },
                            child: Text('NEW? JOIN FOR FREE', style: textTheme.labelLarge),
                          ),
                        ],
                      ),

                      /// Bottom Logo
                      Padding(
                        padding: EdgeInsets.only(bottom: 3.h),
                        child: Image.asset(AppAssets.logo2, width: 55.w, height: 10.h, fit: BoxFit.contain),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
