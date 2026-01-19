import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:get/route_manager.dart';
import 'package:sizer/sizer.dart';
import '../../../controller/admin_menu_controller.dart';
import '../../../infrastructure/constants/app_assets.dart';
import '../../../infrastructure/navigation/routes.dart';
import '../../component/button_component.dart';
import '../../component/textfield_component.dart';

class AdminMenuScreen extends GetView<AdminMenuController> {
  const AdminMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.darken,
              ),
              child: Image.asset(AppAssets.background1, fit: BoxFit.cover),
            ),
          ),

          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: 100.h),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 20.h,
                      child: Center(
                        child: Image.asset(
                          AppAssets.logo1,
                          width: 60.w,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    Column(
                      children: [
                        Text('ADMIN MENU', style: textTheme.displayLarge),

                        SizedBox(height: 3.h),

                        TextfieldComponent(hintText: 'PIN', isObscure: true),

                        SizedBox(height: 3.h),

                        ButtonComponent(
                          text: 'UNLOCK',
                          borderRadius: 0.0,
                          onPressed: () {
                            Get.toNamed(Routes.EXPERIENCESELECTION1);
                          },
                        ),
                      ],
                    ),

                    Padding(
                      padding: EdgeInsets.only(bottom: 3.h),
                      child: Image.asset(
                        AppAssets.logo2,
                        width: 55.w,
                        height: 10.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
