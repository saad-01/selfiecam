import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:get/route_manager.dart';
import 'controller/admin_menu_controller.dart';
import '../../../infrastructure/constants/app_assets.dart';
import '../../../infrastructure/navigation/routes.dart';
import '../../component/button_component.dart';
import '../../component/textfield_component.dart';

class AdminMenuScrren extends GetView<AdminMenuController> {
  const AdminMenuScrren({super.key});

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
                                'ADMIN MENU',
                                style: textTheme.displayLarge,
                              ),
                            ),

                            const Gap(20),
                            TextfieldComponent(
                              hintText: 'PIN',
                              isObscure: true,
                            ),

                            const Gap(25),
                            ButtonComponent(
                              text: 'UNLOCK',
                              onPressed: () {
                                Get.toNamed(Routes.EXPERIENCESELECTION1);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 2,
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
