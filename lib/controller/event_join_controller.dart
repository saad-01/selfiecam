import 'dart:async';

import 'package:get/get.dart';
import 'package:selfiecam1/controller/device_controller.dart';
import 'package:selfiecam1/data/services/socket_service.dart';
import 'package:selfiecam1/infrastructure/constants/api_endpoints.dart';
import 'package:selfiecam1/infrastructure/navigation/routes.dart';
import 'package:selfiecam1/infrastructure/utils/api_client.dart';
import 'package:selfiecam1/infrastructure/utils/custom_snackbar.dart';
import 'package:selfiecam1/infrastructure/utils/loader.dart';
import 'package:selfiecam1/infrastructure/utils/logger.dart';
import 'package:selfiecam1/infrastructure/utils/pref_utils.dart';
import 'package:sizer/sizer.dart';

class EventJoinController extends GetxController {
  final RxList<dynamic> eventsList = <dynamic>[].obs;
  final Rxn<dynamic> selectedEvent = Rxn<dynamic>();
  final loader = Get.find<LoaderService>();
  void onEventSelected(dynamic event) {
    selectedEvent.value = event;
    joinEvent();
  }

  Future<void> getEvents() async {
    var response = await ApiCalls.getAPICall(url: ApiUrls.getEvents, isAuth: true);
    Logger.log("Events List: ${response.statusCode}");
    if (response.statusCode == 200) {
      final list = response.data['data'];
      if (list != null && list.isNotEmpty) {
        eventsList.assignAll(list);
        Logger.log("Events List: $eventsList");
      } else {
        eventsList.clear();
        CustomSnackbar.showError("No events available, please try again later.");
      }
    } else {
      CustomSnackbar.showError("${response.data ?? 'Failed to fetch events'}");
    }
  }

  Future<void> joinEvent() async {
    final event = selectedEvent.value;

    if (event == null) return;
    loader.show();
    var response = await ApiCalls.putAPICall(
      url: "${ApiUrls.joinEvent}/${PrefUtils().getString("deviceId")}",
      isAuth: true,
      bodyParams: {"eventId": event['_id']},
    );
    loader.hide();
    Logger.log("Joined Event: ${response.data['data']['lastEventId']['eventName']}");
    if (response.statusCode == 200) {
      Logger.log("Joined Event: ${response.data['data']['lastEventId']['eventName']}");
      PrefUtils().saveString("eventToken", response.data['eventToken']);
      PrefUtils().saveString("eventId", response.data['data']['lastEventId']['_id']);
      PrefUtils().saveString("eventJoined", "true");
      Logger.log("Joined Event: ${response.data['data']['lastEventId']['eventName']}");
      PrefUtils().saveString("eventName", response.data['data']['lastEventId']['eventName']);
      await DeviceController.to.getJoinedEvent();
      SocketService.init();
      unawaited(DeviceController.to.loadAllInfo());
      Get.offAllNamed(Routes.EXPERIENCESELECTION2);
    } else {
      CustomSnackbar.showError("${response.data ?? 'Failed to join event'}");
    }
  }

  Future<void> getDeviceById() async {
    var response = await ApiCalls.getAPICall(url: "${ApiUrls.joinEvent}/${PrefUtils().getString("deviceId")}", isAuth: true);
    if (response.statusCode == 200) {
      var data = response.data['data']['lastEventId'];
      if (data != null && data.isNotEmpty) {
        PrefUtils().saveString("eventJoined", "true");
      }
    } else {
      CustomSnackbar.showError("${response.data ?? 'Failed to fetch device info'}");
    }
  }
}
