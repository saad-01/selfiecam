import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class SpeedTest extends StatefulWidget {
  const SpeedTest({super.key});

  @override
  State<SpeedTest> createState() => _SpeedTestState();
}

class _SpeedTestState extends State<SpeedTest> {
  String uploadResult = 'Ready to analyze upload performance';
  bool testingUpload = false;
  bool showResults = false;

  Future<void> _runUploadTest() async {
    // Reset state if button is pressed again
    setState(() {
      testingUpload = true;
      showResults = false;
      uploadResult = 'Uploading sample data...';
    });

    const url = 'https://speed.cloudflare.com/__upl';
    final data = _generateTestData(5 * 1024 * 1024); // 5 MB
    final stopwatch = Stopwatch()..start();

    try {
      final request = await HttpClient().postUrl(Uri.parse(url))
        ..headers.set(HttpHeaders.contentTypeHeader, 'application/octet-stream')
        ..add(data);

      final response = await request.close();
      await response.drain();

      stopwatch.stop();
      final seconds = stopwatch.elapsedMilliseconds / 1000;
      final speedMbps = (data.length * 8) / (seconds * 1000000);

      setState(() {
        uploadResult = 'Upload Speed: ${speedMbps.toStringAsFixed(2)} Mbps';
        showResults = true;
      });
    } catch (e) {
      setState(() {
        uploadResult = 'Upload failed. Please check connection.';
        showResults = false;
      });
    } finally {
      setState(() {
        testingUpload = false;
      });
    }
  }

  Uint8List _generateTestData(int byteCount) {
    final rand = Random();
    return Uint8List.fromList(List<int>.generate(byteCount, (_) => rand.nextInt(256)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Network Diagnostics', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600), // Better for iPad
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.upload_rounded, size: 80, color: testingUpload ? Colors.blue : Colors.grey[400]),
                const SizedBox(height: 24),
                Text(
                  uploadResult,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: Colors.blueGrey[800], fontWeight: FontWeight.w500, fontSize: 30),
                ),
                if (showResults) ...[
                  const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider()),
                  const Text(
                    'Test Completed Successfully',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                  const SizedBox(height: 12),
                  _buildMetricRow('Selfies', '5 uploads per min'),
                  _buildMetricRow('Video', '3 uploads per min'),
                  _buildMetricRow('Loop', '3 uploads per min'),
                ],
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: FilledButton.tonal(
                    onPressed: testingUpload ? null : _runUploadTest,
                    style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: testingUpload
                        ? const CircularProgressIndicator.adaptive()
                        : const Text('Start Upload Test', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 25)),
          Text(value, style: const TextStyle(fontSize: 25)),
        ],
      ),
    );
  }
}
