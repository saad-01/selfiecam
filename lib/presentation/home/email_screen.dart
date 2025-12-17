import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:selfiecam1/infrastructure/navigation/routes.dart';
import 'package:selfiecam1/presentation/component/button_component1.dart';
import 'package:selfiecam1/presentation/component/textfield_component.dart';
import '../../infrastructure/constants/app_assets.dart';

class Email extends StatelessWidget {
  const Email({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(AppAssets.background3, fit: BoxFit.fill),
          ),

          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextfieldComponent(hintText: 'Full Name'),
                    Gap(2.h),
                    TextfieldComponent(hintText: 'ENTER YOUR @ EMAIL'),
                    Gap(1.5.h),

                    /// Checkbox Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: false,
                          onChanged: (val) {},
                          activeColor: Colors.white,
                          checkColor: Colors.black,
                        ),
                        Expanded(
                          child: Text(
                            'I AGREE TO RECEIVE EMAILS FROM THIS BRAND.',
                            style: textTheme.headlineMedium!.copyWith(
                              color: Colors.white,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ],
                    ),

                    Gap(4.h),
                    _buildAddEmailButton(),
                    Gap(6.h),

                    /// Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconButton(
                          color: const Color(0xffFF0000),
                          icon: Icons.close,
                          iconColor: Colors.white,
                          borderRadius: 100,
                          containerHeight: 9.h,
                          containerWidth: 16.w,
                          onPressed: () {},
                        ),
                        Gap(5.w),
                        CustomIconButton(
                          color: const Color(0xff00C846),
                          icon: Icons.arrow_forward,
                          iconColor: Colors.white,
                          containerHeight: 9.h,
                          containerWidth: 16.w,
                          borderRadius: 100,
                          onPressed: () {
                            Get.toNamed(Routes.PHONE);
                          },
                        ),
                      ],
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

  /// ADD EMAIL button
  Widget _buildAddEmailButton() {
    return Column(
      children: [
        Container(
          width: 7.h,
          height: 7.h,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 0.4.h),
          ),
          child: Icon(Icons.add, color: Colors.black, size: 4.h),
        ),
        Gap(0.8.h),
        Text(
          'ADD EMAIL',
          style: TextStyle(
            fontFamily: 'Bebas',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
