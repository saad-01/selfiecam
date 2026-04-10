import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:selfiecam1/data/models/branding_model.dart';
import 'package:selfiecam1/data/services/media_download_service.dart';

import '../../infrastructure/utils/logger.dart';

class BrandingLocalRepository {
  final MediaDownloadService _mediaService = MediaDownloadService();

  Future<void> _deleteOldBrandingFiles(Box box) async {
    Logger.log("Checking for old branding files to delete...");
    final oldData = box.get('branding');
    if (oldData == null) return;
    Logger.log("Old branding data found: ${oldData.toString()}");

    final oldId = oldData['_id']?.toString();
    if (oldId == null) return;
    Logger.log("Old branding ID: $oldId");

    final dir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${dir.path}/media');

    final oldFileNames = [
      'home_image_$oldId.png',
      'home_video_$oldId.mp4',
      'home_no_activity_video_$oldId.mp4',
      'home_$oldId.png',
      'overlay_$oldId.png',
      'promo_$oldId.mp4',
      'audio_$oldId.mp3',
    ];

    for (final fileName in oldFileNames) {
      Logger.log("Attempting to delete old branding file: $fileName");
      final file = File('${mediaDir.path}/$fileName');
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  Future<Branding> processAndStore(Branding branding) async {
    final box = await Hive.openBox('brandingBox');

    // Delete old files BEFORE downloading new ones
    // await _deleteOldBrandingFiles(box);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final updatedBranding = Branding(
      id: branding.id,
      eventId: branding.eventId,
      buttonColor: branding.buttonColor,
      buttonTextColor: branding.buttonTextColor,
      buttonStyle: branding.buttonStyle,
      fontFamily: branding.fontFamily,
      fontColor: branding.fontColor,
      fontSize: branding.fontSize,
      homeImage: await _mediaService.downloadFile(branding.homeImage, 'home_image_${branding.id}_$timestamp.png'),
      homeVideo: await _mediaService.downloadFile(branding.homeVideo, 'home_video_${branding.id}_$timestamp.mp4'),
      homeNoActivityVideo: await _mediaService.downloadFile(
        branding.homeNoActivityVideo,
        'home_no_activity_video_${branding.id}_$timestamp.mp4',
      ),
      homeScreenMode: branding.homeScreenMode,
      homeOverlay: await _mediaService.downloadFile(branding.homeOverlay, 'home_${branding.id}_$timestamp.png'),
      photoVideoOverlay: await _mediaService.downloadFile(branding.photoVideoOverlay, 'overlay_${branding.id}_$timestamp.png'),
      promoVideo: await _mediaService.downloadFile(branding.promoVideo, 'promo_${branding.id}_$timestamp.mp4'),
      backgroundAudio: await _mediaService.downloadFile(branding.backgroundAudio, 'audio_${branding.id}_$timestamp.mp3'),
      enablePromoBoomerang: branding.enablePromoBoomerang,
      enablePromoShoutout: branding.enablePromoShoutout,
      enablePromoAnimatedGif: branding.enablePromoAnimatedGif,
      enablePromoSlowmo: branding.enablePromoSlowmo,
      enableAudioBoomerang: branding.enableAudioBoomerang,
      enableAudioGif: branding.enableAudioGif,
      enableAudioSlowmo: branding.enableAudioSlowmo,
      smsMessage: branding.smsMessage,
      createdAt: branding.createdAt,
      updatedAt: branding.updatedAt,
    );

    await box.put('branding', updatedBranding.toJson());

    return updatedBranding;
  }
}
