import 'package:get/get.dart';
import 'package:selfiecam1/controller/device_controller.dart';
import 'package:selfiecam1/data/models/branding_model.dart';
import 'package:selfiecam1/data/models/experiences_model.dart';
import 'package:selfiecam1/infrastructure/constants/api_endpoints.dart';
import 'package:selfiecam1/infrastructure/navigation/routes.dart';
import 'package:selfiecam1/infrastructure/utils/pref_utils.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../infrastructure/utils/logger.dart';

class SocketService extends GetxService {
  static late io.Socket socket;
  static RxInt connectedId = 0.obs;
  static RxBool initializedSocket = false.obs;
  static RxBool callEvents = false.obs;
  static RxInt conversationId = 0.obs;
  static RxInt currentRoomId = 0.obs;
  static List<int> tempIdList = [];
  static Future<void> init() async {
    Logger.log("Socket Service Initialized");
    // var id = MainHomeController.to.profileData['user']['id'];
    socket = io.io(
      ApiUrls.socketUrl,
      io.OptionBuilder()
          .setPath('/socket.io') // ✅ add this line
          .setTransports(['websocket']) // optional
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .setTimeout(20000)
          .setAuth({'token': PrefUtils().getUserToken()})
          .setQuery({'deviceId': PrefUtils().getString("deviceId")})
          .build(),
    );
    try {
      // socket.
      socket.connect();
      Logger.log("Connection Established ${{"authorization": 'Bearer ${PrefUtils().getUserToken()}'}.toString()}");
    } catch (e) {
      Logger.log(e.toString());
      Logger.log("Error Connecting To Server");
    }
    socket.onConnect((data) {
      initializedSocket.value = true;
      Logger.log("@@@@@@@@@@@@@@@@@@@Connection established");
      Logger.log(socket.connected.toString());
      socket.emit('getUserDetails', {});
      if (connectedId.value != 0) {}
    });
    socket.onAny((event, payload) => {Logger.log("EVENT: $event payload: $payload")});
    socket.onConnectError((data) {
      Logger.log("Error while connecting $data");
      // MyToast.error("msg_something_wrong");
    });
    socket.onDisconnect((data) {
      initializedSocket.value = false;
      SocketService.socket.emit("event:leave", {"eventId": PrefUtils().getString("eventId")});
      Logger.log("@@@Diconnected from the server: $data");
    });
    socket.on('device:removed', (data) async {
      await PrefUtils().clearPreferencesData();
      Get.offAllNamed(Routes.SIGNIN);
    });
    socket.on('event:branding-updated', (data) async {
      Logger.log("Received branding update from server");
      DeviceController.to.branding.value = Branding.fromJson(data['branding']);
      DeviceController.to.update();
    });
    socket.on('event:experiences-updated', (data) async {
      Logger.log("Received branding update from server");
      DeviceController.to.experiences.value = Experiences.fromJson(data['experiences']);
      DeviceController.to.update();
    });
  }
}
