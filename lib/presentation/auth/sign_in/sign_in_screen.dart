import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:get/route_manager.dart';
import 'package:selfiecam1/infrastructure/constants/app_assets.dart';
import 'package:selfiecam1/infrastructure/navigation/routes.dart';
import 'package:selfiecam1/presentation/component/button_component.dart';
import 'package:selfiecam1/presentation/component/textfield_component.dart';
import 'controller/sign_in_controller.dart';

class SignInScreen extends GetView<SignInController> {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
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
            child: IntrinsicHeight(
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: SizedBox(
                        width: Get.width * 0.6,
                        height: Get.height * 0.3,
                        child: Image.asset(
                          AppAssets.logo1,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: SizedBox(
                        width: Get.width * 0.75,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Text(
                                'LOGIN',
                                style: textTheme.displayLarge,
                              ),
                            ),

                            const Gap(20),
                            TextfieldComponent(hintText: 'ACCOUNT EMAIL'),
                            const Gap(15),
                            TextfieldComponent(
                              hintText: 'PASSWORD',
                              isObscure: true,
                            ),
                            const Gap(15),

                            Center(
                              child: Text(
                                'Forgot user or password?',
                                style: textTheme.labelMedium,
                              ),
                            ),

                            const Gap(25),
                            ButtonComponent(
                              text: 'GO',
                              onPressed: () {
                                Get.toNamed(Routes.AUTHMENU);
                              },
                            ),
                            const Gap(50),
                            const Divider(color: Colors.white, thickness: 2),
                            const Gap(50),

                            Center(
                              child: Text(
                                'NEW? JOIN FOR FREE',
                                style: textTheme.labelLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // ...
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: SizedBox(
                        width: Get.width * 0.6,
                        height: Get.width * 0.1,
                        child: Image.asset(
                          AppAssets.logo2,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
