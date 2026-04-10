import 'package:get/get.dart';
import 'package:selfiecam1/infrastructure/navigation/routes.dart';
import 'package:selfiecam1/presentation/auth/sign_in/event_join_screen.dart';
import 'package:selfiecam1/presentation/auth/sign_in/forget_webview.dart';
import 'package:selfiecam1/presentation/auth/sign_in/signup_webview.dart';
import 'package:selfiecam1/presentation/home/countdown_screen.dart';
import 'package:selfiecam1/presentation/home/email_screen.dart';
import 'package:selfiecam1/presentation/home/phone_screen.dart';
import 'package:selfiecam1/presentation/home/preview_approve_screen.dart';
import 'package:selfiecam1/presentation/home/send_it_to_screen.dart';
import 'package:selfiecam1/presentation/home/settings_screen.dart';
import 'package:selfiecam1/presentation/home/splash_screen.dart';
import 'package:selfiecam1/presentation/home/welcome_2_screen.dart';
import '../../presentation/auth/sign_in/admin_menu_scrren.dart';
import '../../presentation/auth/sign_in/sign_in_screen.dart';
import '../../presentation/home/experience_selection_1_screen.dart';
import '../../presentation/home/experiemce_selection_2_screen.dart';
import '../../presentation/home/send_it_to_me_2_screen.dart';
import '../../presentation/home/welcome_1_screen.dart';
import '../bindings/initial_bindings.dart';

class Nav {
  static List<GetPage> routes = [
    GetPage(
      name: Routes.SIGNIN,
      page: () => const SignInScreen(),
      // binding: InitialBindings(),
    ),
    GetPage(
      name: Routes.FORGETWEBVIEW,
      page: () => ForgetWebview(),
      // binding: InitialBindings(),
    ),
    GetPage(
      name: Routes.JOINEVENT,
      page: () => const EventDropdownView(),
      // binding: InitialBindings(),
    ),
    GetPage(
      name: Routes.SIGNUP,
      page: () => SignupWebview(url: "https://hub.selfiecam.ai/auth/register",),
      // binding: InitialBindings(),
    ),
    GetPage(
      name: Routes.AUTHMENU,
      page: () => const AdminMenuScreen(),
      // binding: InitialBindings(),
    ),
    GetPage(
      name: Routes.WELCOME1,
      page: () => const Welcome1Screen(),
      // binding: InitialBindings(),
    ),
    GetPage(
      name: Routes.WELCOME2,
      page: () => const Welcome2Screen(),
      // binding: InitialBindings(),
    ),
    // GetPage(
    //   name: Routes.EXPERIENCESELECTION1,
    //   page: () => const ExperienceSelectionScreen1(),
    //   // binding: InitialBindings(),
    // ),
    GetPage(
      name: Routes.EXPERIENCESELECTION2,
      page: () => const ExperienceSelectionScreen2(),
      // binding: InitialBindings(),
    ),
    // GetPage(
    //   name: Routes.COUNTDOWN,
    //   page: () => const CountdownScreen(),
    //   // binding: InitialBindings(),
    // ),
    // GetPage(
    //   name: Routes.PREVIEW,
    //   page: () => const PreviewApproveScreen(),
    //   // binding: InitialBindings(),
    // ),
    GetPage(
      name: Routes.SENDITTOME,
      page: () => const SenItToMeScreen(type: '',),
      // binding: InitialBindings(),
    ),
    GetPage(
      name: Routes.SENDITTOME2,
      page: () => const SenItToMeScreen2(),
      // binding: InitialBindings(),
    ),
    GetPage(
      name: Routes.EMAIL,
      page: () => const Email(),
      // binding: InitialBindings(),
    ),
    GetPage(
      name: Routes.PHONE,
      page: () => const Phone(),
      // binding: InitialBindings(),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsScreen(),
      // binding: InitialBindings(),
    ),
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashScreen(),
      // binding: InitialBindings(),
    ),
  ];
}
