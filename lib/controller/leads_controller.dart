import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:selfiecam1/controller/cam_controller.dart';
import 'package:selfiecam1/controller/device_controller.dart';
import 'package:selfiecam1/data/models/lead_capture.dart';
import 'package:selfiecam1/data/models/lead_model.dart';
import 'package:selfiecam1/data/models/upload_status.dart';
import 'package:selfiecam1/data/services/credentials.dart';
import 'package:selfiecam1/data/services/internet_service.dart';
import 'package:selfiecam1/data/services/internet_service_adapter.dart';
import 'package:selfiecam1/data/services/upload_queue_service.dart';
import 'package:selfiecam1/data/services/upload_repository.dart';
import 'package:selfiecam1/infrastructure/constants/api_endpoints.dart';
import 'package:selfiecam1/infrastructure/utils/api_client.dart';
import 'package:selfiecam1/infrastructure/utils/custom_snackbar.dart';
import 'package:selfiecam1/infrastructure/utils/loader.dart';
import 'package:selfiecam1/infrastructure/utils/logger.dart';
import 'package:selfiecam1/infrastructure/utils/pref_utils.dart';
import 'package:selfiecam1/infrastructure/utils/video_utils.dart';
import 'package:selfiecam1/presentation/home/send_it_to_me_2_screen.dart';

class LeadsController extends GetxController {
  /// CONFIG
  final config = DeviceController.to.leadCaptureConfig;
  final persons = <Map<String, TextEditingController>>[].obs;
  final consents = <RxBool>[].obs; // one per person

  void addPerson() {
    persons.add({
      'name': TextEditingController(),
      'email': TextEditingController(),
      'phone': TextEditingController(),
      'company': TextEditingController(),
      'instagram': TextEditingController(),
      'tiktok': TextEditingController(),
    });
    consents.add(true.obs);
  }

  void removePerson(int index) {
    if (persons.length > 1) {
      persons[index].values.forEach((c) => c.dispose());
      persons.removeAt(index);
      consents.removeAt(index);
    }
  }

  bool isPersonComplete(int index, LeadFields fields) {
    final p = persons[index];
    if (fields.name.required && (p['name']?.text.trim().isEmpty ?? true)) return false;
    if (fields.email.required && (p['email']?.text.trim().isEmpty ?? true)) return false;
    if (fields.phone.required && (p['phone']?.text.trim().isEmpty ?? true)) return false;
    if (fields.company.required && (p['company']?.text.trim().isEmpty ?? true)) return false;
    if (fields.instagram.required && (p['instagram']?.text.trim().isEmpty ?? true)) return false;
    if (fields.tiktok.required && (p['tiktok']?.text.trim().isEmpty ?? true)) return false;
    if (fields.consent.required && !(consents[index].value)) return false;
    return true;
  }

  @override
  void onInit() {
    super.onInit();
    addPerson(); // start with one person
  }

  /// TEXT CONTROLLERS
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final companyController = TextEditingController();
  final instagramController = TextEditingController();
  final tiktokController = TextEditingController();

  /// CONSENT
  final consent = true.obs;

  /// LOADING
  final isSubmitting = false.obs;

  /// ---------------------------
  /// INIT CONFIG
  /// ---------------------------
  void setConfig(LeadCaptureConfig cfg) {
    config.value = cfg;
  }

  /// ---------------------------
  /// FIELD VISIBILITY
  /// ---------------------------
  bool isEnabled(LeadField field) => field.enabled;

  /// ---------------------------
  /// FIELD REQUIRED
  /// ---------------------------
  bool isRequired(LeadField field) => field.required;

  /// ---------------------------
  /// VALIDATION
  /// ---------------------------
  String? validateField({required String value, required LeadField field, required String fieldName}) {
    if (!field.enabled) return null;

    if (field.required && value.trim().isEmpty) {
      return "$fieldName is required";
    }

    return null;
  }

  /// ---------------------------
  /// FULL FORM VALIDATION
  /// ---------------------------
  bool validateForm() {
    final fields = config.value?.fields;
    if (fields == null) return false;

    if (isRequired(fields.name) && nameController.text.trim().isEmpty) return false;

    if (isRequired(fields.email) && emailController.text.trim().isEmpty) return false;

    if (isRequired(fields.phone) && phoneController.text.trim().isEmpty) return false;

    if (isRequired(fields.company) && companyController.text.trim().isEmpty) return false;

    if (isRequired(fields.instagram) && instagramController.text.trim().isEmpty) return false;

    if (isRequired(fields.tiktok) && tiktokController.text.trim().isEmpty) return false;

    if (fields.consent.enabled && fields.consent.required && consent.value == false) return false;

    return true;
  }

  /// ---------------------------
  /// BUILD PAYLOAD
  /// ---------------------------
  LeadCapture buildPayload() {
    final fields = config.value!.fields;
    LeadCapture lead = LeadCapture();
    Map<String, dynamic> data = {};

    if (fields.name.enabled) {
      data["name"] = nameController.text.trim();
      lead.name = nameController.text.trim();
    }

    if (fields.email.enabled) {
      data["email"] = emailController.text.trim();
      lead.email = emailController.text.trim();
    }

    if (fields.phone.enabled) {
      data["phone"] = phoneController.text.trim();
      lead.phone = phoneController.text.trim();
    }

    if (fields.company.enabled) {
      data["company"] = companyController.text.trim();
      lead.company = companyController.text.trim();
    }

    if (fields.instagram.enabled) {
      data["instagram"] = instagramController.text.trim();
      lead.instagram = instagramController.text.trim();
    }

    if (fields.tiktok.enabled) {
      data["tiktok"] = tiktokController.text.trim();
      lead.tiktok = tiktokController.text.trim();
    }

    if (fields.consent.enabled) {
      data["consent"] = consent.value;
      lead.consentGiven = consent.value;
    }

    return lead;
  }

  String cleanPhoneNumber(String phone) {
    String phoneCleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return '+1$phoneCleaned'; // Ensure US country code
  }

  /// ---------------------------
  /// SUBMIT
  /// ---------------------------
  Future<void> submitLead(String type) async {
    try {
      isSubmitting.value = true;

      // Capture everything synchronously before any async work
      final List<Map<String, dynamic>> peopleList = persons.asMap().entries.map((entry) {
        final p = entry.value;
        return {
          "name": p['name']?.text.trim(),
          "email": p['email']?.text.trim(),
          "phone": cleanPhoneNumber(p['phone']?.text.trim() ?? ''),
          "company": p['company']?.text.trim(),
          "instagram": p['instagram']?.text.trim(),
          "tiktok": p['tiktok']?.text.trim(),
          "consent": consents[entry.key].value,
        };
      }).toList();

      // Snapshot the file path NOW — before background processing mutates it
      final originalFilePath = CameraControllerX.to.capturedFile!.value.path;
      final originalFileName = CameraControllerX.to.capturedFile!.value.name;
      final originalMimeType = CameraControllerX.to.capturedFile!.value.mimeType ?? 'image/jpeg';
      final publishToPublic = CameraControllerX.to.publishToPublic.value;
      final eventName = PrefUtils().getString("eventName") ?? "unknown_event";

      clearForm();

      // Navigate immediately — user doesn't wait for video processing
      Get.off(() => SenItToMeScreen2(capturedFile: CameraControllerX.to.capturedFile!.value, type: type));

      // Fire processing + upload in background — no await
      unawaited(
        _processAndEnqueue(
          type: type,
          originalFilePath: originalFilePath,
          originalFileName: originalFileName,
          originalMimeType: originalMimeType,
          publishToPublic: publishToPublic,
          eventName: eventName,
          peopleList: peopleList,
        ),
      );
    } catch (e, stackTrace) {
      CustomSnackbar.showError(e.toString());
      Logger.log('Error submitting lead: $e $stackTrace');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _processAndEnqueue({
    required String type,
    required String originalFilePath,
    required String originalFileName,
    required String originalMimeType,
    required bool publishToPublic,
    required String eventName,
    required List<Map<String, dynamic>> peopleList,
  }) async {
    try {
      // LoaderService().show();
      String processedPath = originalFilePath;

      final branding = DeviceController.to.branding.value;

      if (type == 'Photo') {
        await CameraControllerX.to.savePhoto();
        processedPath = CameraControllerX.to.capturedFileOriginal!.value.path;
      } else if (type == 'Ai') {
        await CameraControllerX.to.saveAIPhoto();
        processedPath = CameraControllerX.to.capturedFile!.value.path;
      } else if (type == 'Boomerang') {
        processedPath = await _applyAudioAndPromo(
          filePath: originalFilePath,
          audio: branding?.backgroundAudio,
          enableAudio: branding?.enableAudioBoomerang ?? false,
          promoVideo: branding?.promoVideo,
          enablePromo: branding?.enablePromoBoomerang ?? false,
          useGifConcatenation: false,
        );
        CameraControllerX.to.capturedFile = XFile(processedPath).obs;
        // CameraControllerX.to.capturedFile = XFile(processedPath).obs;
        var flippedPath = await VideoUtils().flipVideoHorizontally(processedPath);
        CameraControllerX.to.capturedFile = XFile(flippedPath!).obs;
        await CameraControllerX.to.saveVideo();
      } else if (type == 'Shoutout') {
        processedPath = await _applyPromoOnly(
          filePath: originalFilePath,
          promoVideo: branding?.promoVideo,
          enablePromo: branding?.enablePromoShoutout ?? false,
          useGifConcatenation: false,
        );
        CameraControllerX.to.capturedFile = XFile(processedPath).obs;
        await CameraControllerX.to.saveVideo();
      } else if (type == 'Gif') {
        processedPath = await _applyAudioAndPromo(
          filePath: originalFilePath,
          audio: branding?.backgroundAudio,
          enableAudio: branding?.enableAudioGif ?? false,
          promoVideo: branding?.promoVideo,
          enablePromo: branding?.enablePromoAnimatedGif ?? false,
          useGifConcatenation: true, // <-- Gif uses concatenateVideos, others use concatenateVideosLocal
        );
        CameraControllerX.to.capturedFile = XFile(processedPath).obs;
        await CameraControllerX.to.saveVideo();
      } else if (type == 'Slomo') {
        processedPath = await _applyAudioAndPromo(
          filePath: originalFilePath,
          audio: branding?.backgroundAudio,
          enableAudio: branding?.enableAudioSlowmo ?? false,
          promoVideo: branding?.promoVideo,
          enablePromo: branding?.enablePromoSlowmo ?? false,
          useGifConcatenation: false,
        );
        CameraControllerX.to.capturedFile = XFile(processedPath).obs;
        await CameraControllerX.to.saveVideo();
      }

      final bytes = (await File(processedPath).stat()).size;
      if (Get.isRegistered<UploadQueueService>()) {
      } else {
        await Get.putAsync(() async {
          final service = UploadQueueService(
            repository: UploadRepository(),
            connectivity: InternetServiceAdapter(Get.find<InternetService>()),
            credentials: MyCredentialsProvider(),
          );
          await service.init();
          return service;
        }, permanent: true);
      }
      final uploadQueue = Get.find<UploadQueueService>();
      // await uploadQueue.init();

      final mediaId = await uploadQueue.enqueue(
        UploadEnqueueRequest(
          filePath: processedPath,
          fileName: originalFileName,
          fileSize: bytes,
          mimeType: originalMimeType,
          eventName: eventName,
          compress: true,
          listOnGallery: publishToPublic,
          leadCapture: peopleList,
        ),
      );

      uploadQueue.onItemUpdated.where((item) => item.id == mediaId).listen((item) {
        switch (item.status) {
          case UploadStatus.uploading:
            print('Progress: ${(item.uploadProgress * 100).toStringAsFixed(1)}%');
          case UploadStatus.completed:
            print('Done! CDN URL: ${item.mediaUrl}');
            print('Share link: ${item.imageLink}');
          case UploadStatus.failed:
            print('Failed after ${item.retryCount} attempts: ${item.errorMessage}');
          default:
            break;
        }
      });
    } catch (e, stackTrace) {
      Logger.log('Background processing/enqueue error: $e $stackTrace');
      // Optionally surface a non-blocking snackbar here
      // CustomSnackbar.showError('Upload failed: ${e.toString()}');
    } finally {
      // LoaderService().hide();
    }
  }

  // Handles the audio-attach → promo-concat pattern shared by Boomerang, Gif, Slomo
  Future<String> _applyAudioAndPromo({
    required String filePath,
    required String? audio,
    required bool enableAudio,
    required String? promoVideo,
    required bool enablePromo,
    required bool useGifConcatenation,
  }) async {
    String current = filePath;

    if (audio != null && enableAudio) {
      current = (await VideoUtils.attachBackgroundAudio(videoPath: current, audioUrl: audio))!;
    }

    return _applyPromoOnly(
      filePath: current,
      promoVideo: promoVideo,
      enablePromo: enablePromo,
      useGifConcatenation: useGifConcatenation,
    );
  }

  Future<String> _applyPromoOnly({
    required String filePath,
    required String? promoVideo,
    required bool enablePromo,
    required bool useGifConcatenation,
  }) async {
    if (promoVideo != null && enablePromo) {
      final result = useGifConcatenation
          ? await VideoUtils.concatenateVideos(localVideoPath: filePath, remoteVideoUrl: promoVideo)
          : await VideoUtils.concatenateVideosLocal(localVideoPath: filePath, remoteVideoUrl: promoVideo);
      return result!;
    }
    return filePath;
  }

  Future<void> onPhotoTaken(XFile photo) async {
    final stat = await File(photo.path).stat();
    final bytes = stat.size;
    var uploadQueue = Get.find<UploadQueueService>();

    final mediaId = await uploadQueue.enqueue(
      UploadEnqueueRequest(
        filePath: photo.path,
        fileName: photo.name,
        fileSize: bytes,
        mimeType: photo.mimeType ?? 'image/jpeg',
        eventName: PrefUtils().getString("eventName") ?? "unknown_event",
        compress: true,
        listOnGallery: CameraControllerX.to.publishToPublic.value,
        leadCapture: LeadCapture(name: 'Jane Smith', email: 'jane@example.com', phone: '+1234567890', consentGiven: true),
      ),
    );

    // `mediaId` is the UUID sent to the server as `media_id`.
    // Listen to onItemUpdated for progress / completion events:

    uploadQueue.onItemUpdated.where((item) => item.id == mediaId).listen((item) {
      switch (item.status) {
        case UploadStatus.uploading:
          print('Progress: ${(item.uploadProgress * 100).toStringAsFixed(1)}%');
        case UploadStatus.completed:
          print('Done! CDN URL: ${item.mediaUrl}');
          print('Share link: ${item.imageLink}');
        case UploadStatus.failed:
          print('Failed after ${item.retryCount} attempts: ${item.errorMessage}');
        default:
          break;
      }
    });
  }

  /// ---------------------------
  /// CLEAR FORM
  /// ---------------------------
  void clearForm() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    companyController.clear();
    instagramController.clear();
    tiktokController.clear();
    consent.value = false;
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    companyController.dispose();
    instagramController.dispose();
    tiktokController.dispose();
    super.onClose();
  }

  Future<List<String>> dropdownApi(String search) async {
    try {
      var response = await ApiCalls.getAPICall(
        url: "${ApiUrls.leadCaptureContacts}?search=$search&type=email&page=1&limit=20",
        isAuth: true,
        showError: false,
        eventJoined: true,
      );
      if (response.statusCode == 200) {
        final data = response.data['data']['contacts'] as List;
        // ← adjust the key ('email') to whatever your model actually contains
        return data.map((e) => e['email'].toString()).toList();
      }
    } catch (e, st) {
      Logger.log("Dropdown API Exception: $e $st");
    }
    return [];
  }
}
