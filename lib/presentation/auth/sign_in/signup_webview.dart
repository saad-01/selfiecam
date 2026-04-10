import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:selfiecam1/infrastructure/utils/loader.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SignupWebview extends StatelessWidget {
  final String url;
  SignupWebview({super.key, required this.url});
  final RxBool isLoading = true.obs;
  final LoaderService loader = Get.find<LoaderService>();

  late final WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(Colors.transparent)
    ..setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (_) {
          if (isLoading.value) {
            loader.show();
          }
        },
        onPageFinished: (_) {
          if (isLoading.value) {
            isLoading.value = false;
            loader.hide();
          }
        },
        onWebResourceError: (error) {
          isLoading.value = false;
          loader.hide();

          // Get.snackbar(
          //   'Error',
          //   'Failed to load page. Please check your internet connection.',
          //   snackPosition: SnackPosition.BOTTOM,
          //   backgroundColor: Colors.red,
          //   colorText: Colors.white,
          // );
        },
      ),
    )
    ..loadRequest(Uri.parse(url));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: WebViewWidget(controller: controller),
    );
  }
}
