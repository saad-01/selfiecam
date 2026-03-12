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
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
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
                        Text('ADMIN MENU', style: textTheme.displayLarge),

                        SizedBox(height: 3.h),

                        TextfieldComponent(hintText: 'PIN', isObscure: true, controller: controller.pinController),

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

                    Padding(
                      padding: EdgeInsets.only(bottom: 3.h),
                      child: Image.asset(AppAssets.logo2, width: 55.w, height: 10.h, fit: BoxFit.contain),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
