// lib/features/upload/hive_registrar.dart
//
// Call `HiveRegistrar.registerUploadAdapters()` once during app initialisation,
// before any Hive box is opened.
//
// Example (in main.dart):
//   void main() async {
//     WidgetsFlutterBinding.ensureInitialized();
//     await Hive.initFlutter();          // or Hive.init(directory) for non-Flutter
//     HiveRegistrar.registerUploadAdapters();
//     runApp(const MyApp());
//   }
// ─────────────────────────────────────────────────────────────────────────────

import 'package:hive/hive.dart';
import 'package:selfiecam1/data/models/lead_capture.dart';
import 'package:selfiecam1/data/models/upload_queue_item.dart';
import 'package:selfiecam1/data/models/upload_status.dart';

class HiveRegistrar {
  HiveRegistrar._();

  /// Registers all TypeAdapters for the upload system.
  /// Safe to call multiple times – subsequent calls are no-ops.
  static void registerUploadAdapters() {
    _register(UploadStatusAdapter());    // typeId = 50
    _register(LeadCaptureAdapter());     // typeId = 51
    _register(UploadQueueItemAdapter()); // typeId = 52
  }

  static void _register<T>(TypeAdapter<T> adapter) {
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
  }
}
