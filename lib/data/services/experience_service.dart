import 'package:hive/hive.dart';
import '../models/experiences_model.dart';
import 'media_download_service.dart';

class ExperiencesLocalRepository {
  static const String boxName = "experiencesBox";
  static const String key = "experiences";
  static const String settingsBox = "experience_settings_box";

  final MediaDownloadService _mediaService = MediaDownloadService();

  /// MAIN FUNCTION
  Future<Experiences> processAndStore(Experiences apiData) async {
    final processedAiStyles = await _processAiStyles(apiData.aiStyles);

    final updated = Experiences(
      id: apiData.id,
      eventId: apiData.eventId,
      status: apiData.status,
      deletedAt: apiData.deletedAt,
      photo: apiData.photo,
      shoutout: apiData.shoutout,
      boomerang: apiData.boomerang,
      gif: apiData.gif,
      slowMotion: apiData.slowMotion,
      aiStyles: processedAiStyles,
      createdAt: apiData.createdAt,
      updatedAt: apiData.updatedAt,
      v: apiData.v,
    );
    final box = await Hive.openBox(boxName);
    await box.put(key, updated.toJson());

    return updated;
  }

  /// PROCESS AI STYLES
  Future<AiStyles> _processAiStyles(AiStyles aiStyles) async {
    if (!aiStyles.enabled || aiStyles.styles.isEmpty) {
      return aiStyles;
    }

    List<Map<String, dynamic>> processedStyles = [];

    for (var style in aiStyles.styles) {
      if (style is! Map<String, dynamic>) {
        processedStyles.add(Map<String, dynamic>.from(style));
        continue;
      }

      final styleMap = Map<String, dynamic>.from(style);

      final refImage = styleMap["referenceImage"];

      /// download only if exists
      if (refImage != null && refImage.toString().isNotEmpty) {
        final localPath = await _mediaService.downloadFile(refImage, "ai_style_${styleMap["_id"]}.png");

        styleMap["referenceImage"] = localPath;
      }

      processedStyles.add(styleMap);
    }

    return AiStyles(enabled: aiStyles.enabled, styles: processedStyles, overlayEnabled: aiStyles.overlayEnabled);
  }

  /// LOAD LOCAL DATA
  Future<Experiences?> loadLocal() async {
    final box = Hive.box(boxName);

    final data = box.get(key);

    if (data == null) return null;

    return Experiences.fromJson(Map<String, dynamic>.from(data));
  }

  /// CHECK IF API HAS NEWER DATA
  Future<bool> shouldUpdate(Experiences apiData) async {
    final local = await loadLocal();

    if (local == null) return true;

    return apiData.updatedAt.isAfter(local.updatedAt);
  }

  Future<void> setExperienceToggle({required String eventId, required String type, required bool value}) async {
    final box = await Hive.openBox(settingsBox);

    final key = "${eventId}_$type";

    await box.put(key, value);
  }

  Future<bool?> getExperienceToggle({required String eventId, required String type}) async {
    final box = await Hive.openBox(settingsBox);

    final key = "${eventId}_$type";

    return box.get(key);
  }
}
