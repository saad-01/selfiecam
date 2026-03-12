// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:get/get.dart';
// import 'package:get/get_state_manager/src/simple/get_view.dart';
// import 'package:get/route_manager.dart';
// import 'package:selfiecam1/controller/settings_controller.dart';
// import 'package:selfiecam1/infrastructure/utils/custom_snackbar.dart';
// import 'package:selfiecam1/infrastructure/utils/pref_utils.dart';
// import 'package:selfiecam1/presentation/component/back_button.dart';
// import 'package:selfiecam1/presentation/component/button_component.dart';
// import 'package:selfiecam1/presentation/component/button_component1.dart';
// import 'package:sizer/sizer.dart';
// import '../../../controller/admin_menu_controller.dart';
// import '../../../infrastructure/constants/app_assets.dart';
// import '../../../infrastructure/navigation/routes.dart';

// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   final controller = Get.put(SettingsController());
//   bool _isImagePrecached = false;
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();

//     if (!_isImagePrecached) {
//       precacheImage(AssetImage(AppAssets.background1), context);
//       precacheImage(AssetImage(AppAssets.logo2), context);
//       precacheImage(AssetImage(AppAssets.logo1), context);
//       _isImagePrecached = true;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;

//     return GestureDetector(
//       onTap: () {
//         FocusScope.of(context).unfocus();
//       },
//       child: Scaffold(
//         body: Stack(
//           children: [
//             Positioned.fill(
//               child: ColorFiltered(
//                 colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
//                 child: FadeInImage(
//                   placeholder: AssetImage(AppAssets.background1), // same image
//                   image: AssetImage(AppAssets.background1),
//                   fit: BoxFit.cover,
//                   fadeInDuration: const Duration(milliseconds: 150),
//                 ),
//               ),
//             ),
//             Positioned(top: 40, left: 20, child: CustomBackButton()),
//             ConstrainedBox(
//               constraints: BoxConstraints(minHeight: 100.h),
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 8.w),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     SizedBox(
//                       height: 20.h,
//                       child: Center(
//                         child: Image.asset(AppAssets.logo1, width: 60.w, fit: BoxFit.contain),
//                       ),
//                     ),

//                     Column(
//                       children: [
//                         Text('SELECT EXPERIENCE', style: textTheme.displayLarge),
//                         Text(
//                           'Tap an experience to let users choose',
//                           style: textTheme.displaySmall!.copyWith(color: Colors.white),
//                         ),

//                         SizedBox(height: 3.h),
//                         Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 14.0.w),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             // spacing: 1.w,
//                             children: [
//                               CustomIconButton1(
//                                 containerHeight: 18.h,
//                                 containerWidth: 18.w,
//                                 borderRadius: 0.0,
//                                 color: const Color(0xff500F86),
//                                 icon: AppAssets.selfie,
//                                 iconSize: 6.h,
//                                 label: 'Photo',
//                                 onPressed: () {
//                                   Get.toNamed(Routes.COUNTDOWN);
//                                 },
//                               ),

//                               CustomIconButton1(
//                                 containerHeight: 18.h,
//                                 containerWidth: 18.w,
//                                 borderRadius: 0.0,
//                                 color: const Color(0xff500F86),
//                                 icon: AppAssets.boomerang,
//                                 iconSize: 6.h,
//                                 label: 'Boomerang',
//                                 onPressed: () {
//                                   // Get.toNamed(Routes.WELCOME2);
//                                 },
//                               ),

//                               CustomIconButton1(
//                                 containerHeight: 18.h,
//                                 containerWidth: 18.w,
//                                 borderRadius: 0.0,
//                                 color: const Color(0xff500F86),
//                                 icon: AppAssets.gif,
//                                 iconSize: 6.h,
//                                 label: 'GIF',
//                                 onPressed: () {
//                                   // Get.toNamed(Routes.WELCOME2);
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),
//                         Gap(1.h),
//                         Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 14.0.w),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             // spacing: 1.w,
//                             children: [
//                               CustomIconButton1(
//                                 containerHeight: 18.h,
//                                 containerWidth: 18.w,
//                                 borderRadius: 0.0,
//                                 color: const Color(0xff500F86),
//                                 icon: AppAssets.shoutout,
//                                 iconSize: 6.h,
//                                 label: 'Shoutout',
//                                 onPressed: () {
//                                   // Get.toNamed(Routes.WELCOME2);
//                                 },
//                               ),

//                               CustomIconButton1(
//                                 containerHeight: 18.h,
//                                 containerWidth: 18.w,
//                                 borderRadius: 0.0,
//                                 color: const Color(0xff500F86),
//                                 icon: AppAssets.slowmo,
//                                 iconSize: 6.h,
//                                 label: 'Slowmo',
//                                 onPressed: () {
//                                   // Get.toNamed(Routes.WELCOME2);
//                                 },
//                               ),
//                               CustomIconButton1(
//                                 containerHeight: 18.h,
//                                 containerWidth: 18.w,
//                                 borderRadius: 0.0,
//                                 color: const Color(0xff500F86),
//                                 icon: AppAssets.slowmo,
//                                 iconSize: 6.h,
//                                 label: 'AI Photo',
//                                 onPressed: () {
//                                   // Get.toNamed(Routes.WELCOME2);
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),

//                         SizedBox(height: 3.h),

//                         ButtonComponent(
//                           text: 'UNLOCK',
//                           borderRadius: 0.0,
//                           onPressed: () {
//                             // Get.offNamed(Routes.EXPERIENCESELECTION1);
//                           },
//                         ),
//                       ],
//                     ),

//                     Padding(
//                       padding: EdgeInsets.only(bottom: 3.h),
//                       child: Image.asset(AppAssets.logo2, width: 55.w, height: 10.h, fit: BoxFit.contain),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
