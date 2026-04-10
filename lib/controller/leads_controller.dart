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

  /// ---------------------------
  /// SUBMIT
  /// ---------------------------
  Future<void> submitLead(String type) async {
    try {
      isSubmitting.value = true;
      // final leadCapture = buildPayload();
      final List<Map<String, dynamic>> peopleList = persons.asMap().entries.map((entry) {
        final index = entry.key;
        final p = entry.value;

        return {
          "name": p['name']?.text.trim(),
          "email": p['email']?.text.trim(),
          "phone": p['phone']?.text.trim(),
          "company": p['company']?.text.trim(),
          "instagram": p['instagram']?.text.trim(),
          "tiktok": p['tiktok']?.text.trim(),
          "consent": consents[index].value,
        };
      }).toList();
      LoaderService().show();
      if (type == 'Photo') {
        await CameraControllerX.to.savePhoto();
      } else if (type == 'Boomerang') {
        if (DeviceController.to.branding.value?.backgroundAudio != null &&
            DeviceController.to.branding.value!.enableAudioBoomerang) {
          var video1 = await VideoUtils.attachBackgroundAudio(
            videoPath: CameraControllerX.to.capturedFile!.value.path,
            audioUrl: DeviceController.to.branding.value!.backgroundAudio!,
          );
          if (DeviceController.to.branding.value?.promoVideo != null &&
              DeviceController.to.branding.value!.enablePromoBoomerang) {
            var video = await VideoUtils.concatenateVideosLocal(
              localVideoPath: video1!,
              remoteVideoUrl: DeviceController.to.branding.value!.promoVideo!,
            );
            CameraControllerX.to.capturedFile = XFile(video!).obs;
            await CameraControllerX.to.saveVideo();
          } else {
            CameraControllerX.to.capturedFile = XFile(video1!).obs;
            await CameraControllerX.to.saveVideo();
          }
        } else {
          if (DeviceController.to.branding.value?.promoVideo != null &&
              DeviceController.to.branding.value!.enablePromoBoomerang) {
            var video = await VideoUtils.concatenateVideosLocal(
              localVideoPath: CameraControllerX.to.capturedFile!.value.path,
              remoteVideoUrl: DeviceController.to.branding.value!.promoVideo!,
            );
            Logger.log("hi");
            CameraControllerX.to.capturedFile = XFile(video!).obs;
            await CameraControllerX.to.saveVideo();
          } else {
            await CameraControllerX.to.saveVideo();
          }
        }

        // await camController.uploadToApi(widget.capturedFile!);
      } else if (type == 'Shoutout') {
        if (DeviceController.to.branding.value?.promoVideo != null && DeviceController.to.branding.value!.enablePromoShoutout) {
          var video = await VideoUtils.concatenateVideosLocal(
            localVideoPath: CameraControllerX.to.capturedFile!.value.path,
            remoteVideoUrl: DeviceController.to.branding.value!.promoVideo!,
          );
          CameraControllerX.to.capturedFile = XFile(video!).obs;
          await CameraControllerX.to.saveVideo();
        } else {
          await CameraControllerX.to.saveVideo();
        }

        // await camController.uploadToApi(widget.capturedFile!);
      } else if (type == 'Gif') {
        if (DeviceController.to.branding.value?.backgroundAudio != null && DeviceController.to.branding.value!.enableAudioGif) {
          var video1 = await VideoUtils.attachBackgroundAudio(
            videoPath: CameraControllerX.to.capturedFile!.value.path,
            audioUrl: DeviceController.to.branding.value!.backgroundAudio!,
          );

          if (DeviceController.to.branding.value?.promoVideo != null &&
              DeviceController.to.branding.value!.enablePromoAnimatedGif) {
            var video = await VideoUtils.concatenateVideos(
              localVideoPath: video1!,
              remoteVideoUrl: DeviceController.to.branding.value!.promoVideo!,
            );
            CameraControllerX.to.capturedFile = XFile(video!).obs;
            await CameraControllerX.to.saveVideo();
          } else {
            CameraControllerX.to.capturedFile = XFile(video1!).obs;
            await CameraControllerX.to.saveVideo();
          }
        } else {
          if (DeviceController.to.branding.value?.promoVideo != null &&
              DeviceController.to.branding.value!.enablePromoAnimatedGif) {
            var video = await VideoUtils.concatenateVideosLocal(
              localVideoPath: CameraControllerX.to.capturedFile!.value.path,
              remoteVideoUrl: DeviceController.to.branding.value!.promoVideo!,
            );
            Logger.log("hi");
            CameraControllerX.to.capturedFile = XFile(video!).obs;
            await CameraControllerX.to.saveVideo();
          } else {
            await CameraControllerX.to.saveVideo();
          }
        }

        // await camController.uploadToApi(widget.capturedFile!);
      } else if (type == 'Slomo') {
        if (DeviceController.to.branding.value?.backgroundAudio != null &&
            DeviceController.to.branding.value!.enableAudioSlowmo) {
          var video1 = await VideoUtils.attachBackgroundAudio(
            videoPath: CameraControllerX.to.capturedFile!.value.path,
            audioUrl: DeviceController.to.branding.value!.backgroundAudio!,
          );

          if (DeviceController.to.branding.value?.promoVideo != null && DeviceController.to.branding.value!.enablePromoSlowmo) {
            var video = await VideoUtils.concatenateVideosLocal(
              localVideoPath: video1!,
              remoteVideoUrl: DeviceController.to.branding.value!.promoVideo!,
            );
            CameraControllerX.to.capturedFile = XFile(video!).obs;
            await CameraControllerX.to.saveVideo();
          } else {
            CameraControllerX.to.capturedFile = XFile(video1!).obs;
            await CameraControllerX.to.saveVideo();
          }
        } else {
          if (DeviceController.to.branding.value?.promoVideo != null && DeviceController.to.branding.value!.enablePromoSlowmo) {
            var video = await VideoUtils.concatenateVideosLocal(
              localVideoPath: CameraControllerX.to.capturedFile!.value.path,
              remoteVideoUrl: DeviceController.to.branding.value!.promoVideo!,
            );
            Logger.log("hi");
            CameraControllerX.to.capturedFile = XFile(video!).obs;
            await CameraControllerX.to.saveVideo();
          } else {
            await CameraControllerX.to.saveVideo();
          }
        }

        // await camController.uploadToApi(widget.capturedFile!);
      } else if (type == 'Ai') {
        await CameraControllerX.to.savePhoto();
      }
      final stat = await File(CameraControllerX.to.capturedFile!.value.path).stat();
      final bytes = stat.size;
      var uploadQueue = Get.find<UploadQueueService>();
      await uploadQueue.init(); // Ensure the service is initialized before enqueuing

      final mediaId = await uploadQueue.enqueue(
        UploadEnqueueRequest(
          filePath: CameraControllerX.to.capturedFile!.value.path,
          fileName: CameraControllerX.to.capturedFile!.value.name,
          fileSize: bytes,
          mimeType: CameraControllerX.to.capturedFile!.value.mimeType ?? 'image/jpeg',
          eventName: PrefUtils().getString("eventName") ?? "unknown_event",
          compress: true,
          listOnGallery: CameraControllerX.to.publishToPublic.value,
          leadCapture: peopleList,
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

      clearForm();

      LoaderService().hide();
      Get.back(); // Close the lead capture screen after submission
      Get.back(); // Go back to the camera screen
      Get.back(); // Go back to the experience selection screen
      CameraControllerX.to.capturedFile = null;
    } catch (e, stackTrace) {
      CustomSnackbar.showError(e.toString());
      Logger.log('Error submitting lead: $e $stackTrace');
    } finally {
      isSubmitting.value = false;
    }
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
