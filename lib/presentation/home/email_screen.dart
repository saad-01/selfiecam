import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:selfiecam1/infrastructure/navigation/routes.dart';
import 'package:selfiecam1/presentation/component/button_component1.dart';
import 'package:selfiecam1/presentation/component/textfield_component.dart';
import 'dart:ui';

import '../../infrastructure/constants/app_assets.dart' show AppAssets;

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
              padding: const EdgeInsets.symmetric(horizontal: 150),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: <Widget>[
                    TextfieldComponent(hintText: 'Full Name'),
                    Gap(20),
                    TextfieldComponent(hintText: 'ENTER YOUR @ EMAIL'),
                    Gap(10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: false,
                          onChanged: (val) {},
                          activeColor: Colors.white,
                          checkColor: Colors.black,
                        ),
                        Text(
                          'I AGREE TO RECEIVE EMAILS FROM THIS BRAND.',
                          style: textTheme.headlineMedium!.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    Gap(30),

                    _buildAddEmailButton(),
                    Gap(60),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconButton(
                          containerHeight: 100,
                          containerWidth: 100,
                          color: Color(0xffFF0000),
                          icon: Icons.close,
                          iconColor: Colors.white,
                          iconSize: 40,
                          borderRadius: 100,
                          onPressed: () {},
                        ),
                        Gap(30),
                        CustomIconButton(
                          containerHeight: 100,
                          containerWidth: 100,
                          color: Color(0xff00C846),
                          icon: Icons.arrow_forward,
                          iconColor: Colors.white,
                          iconSize: 40,
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

  Widget _buildAddEmailButton() {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: const Icon(Icons.add, color: Colors.black, size: 30),
        ),
        const SizedBox(height: 5),
        const Text(
          'ADD EMAIL',
          style: TextStyle(
            fontFamily: 'Bebas',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCircleButton(Color(0xffFF0000), Icons.close),
        Gap(20),
        _buildCircleButton(Color(0xff00C846), Icons.arrow_forward),
      ],
    );
  }

  Widget _buildCircleButton(Color color, IconData icon) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 40),
    );
  }
}
