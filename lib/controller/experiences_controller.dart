import 'package:get/get.dart';
import 'package:selfiecam1/infrastructure/constants/api_endpoints.dart';
import 'package:selfiecam1/infrastructure/navigation/routes.dart';
import 'package:selfiecam1/infrastructure/utils/api_client.dart';
import 'package:selfiecam1/infrastructure/utils/custom_snackbar.dart';
import 'package:selfiecam1/infrastructure/utils/pref_utils.dart';

class ExperiencesController extends GetxController {
  final RxList<dynamic> eventsList = <dynamic>[].obs;
  final Rxn<dynamic> selectedEvent = Rxn<dynamic>();
  void onEventSelected(dynamic event) {
    selectedEvent.value = event;
    joinEvent();
  }

  Future<void> getEvents() async {
    var response = await ApiCalls.getAPICall(
      url: "${ApiUrls.getEvents}?status=all&sortBy=createdAt&sortOrder=desc",
      isAuth: true,
    );

    if (response.statusCode == 200) {
      final list = response.data['data']['events'];
      if (list != null && list.isNotEmpty) {
        eventsList.assignAll(list);
      } else {
        eventsList.clear();
      }
    } else {
      CustomSnackbar.showError("${response.data ?? 'Failed to fetch events'}");
    }
  }

  Future<void> joinEvent() async {
    final event = selectedEvent.value;

    if (event == null) return;

    var response = await ApiCalls.putAPICall(
      url: "${ApiUrls.joinEvent}/${PrefUtils().getString("deviceId")}",
      isAuth: true,
      bodyParams: {"eventId": event['_id']},
    );

    if (response.statusCode == 200) {
      PrefUtils().saveString("eventId", event['_id']);
      PrefUtils().saveString("eventJoined", "true");
      Get.toNamed(Routes.WELCOME1);
    } else {
      CustomSnackbar.showError("${response.data ?? 'Failed to join event'}");
    }
  }
}
