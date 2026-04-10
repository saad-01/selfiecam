import 'package:hive/hive.dart';
import 'package:selfiecam1/data/models/lead_model.dart';

class LeadCaptureLocalRepository {
  Future<LeadCaptureConfig> processAndStore(LeadCaptureConfig config) async {
    final updatedConfig = LeadCaptureConfig(
      id: config.id,
      eventId: config.eventId,
      status: config.status,
      deletedAt: config.deletedAt,
      emailAutoPopulate: config.emailAutoPopulate,
      fields: config.fields,
      createdAt: config.createdAt,
      updatedAt: config.updatedAt,
      v: config.v,
    );

    final box = await Hive.openBox('leadCaptureBox');

    await box.put('leadCapture', updatedConfig.toJson());

    return updatedConfig;
  }

  Future<LeadCaptureConfig?> loadLocal() async {
    final box = await Hive.openBox('leadCaptureBox');

    final data = box.get('leadCapture');

    if (data == null) return null;

    return LeadCaptureConfig.fromJson(Map<String, dynamic>.from(data));
  }
}
