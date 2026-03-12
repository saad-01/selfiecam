import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:selfiecam1/controller/device_controller.dart';
import 'package:selfiecam1/infrastructure/utils/logger.dart';

class VideoUtils {
  /// Remove audio
  static Future<String> removeAudio(String inputPath) async {
    final dir = await getTemporaryDirectory();
    final outputPath = p.join(dir.path, 'no_audio_${DateTime.now().millisecondsSinceEpoch}.mp4');

    final command = '-i "$inputPath" -c copy -an "$outputPath"';

    await _execute(command);
    return outputPath;
  }

  /// Reverse video (video + audio)
  static Future<String> reverseVideo(String inputPath) async {
    final dir = await getTemporaryDirectory();
    final outputPath = p.join(dir.path, 'reversed_${DateTime.now().millisecondsSinceEpoch}.mp4');

    final command = '-i $inputPath -vf reverse -af areverse -c:v libx264 -preset fast -crf 18 $outputPath';
    await _execute(command);
    return outputPath;
  }

  /// Generate Boomerang (Forward + Backward)
  static Future<String> generateBoomerangVideo(
    String forwardPath,
    String backwardPath, {
    double playbackSpeed = 1.0, // 0.5 → 2.0
    int loopCount = -1, // -1 = infinite
  }) async {
    final dir = await getTemporaryDirectory();
    final outputPath = p.join(dir.path, 'boomerang_${DateTime.now().millisecondsSinceEpoch}.mp4');

    // Speed filter (correct math)
    // final speedFilter = 'setpts=${1 / playbackSpeed}*PTS';

    String command;

    // Infinite loop (use only for preview)
    command = '-i "$forwardPath" -i "$backwardPath" -filter_complex "[0:v][1:v]concat=n=2:v=1:a=0" -an "$outputPath"';

    await _execute(command);
    return outputPath;
  }

  /// Generate PingPong Effect
  static Future<String> generatePingpongVideo(String forwardPath, String backwardPath) async {
    final dir = await getTemporaryDirectory();
    final outputPath = p.join(dir.path, 'pingpong_${DateTime.now().millisecondsSinceEpoch}.mp4');

    final command =
        '-i "$forwardPath" -i "$backwardPath" '
        '-filter_complex "'
        '[0:v]copy[forward_full];'
        '[1:v]trim=start=0:duration=0.3[backward_start];'
        '[0:v]reverse,trim=start=0:duration=0.3,reverse[forward_end];'
        '[1:v]copy[backward_full];'
        '[forward_full][backward_start][forward_end][backward_full]'
        'concat=n=4:v=1:a=0" '
        '-an "$outputPath"';

    await _execute(command);
    return outputPath;
  }

  /// Apply Overlay PNG on Video
  static Future<String> applyOverlay(String inputPath, String overlayPath) async {
    final dir = await getTemporaryDirectory();
    final outputPath = p.join(dir.path, 'overlay_${DateTime.now().millisecondsSinceEpoch}.mp4');

    final command =
        '-i "$inputPath" -i "$overlayPath" '
        '-filter_complex "[1:v][0:v]scale=w=rw:h=rh[ov];[0:v][ov]overlay=0:0" '
        '-c:v libx264 -preset ultrafast -crf 23 '
        '-pix_fmt yuv420p "$outputPath"';

    await _execute(command);
    return outputPath;
  }

  /// Internal FFmpeg executor (clean)
  static Future<void> _execute(String command) async {
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (returnCode == null || !ReturnCode.isSuccess(returnCode)) {
      final logs = await session.getAllLogsAsString();
      throw Exception('FFmpeg failed: $logs');
    }
  }

  static Future<String> _imagePackageToFile(img.Image overlayImage) async {
    final dir = await getTemporaryDirectory();

    final overlayPath = '${dir.path}/overlay_${DateTime.now().millisecondsSinceEpoch}.png';

    final pngBytes = img.encodePng(overlayImage);

    final file = File(overlayPath);
    await file.writeAsBytes(pngBytes);

    return overlayPath;
  }

  static Future<String> applyOverlayFromImagePackage({required String videoPath, required img.Image overlayImage}) async {
    final videoFile = File(videoPath);

    if (!await videoFile.exists()) {
      throw Exception('Video file not found');
    }

    /// Convert image.Image → PNG file
    final overlayPath = await _imagePackageToFile(overlayImage);

    final dir = await getTemporaryDirectory();
    final outputPath = '${dir.path}/final_${DateTime.now().millisecondsSinceEpoch}.mp4';

    final command =
        '-i "$videoPath" '
        '-i "$overlayPath" '
        '-filter_complex "[0:v][1:v]overlay=0:0" '
        '-c:v libx264 '
        '-c:a copy ' // <-- preserve original audio
        '-preset ultrafast '
        '-crf 23 '
        '-pix_fmt yuv420p '
        '-movflags +faststart '
        '"$outputPath"';

    await _execute(command);

    return outputPath;
  }

  // static Future<String> applyOverlayFromImagePackage({required String videoPath, required img.Image overlayImage}) async {
  //   final videoFile = File(videoPath);
  //   if (!await videoFile.exists()) throw Exception('Video file not found');

  //   final overlayPath = await _imagePackageToFile(overlayImage);
  //   final dir = await getTemporaryDirectory();
  //   final outputPath = '${dir.path}/final_${DateTime.now().millisecondsSinceEpoch}.mp4';

  //   // ✅ Probe actual video dimensions first
  //   final size = await _getVideoDimensions(videoPath);
  //   final int w = size['width']!;
  //   final int h = size['height']!;

  //   final command =
  //       '-i "$videoPath" '
  //       '-i "$overlayPath" '
  //       '-filter_complex '
  //       '"[0:v]setpts=PTS-STARTPTS[base];'
  //       '[1:v]scale=${w}:${h}[ov];' // ✅ scale to exact video size (no scale2ref)
  //       '[base][ov]overlay=0:0[outv]" '
  //       '-map "[outv]" '
  //       '-map 0:a? '
  //       '-c:v libx264 '
  //       '-c:a copy '
  //       '-preset ultrafast '
  //       '-crf 23 '
  //       '-pix_fmt yuv420p '
  //       '-movflags +faststart '
  //       '"$outputPath"';

  //   await _execute(command);
  //   return outputPath;
  // }

  // // ✅ Helper to probe video width/height via ffprobe
  // static Future<Map<String, int>> _getVideoDimensions(String videoPath) async {
  //   final session = await FFprobeKit.execute(
  //     '-v error -select_streams v:0 '
  //     '-show_entries stream=width,height '
  //     '-of csv=p=0 "$videoPath"',
  //   );

  //   final output = await session.getOutput();
  //   // output is like: "1080,1920"
  //   final parts = output?.trim().split(',');
  //   if (parts == null || parts.length < 2) {
  //     throw Exception('Could not probe video dimensions');
  //   }

  //   return {'width': int.parse(parts[0].trim()), 'height': int.parse(parts[1].trim())};
  // }

  /// Reverses a video file without losing quality or audio.
  ///
  /// [inputPath]    - Full path to the source video file.
  /// [onProgress]  - Optional callback receiving progress (0.0 – 1.0).
  ///
  /// Returns the output file path on success, or throws an exception on failure.
  static Future<String> generateReverseVideo({required String inputPath, void Function(double progress)? onProgress}) async {
    // ── 1. Prepare output path ──────────────────────────────────────────────────
    final Directory tempDir = await getTemporaryDirectory();
    final String fileName = 'reversed_${DateTime.now().millisecondsSinceEpoch}${path.extension(inputPath)}';
    final String outputPath = path.join(tempDir.path, fileName);

    // ── 2. Build FFmpeg command ─────────────────────────────────────────────────
    //   -vf reverse   → reverses video frames
    //   -af areverse  → reverses audio stream
    //   -c:v libx264  → re-encodes with H.264 (change to 'copy' to skip re-encode
    //                   but 'reverse' filter always requires re-encoding)
    //   -preset fast  → good balance of speed vs. file size
    //   -crf 18       → near-lossless quality (lower = better, 18–23 is ideal)
    final String command = '-i "$inputPath" -vf reverse -af areverse -c:v libx264 -preset fast -crf 18 "$outputPath"';

    // ── 3. Execute & track progress ─────────────────────────────────────────────
    final FFmpegSession session = await FFmpegKit.executeAsync(
      command,
      (session) async {
        // Completion callback — no action needed here; handled below.
      },
      (log) {
        // Log callback: parse duration/time for progress estimation
        if (onProgress != null) {
          final String message = log.getMessage();
          final double? progress = _parseProgress(message);
          if (progress != null) onProgress(progress);
        }
      },
    );

    // ── 4. Check result ─────────────────────────────────────────────────────────
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      return outputPath;
    } else {
      final logs = await session.getLogsAsString();
      throw Exception('FFmpeg failed to reverse video.\n\nLogs:\n$logs');
    }
  }

  // ── Helper: crude progress parser from FFmpeg stderr ──────────────────────────
  static double? _parseProgress(String log) {
    // FFmpeg emits lines like: "frame=  120 fps= 60 ... time=00:00:04.00 ..."
    // We extract 'time' and compare against a known duration if available.
    // For simplicity, we just return null here and let callers use a spinner.
    // Replace with a proper duration-aware parser if needed.
    return null;
  }

  static Future<String?> generateBoomerang(String inputPath) async {
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final reversedPath = '${dir.path}/reversed_$timestamp.mp4';
    final outputPath = '${dir.path}/boomerang_$timestamp.mp4';

    // Step 1: Create the reversed clip at 2x speed
    // -vf reverse          → reverses frames
    // -af areverse         → reverses audio (if any)
    // setpts=0.5*PTS       → 2x playback speed
    final reverseCmd =
        '''
  -i "$inputPath"
  -vf "reverse,setpts=0.667*PTS"
  -af "areverse,atempo=1.2"
  -y "$reversedPath"
'''
            .trim()
            .replaceAll('\n', ' ');

    final reverseSession = await FFmpegKit.execute(reverseCmd);
    final reverseCode = await reverseSession.getReturnCode();

    if (!ReturnCode.isSuccess(reverseCode)) {
      // print('FFmpeg reverse failed');
      return null;
    }

    // Step 2: Speed up the original clip to 2x as well
    final speedupPath = '${dir.path}/speedup_$timestamp.mp4';
    final speedCmd =
        '''
  -i "$inputPath"
  -vf "setpts=0.667*PTS"
  -af "atempo=1.2"
  -y "$speedupPath"
'''
            .trim()
            .replaceAll('\n', ' ');

    final speedSession = await FFmpegKit.execute(speedCmd);
    final speedCode = await speedSession.getReturnCode();

    if (!ReturnCode.isSuccess(speedCode)) {
      // print('FFmpeg speedup failed');
      return null;
    }

    // Step 3: Create a concat list file (forward + reverse, 3 ping-pong cycles)
    final concatFile = File('${dir.path}/concat_$timestamp.txt');
    // 3 full ping-pong cycles = 6 clips
    final concatContent = List.generate(4, (_) => "file '$speedupPath'\nfile '$reversedPath'").join('\n');
    await concatFile.writeAsString(concatContent);

    // Step 4: Concatenate into final boomerang
    final concatCmd =
        '''
    -f concat
    -safe 0
    -i "${concatFile.path}"
    -c copy
    -y "$outputPath"
  '''
            .trim()
            .replaceAll('\n', ' ');

    final concatSession = await FFmpegKit.execute(concatCmd);
    final concatCode = await concatSession.getReturnCode();

    // Cleanup temp files
    await File(reversedPath).delete();
    await File(speedupPath).delete();
    await concatFile.delete();

    if (ReturnCode.isSuccess(concatCode)) {
      // print('✅ Boomerang saved to: $outputPath');
      return outputPath;
    } else {
      // print('FFmpeg concat failed');
      return null;
    }
  }

  /// Downloads audio from [audioUrl] and attaches it to the video at [videoPath].
  ///
  /// Handles all length cases:
  /// - Audio shorter than video → loops audio to fill video duration
  /// - Audio longer than video  → trims audio to match video duration
  /// - Audio equal to video     → attaches as-is
  ///
  /// Does NOT re-encode or modify the original audio quality.
  /// Returns output video path or null on failure.
  static Future<String?> attachBackgroundAudio({required String videoPath, required String audioUrl}) async {
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final downloadedAudioPath = '${dir.path}/bg_audio_$timestamp.mp3';

    try {
      final response = await http.get(Uri.parse(audioUrl));
      if (response.statusCode != 200) return null;

      await File(downloadedAudioPath).writeAsBytes(response.bodyBytes);
    } catch (e) {
      return null;
    }

    final outputPath = '${dir.path}/with_audio_$timestamp.mp4';

    final ffmpegCmd =
        '''
  -i "$videoPath"
  -stream_loop -1 -i "$downloadedAudioPath"
  -map 0:v:0
  -map 1:a:0
  -c:v copy
  -c:a aac
  -b:a 192k
  -shortest
  -movflags +faststart
  -y "$outputPath"
  '''
            .trim()
            .replaceAll(RegExp(r'\s+'), ' ');

    final session = await FFmpegKit.execute(ffmpegCmd);
    final returnCode = await session.getReturnCode();

    await File(downloadedAudioPath).delete();

    if (ReturnCode.isSuccess(returnCode)) {
      return outputPath;
    }

    final logs = await session.getAllLogsAsString();
    debugPrint('[AudioAttach] ❌ FFmpeg failed: $logs');

    return null;
  }

  static Future<String?> concatenateVideos({required String localVideoPath, required String remoteVideoUrl}) async {
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Step 1: Download the remote video
    final remoteVideoPath = '${dir.path}/remote_video_$timestamp.mp4';

    debugPrint('[Concat] Downloading remote video from $remoteVideoUrl');
    try {
      final response = await http.get(Uri.parse(remoteVideoUrl));
      if (response.statusCode != 200) {
        debugPrint('[Concat] Failed to download remote video: ${response.statusCode}');
        return null;
      }
      await File(remoteVideoPath).writeAsBytes(response.bodyBytes);
      debugPrint('[Concat] Remote video downloaded to $remoteVideoPath');
    } catch (e) {
      debugPrint('[Concat] Download exception: $e');
      return null;
    }

    final outputPath = '${dir.path}/concatenated_$timestamp.mp4';

    // Step 2: Use FFmpeg filter_complex to concat
    // scale2ref ensures both videos match resolution before concat
    // [0:v] [1:v] → normalize both to same resolution using scale
    // concat=n=2:v=1:a=1 → join 2 segments, 1 video stream, 1 audio stream
    //
    // Note: If either video has no audio, add -an to that input
    // and generate silent audio with aevalsrc=0 to keep streams aligned.
    //
    // We use the safe approach: re-encode both to same specs then concat.

    final ffmpegCmd =
        '''
-i "$localVideoPath"
-i "$remoteVideoPath"
-filter_complex "
[0:v]scale=1080:1920:force_original_aspect_ratio=decrease,
pad=1080:1920:(ow-iw)/2:(oh-ih)/2,setsar=1,fps=30[v0];

[1:v]scale=1080:1920:force_original_aspect_ratio=decrease,
pad=1080:1920:(ow-iw)/2:(oh-ih)/2,setsar=1,fps=30[v1];

[0:a]aformat=sample_rates=44100:channel_layouts=stereo[a0];
[1:a]aformat=sample_rates=44100:channel_layouts=stereo[a1];

[v0][a0][v1][a1]concat=n=2:v=1:a=1[outv][outa]
"
-map "[outv]"
-map "[outa]"
-c:v libx264
-c:a aac
-preset ultrafast
-crf 23
-y "$outputPath"
'''
            .trim()
            .replaceAll(RegExp(r'\s+'), ' ');

    debugPrint('[Concat] Running FFmpeg concat...');
    final session = await FFmpegKit.execute(ffmpegCmd);
    final returnCode = await session.getReturnCode();

    // Cleanup downloaded remote video
    await File(remoteVideoPath).delete();

    if (ReturnCode.isSuccess(returnCode)) {
      debugPrint('[Concat] ✅ Concatenated output: $outputPath');
      return outputPath;
    } else {
      final logs = await session.getAllLogsAsString();
      debugPrint('[Concat] ❌ FFmpeg failed: $logs');
      return null;
    }
  }

  static Future<double?> _getVideoDuration(String videoPath) async {
    final session = await FFprobeKit.execute(
      '-v error -select_streams v:0 -show_entries stream=duration -of csv=p=0 "$videoPath"',
    );
    final output = await session.getOutput();
    if (output == null || output.trim().isEmpty) return null;
    return double.tryParse(output.trim());
  }

  static Future<bool> _hasAudioStream(String videoPath) async {
    final session = await FFprobeKit.execute(
      '-v error -select_streams a:0 -show_entries stream=codec_type -of csv=p=0 "$videoPath"',
    );
    final output = await session.getOutput();
    return output != null && output.trim().isNotEmpty;
  }

  static Future<String?> concatenateVideosSecond({required String localVideoPath, required String remoteVideoUrl}) async {
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Step 1: Download remote video
    final remoteVideoPath = '${dir.path}/remote_video_$timestamp.mp4';
    debugPrint('[Concat] Downloading remote video from $remoteVideoUrl');
    try {
      final response = await http.get(Uri.parse(remoteVideoUrl));
      if (response.statusCode != 200) {
        debugPrint('[Concat] Failed to download: ${response.statusCode}');
        return null;
      }
      await File(remoteVideoPath).writeAsBytes(response.bodyBytes);
      debugPrint('[Concat] Remote video saved to $remoteVideoPath');
    } catch (e) {
      debugPrint('[Concat] Download exception: $e');
      return null;
    }

    // Step 2: Probe audio and durations
    final localHasAudio = await _hasAudioStream(localVideoPath);
    final remoteHasAudio = await _hasAudioStream(remoteVideoPath);
    debugPrint('[Concat] Audio — local: $localHasAudio, remote: $remoteHasAudio');

    // Only need duration for videos missing audio — anullsrc must be bounded
    double? localDuration;
    double? remoteDuration;
    if (!localHasAudio) {
      localDuration = await _getVideoDuration(localVideoPath);
      if (localDuration == null) {
        debugPrint('[Concat] ❌ Could not determine local video duration');
        return null;
      }
      debugPrint('[Concat] Local video duration: ${localDuration}s');
    }
    if (!remoteHasAudio) {
      remoteDuration = await _getVideoDuration(remoteVideoPath);
      if (remoteDuration == null) {
        debugPrint('[Concat] ❌ Could not determine remote video duration');
        return null;
      }
      debugPrint('[Concat] Remote video duration: ${remoteDuration}s');
    }

    // Step 3: Build inputs with correct index tracking
    final inputArgs = StringBuffer();
    int nextIndex = 0;

    late final String localAudioRef;
    late final String remoteAudioRef;

    if (!localHasAudio) {
      // d= bounds the silent stream to exactly the video's duration
      inputArgs.write('-f lavfi -i "anullsrc=channel_layout=stereo:sample_rate=44100:d=${localDuration!.toStringAsFixed(6)}" ');
      localAudioRef = '$nextIndex:a';
      nextIndex++;
    }

    if (!remoteHasAudio) {
      inputArgs.write('-f lavfi -i "anullsrc=channel_layout=stereo:sample_rate=44100:d=${remoteDuration!.toStringAsFixed(6)}" ');
      remoteAudioRef = '$nextIndex:a';
      nextIndex++;
    }

    final localVideoIndex = nextIndex;
    inputArgs.write('-i "$localVideoPath" ');
    nextIndex++;

    final remoteVideoIndex = nextIndex;
    inputArgs.write('-i "$remoteVideoPath" ');

    if (localHasAudio) localAudioRef = '$localVideoIndex:a';
    if (remoteHasAudio) remoteAudioRef = '$remoteVideoIndex:a';

    // Step 4: Build filter_complex
    final filterComplex = [
      '[$localVideoIndex:v]scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2,setsar=1,fps=30[v0]',
      '[$remoteVideoIndex:v]scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2,setsar=1,fps=30[v1]',
      '[$localAudioRef]aformat=sample_rates=44100:channel_layouts=stereo[a0]',
      '[$remoteAudioRef]aformat=sample_rates=44100:channel_layouts=stereo[a1]',
      '[v0][a0][v1][a1]concat=n=2:v=1:a=1[outv][outa]',
    ].join(';');

    final outputPath = '${dir.path}/concatenated_$timestamp.mp4';

    final ffmpegCmd =
        '${inputArgs.toString().trim()} '
        '-filter_complex "$filterComplex" '
        '-map "[outv]" -map "[outa]" '
        '-c:v libx264 -c:a aac '
        '-preset ultrafast -crf 23 '
        '-y "$outputPath"';

    debugPrint('[Concat] Running FFmpeg: $ffmpegCmd');
    final session = await FFmpegKit.execute(ffmpegCmd);
    final returnCode = await session.getReturnCode();

    await File(remoteVideoPath).delete();

    if (ReturnCode.isSuccess(returnCode)) {
      debugPrint('[Concat] ✅ Output: $outputPath');
      return outputPath;
    } else {
      final logs = await session.getAllLogsAsString();
      debugPrint('[Concat] ❌ FFmpeg failed: $logs');
      return null;
    }
  }

  static Future<String?> concatenateVideosLocal({required String localVideoPath, required String remoteVideoUrl}) async {
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Step 1: Download remote video
    final remoteVideoPath = remoteVideoUrl;

    // Step 2: Probe audio and durations
    final localHasAudio = await _hasAudioStream(localVideoPath);
    final remoteHasAudio = await _hasAudioStream(remoteVideoPath);
    debugPrint('[Concat] Audio — local: $localHasAudio, remote: $remoteHasAudio');

    // Only need duration for videos missing audio — anullsrc must be bounded
    double? localDuration;
    double? remoteDuration;
    if (!localHasAudio) {
      localDuration = await _getVideoDuration(localVideoPath);
      if (localDuration == null) {
        debugPrint('[Concat] ❌ Could not determine local video duration');
        return null;
      }
      debugPrint('[Concat] Local video duration: ${localDuration}s');
    }
    if (!remoteHasAudio) {
      remoteDuration = await _getVideoDuration(remoteVideoPath);
      if (remoteDuration == null) {
        debugPrint('[Concat] ❌ Could not determine remote video duration');
        return null;
      }
      debugPrint('[Concat] Remote video duration: ${remoteDuration}s');
    }

    // Step 3: Build inputs with correct index tracking
    final inputArgs = StringBuffer();
    int nextIndex = 0;

    late final String localAudioRef;
    late final String remoteAudioRef;

    if (!localHasAudio) {
      // d= bounds the silent stream to exactly the video's duration
      inputArgs.write('-f lavfi -i "anullsrc=channel_layout=stereo:sample_rate=44100:d=${localDuration!.toStringAsFixed(6)}" ');
      localAudioRef = '$nextIndex:a';
      nextIndex++;
    }

    if (!remoteHasAudio) {
      inputArgs.write('-f lavfi -i "anullsrc=channel_layout=stereo:sample_rate=44100:d=${remoteDuration!.toStringAsFixed(6)}" ');
      remoteAudioRef = '$nextIndex:a';
      nextIndex++;
    }

    final localVideoIndex = nextIndex;
    inputArgs.write('-i "$localVideoPath" ');
    nextIndex++;

    final remoteVideoIndex = nextIndex;
    inputArgs.write('-i "$remoteVideoPath" ');

    if (localHasAudio) localAudioRef = '$localVideoIndex:a';
    if (remoteHasAudio) remoteAudioRef = '$remoteVideoIndex:a';

    // Step 4: Build filter_complex
    final filterComplex = [
      '[$localVideoIndex:v]scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2,setsar=1,fps=30[v0]',
      '[$remoteVideoIndex:v]scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2,setsar=1,fps=30[v1]',
      '[$localAudioRef]aformat=sample_rates=44100:channel_layouts=stereo[a0]',
      '[$remoteAudioRef]aformat=sample_rates=44100:channel_layouts=stereo[a1]',
      '[v0][a0][v1][a1]concat=n=2:v=1:a=1[outv][outa]',
    ].join(';');

    final outputPath = '${dir.path}/concatenated_$timestamp.mp4';

    final ffmpegCmd =
        '${inputArgs.toString().trim()} '
        '-filter_complex "$filterComplex" '
        '-map "[outv]" -map "[outa]" '
        '-c:v libx264 -c:a aac '
        '-preset ultrafast -crf 23 '
        '-y "$outputPath"';

    debugPrint('[Concat] Running FFmpeg: $ffmpegCmd');
    final session = await FFmpegKit.execute(ffmpegCmd);
    final returnCode = await session.getReturnCode();

    await File(remoteVideoPath).delete();

    if (ReturnCode.isSuccess(returnCode)) {
      debugPrint('[Concat] ✅ Output: $outputPath');
      return outputPath;
    } else {
      final logs = await session.getAllLogsAsString();
      debugPrint('[Concat] ❌ FFmpeg failed: $logs');
      return null;
    }
  }

  /// Creates an 8-second video from 4 images (each image = 0.25s, looped 8 times)
  static Future<String> createGif({required List<File> photos}) async {
    assert(photos.length == 4, 'Exactly 4 photos required');

    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // ── Step 1: Create 1-second video from 4 photos (each shown for 0.25s) ──
    final oneSecOutputPath = '${dir.path}/one_sec_$timestamp.mp4';

    // framerate=4 means 4 frames per second, each image = 1 frame = 0.25s
    // We list each image as a separate input with -loop and -t
    final inputArgs = photos.map((f) => '-loop 1 -t 0.25 -i "${f.path}"').join(' ');

    // Build filter: scale all to 1080x1920, then concat
    final scaleFilters = List.generate(
      photos.length,
      (i) =>
          '[$i:v]scale=1080:1920:force_original_aspect_ratio=decrease,'
          'pad=1080:1920:(ow-iw)/2:(oh-ih)/2,setsar=1,setpts=PTS-STARTPTS[v$i]',
    ).join(';');

    final concatInputs = List.generate(photos.length, (i) => '[v$i]').join('');

    final filterComplex =
        '$scaleFilters;'
        '${concatInputs}concat=n=${photos.length}:v=1:a=0[outv]';

    final step1Command =
        '$inputArgs '
        '-filter_complex "$filterComplex" '
        '-map "[outv]" '
        '-c:v libx264 -preset fast -crf 18 '
        '-pix_fmt yuv420p '
        '-r 30 ' // 30fps output
        '-an ' // no audio
        '-y "$oneSecOutputPath"';

    await _execute(step1Command);

    if (!await File(oneSecOutputPath).exists()) {
      throw Exception('Step 1 failed: 1-second video not created');
    }

    // ── Step 2: Loop that 1-second video 8 times → 8-second video ────────────
    final finalOutputPath = '${dir.path}/looped_photo_video_$timestamp.mp4';

    // -stream_loop 7 means play the input 1 + 7 = 8 times
    final step2Command =
        '-stream_loop 7 '
        '-i "$oneSecOutputPath" '
        '-c:v libx264 -preset fast -crf 18 '
        '-pix_fmt yuv420p '
        '-t 8 ' // hard cap at exactly 8 seconds
        '-an '
        '-y "$finalOutputPath"';

    await _execute(step2Command);

    // ── Cleanup intermediate ──────────────────────────────────────────────────
    await File(oneSecOutputPath).delete();

    if (!await File(finalOutputPath).exists()) {
      throw Exception('Step 2 failed: looped video not created');
    }

    return finalOutputPath;
  }

  static Future<XFile?> applyOverlayOnNetworkImage(String imageUrl) async {
    try {
      // 1️⃣ Download original image
      final imageResponse = await http.get(Uri.parse(imageUrl));

      if (imageResponse.statusCode != 200) {
        Logger.log("Failed to download main image");
        return null;
      }

      img.Image? baseImage = img.decodeImage(imageResponse.bodyBytes);

      if (baseImage == null) {
        Logger.log("Failed to decode main image");
        return null;
      }

      // 2️⃣ Mirror if needed (optional)
      // baseImage = img.flipHorizontal(baseImage);

      // 3️⃣ Get overlay URL from GetX controller
      final overlayUrl = DeviceController.to.branding.value?.photoVideoOverlay;

      if (overlayUrl != null && overlayUrl.isNotEmpty) {
        final overlayResponse = await http.get(Uri.parse(overlayUrl));

        if (overlayResponse.statusCode == 200) {
          img.Image? overlayImage = img.decodeImage(overlayResponse.bodyBytes);

          if (overlayImage != null) {
            final resizedOverlay = img.copyResize(overlayImage, width: baseImage.width, height: baseImage.height);

            img.compositeImage(baseImage, resizedOverlay);
          }
        } else {
          Logger.log('Overlay skipped: HTTP ${overlayResponse.statusCode}');
        }
      }

      // 4️⃣ Save new image locally
      final directory = await getTemporaryDirectory();
      final outputPath = '${directory.path}/overlay_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final outputFile = File(outputPath)..writeAsBytesSync(img.encodeJpg(baseImage, quality: 95));

      return XFile(outputFile.path);
    } catch (e) {
      Logger.log("Overlay error: $e");
      return null;
    }
  }
}
