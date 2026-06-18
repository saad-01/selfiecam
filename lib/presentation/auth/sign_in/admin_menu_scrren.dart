import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:selfiecam1/infrastructure/utils/custom_snackbar.dart';
import 'package:selfiecam1/infrastructure/utils/pref_utils.dart';
import 'package:selfiecam1/presentation/component/back_button.dart';
import 'package:sizer/sizer.dart';
import '../../../controller/admin_menu_controller.dart';
import '../../../infrastructure/constants/app_assets.dart';
import '../../../infrastructure/navigation/routes.dart';
import '../../component/button_component.dart';
import '../../component/textfield_component.dart';

class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  final controller = Get.put(AdminMenuController());
  bool _isImagePrecached = false;
  Timer? _popupTimer;
  var counter = 30.obs;
  var password = PrefUtils().getString("password") ?? "";
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _popupTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (counter.value == 1) {
          Get.back();
        } else {
          counter.value--;
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _popupTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
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
            Positioned(top: 40, left: 20, child: CustomBackButton()),
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: 100.h),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 20.h,
                      child: Center(
                        child: Image.asset(AppAssets.logo1, width: 60.w, fit: BoxFit.contain),
                      ),
                    ),

                    Column(
                      children: [
                        Text('ADMIN MENU', style: textTheme.displayLarge!.copyWith(fontSize: 90)),

                        SizedBox(height: 3.h),

                        TextfieldComponent(hintText: 'PASSWORD', isObscure: true, controller: controller.pinController),

                        SizedBox(height: 3.h),

                        ButtonComponent(
                          text: 'UNLOCK',
                          borderRadius: 0.0,
                          onPressed: () {
                            // Get.offNamed(Routes.EXPERIENCESELECTION1);

                            if (controller.pinController.text.trim() == password) {
                              FocusScope.of(context).unfocus();
                              Get.offNamed(Routes.SETTINGS);
                            } else {
                              CustomSnackbar.showError('Invalid PIN');
                            }
                          },
                        ),
                      ],
                    ),

                    Image.asset(AppAssets.logo2, width: 355, height: 210, fit: BoxFit.contain),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 30,
              child: Container(
                height: 70,
                width: 70,
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: Colors.white, width: 10),
                ),
                child: Obx(() => Center(child: Text('${counter.value}', style: textTheme.labelMedium))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
