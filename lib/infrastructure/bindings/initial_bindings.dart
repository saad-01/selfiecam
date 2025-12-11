import 'package:get/get.dart';
import '../../../presentation/auth/sign_in/controller/sign_in_controller.dart';
import '../../presentation/auth/sign_in/controller/admin_menu_controller.dart';

class InitialBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignInController>(() => SignInController());
    Get.lazyPut<AdminMenuController>(() => AdminMenuController());
  }
}
