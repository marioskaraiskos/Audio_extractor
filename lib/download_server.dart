import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

typedef ProgressCallback = void Function(double progress);
typedef StatusCallback = void Function(String status);

Future<void> platformDownloadAudio(
  String youtubeUrl,
  String? directory,
  ProgressCallback onProgress,
  StatusCallback onStatus,
) async {
  try {
    // Determine server URL depending on platform
    final serverBase = kIsWeb
        ? 'http://127.0.0.1:8000' // web uses localhost
        : Platform.isAndroid
            ? 'http://10.0.2.2:8000' // Android emulator
            : 'http://127.0.0.1:8000'; // desktop & iOS simulator

    final uri = Uri.parse('$serverBase/download?url=$youtubeUrl');

    onStatus('Downloading from server...');

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      onStatus('❌ Server error: ${response.statusCode}');
      return;
    }

    // Determine save directory
    Directory saveDir;
    if (directory != null) {
      saveDir = Directory(directory);
    } else {
      saveDir = await getApplicationDocumentsDirectory();
      onStatus('⚠️ No folder selected. Using: ${saveDir.path}');
    }

    // Save the file
    final filePath = '${saveDir.path}/${youtubeUrl.hashCode}.mp3';
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    onProgress(1.0);
    onStatus('✅ Download complete: $filePath');
  } catch (e) {
    onStatus('❌ Download error: $e');
  }
}
