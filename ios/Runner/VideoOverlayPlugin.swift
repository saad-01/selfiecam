// ios/Runner/VideoOverlayPlugin.swift

import AVFoundation
import UIKit
import Flutter

public class VideoOverlayPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.yourapp/video_overlay",
      binaryMessenger: registrar.messenger()
    )
    let instance = VideoOverlayPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "applyOverlay",
          let args = call.arguments as? [String: String],
          let videoPath = args["videoPath"],
          let overlayPath = args["overlayPath"]
    else {
      result(FlutterError(code: "BAD_ARGS", message: "Missing arguments", details: nil))
      return
    }

    applyOverlay(videoPath: videoPath, overlayPath: overlayPath, result: result)
  }

  private func applyOverlay(videoPath: String, overlayPath: String, result: @escaping FlutterResult) {
    let videoURL = URL(fileURLWithPath: videoPath)
    let asset = AVURLAsset(url: videoURL)

    guard let overlayImage = UIImage(contentsOfFile: overlayPath),
          let track = asset.tracks(withMediaType: .video).first
    else {
      result(FlutterError(code: "LOAD_FAILED", message: "Could not load video or overlay", details: nil))
      return
    }

    let videoSize = track.naturalSize.applying(track.preferredTransform)
    let size = CGSize(width: abs(videoSize.width), height: abs(videoSize.height))

    // ─── Build overlay layer ───────────────────────────────────────────────
    let overlayLayer = CALayer()
    overlayLayer.contents = overlayImage.cgImage
    overlayLayer.frame = CGRect(origin: .zero, size: size)
    overlayLayer.contentsGravity = .resizeAspectFill

    let videoLayer = CALayer()
    videoLayer.frame = CGRect(origin: .zero, size: size)

    let parentLayer = CALayer()
    parentLayer.frame = CGRect(origin: .zero, size: size)
    parentLayer.addSublayer(videoLayer)
    parentLayer.addSublayer(overlayLayer)

    // ─── Composition ──────────────────────────────────────────────────────
    let composition = AVMutableComposition()
    guard
      let compositionTrack = composition.addMutableTrack(
        withMediaType: .video,
        preferredTrackID: kCMPersistentTrackID_Invalid
      )
    else {
      result(FlutterError(code: "COMP_FAILED", message: "Could not create composition track", details: nil))
      return
    }

    do {
      try compositionTrack.insertTimeRange(
        CMTimeRange(start: .zero, duration: asset.duration),
        of: track,
        at: .zero
      )
    } catch {
      result(FlutterError(code: "INSERT_FAILED", message: error.localizedDescription, details: nil))
      return
    }

    // ─── Video composition with overlay ───────────────────────────────────
    let videoComposition = AVMutableVideoComposition()
    videoComposition.renderSize = size
    videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
    videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(
      postProcessingAsVideoLayer: videoLayer,
      in: parentLayer
    )

    let instruction = AVMutableVideoCompositionInstruction()
    instruction.timeRange = CMTimeRange(start: .zero, duration: asset.duration)

    let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionTrack)

    // ✅ Fix rotation — handles iPhone/iPad rotation metadata
    var transform = track.preferredTransform
    layerInstruction.setTransform(transform, at: .zero)
    instruction.layerInstructions = [layerInstruction]
    videoComposition.instructions = [instruction]

    // ─── Export ───────────────────────────────────────────────────────────
    let outputDir = NSTemporaryDirectory()
    let outputPath = "\(outputDir)overlay_\(Int(Date().timeIntervalSince1970)).mp4"
    let outputURL = URL(fileURLWithPath: outputPath)

    guard let exporter = AVAssetExportSession(
      asset: composition,
      presetName: AVAssetExportPresetHighestQuality
    ) else {
      result(FlutterError(code: "EXPORT_FAILED", message: "Could not create export session", details: nil))
      return
    }

    exporter.outputURL = outputURL
    exporter.outputFileType = .mp4
    exporter.videoComposition = videoComposition
    exporter.shouldOptimizeForNetworkUse = true

    exporter.exportAsynchronously {
      DispatchQueue.main.async {
        switch exporter.status {
        case .completed:
          result(outputPath)
        case .failed:
          result(FlutterError(
            code: "EXPORT_FAILED",
            message: exporter.error?.localizedDescription ?? "Unknown error",
            details: nil
          ))
        default:
          result(FlutterError(code: "EXPORT_CANCELLED", message: "Export cancelled", details: nil))
        }
      }
    }
  }
}