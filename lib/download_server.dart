// lib/download_server.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Get the correct server URL based on platform
String getServerUrl() {
  if (kIsWeb) {
    return 'http://localhost:8000';
  } else if (Platform.isAndroid) {
    // For Android Emulator, use 10.0.2.2
    // For physical device, replace with your computer's IP (e.g., '192.168.1.100')
    return 'http://10.0.2.2:8000';
  } else {
    // For iOS, Windows, macOS, Linux
    return 'http://localhost:8000';
  }
}

/// Request storage permissions on Android
Future<bool> requestStoragePermission() async {
  if (!Platform.isAndroid) return true;

  if (await Permission.storage.isGranted) {
    return true;
  }

  // For Android 13+ (API 33+), use photos/videos/audio permissions
  if (await Permission.photos.isGranted || 
      await Permission.videos.isGranted || 
      await Permission.audio.isGranted) {
    return true;
  }

  final status = await Permission.storage.request();
  if (status.isGranted) return true;

  // Try requesting specific media permissions for Android 13+
  final Map<Permission, PermissionStatus> statuses = await [
    Permission.photos,
    Permission.videos,
    Permission.audio,
  ].request();

  return statuses.values.any((status) => status.isGranted);
}

/// Platform-specific download implementation
Future<void> platformDownloadAudio(
  String url,
  String? selectedDirectory,
  Function(double) onProgress,
  Function(String) onStatus,
) async {
  try {
    final serverUrl = getServerUrl();
    onStatus('🔗 Connecting to server: $serverUrl');

    // Request permissions on Android
    if (Platform.isAndroid) {
      onStatus('📱 Requesting storage permissions...');
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied. Please grant permission in app settings.');
      }
    }

    // Build the download URL
    final downloadUrl = '$serverUrl/download?url=${Uri.encodeComponent(url)}';
    onStatus('⬇️ Downloading from YouTube...');

    // Make the HTTP request
    final response = await http.get(Uri.parse(downloadUrl));

    if (response.statusCode != 200) {
      throw Exception('Server returned status ${response.statusCode}: ${response.body}');
    }

    onProgress(0.5);
    onStatus('💾 Saving file...');

    // Get the filename from headers
    String filename = 'audio.mp3';
    if (response.headers.containsKey('x-video-title')) {
      filename = '${response.headers['x-video-title']}.mp3';
    } else if (response.headers.containsKey('content-disposition')) {
      final disposition = response.headers['content-disposition']!;
      final match = RegExp(r'filename="?([^"]+)"?').firstMatch(disposition);
      if (match != null) filename = match.group(1)!;
    }

    // Determine save location
    String savePath;
    if (kIsWeb) {
      // Web platform - trigger browser download
      throw UnimplementedError('Web download should use download_web.dart');
    } else if (Platform.isAndroid) {
      // Android - save to Downloads folder
      final directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        // Fallback to app's external storage
        final fallbackDir = await getExternalStorageDirectory();
        savePath = '${fallbackDir!.path}/$filename';
      } else {
        savePath = '${directory.path}/$filename';
      }
    } else if (selectedDirectory != null) {
      // Desktop/iOS with selected directory
      savePath = '$selectedDirectory/$filename';
    } else {
      // Fallback to downloads directory
      final directory = await getDownloadsDirectory() ?? 
                       await getApplicationDocumentsDirectory();
      savePath = '${directory.path}/$filename';
    }

    // Write the file
    final file = File(savePath);
    await file.writeAsBytes(response.bodyBytes);

    onProgress(1.0);
    onStatus('✅ Downloaded successfully!\n📁 Saved to: $savePath');
  } catch (e) {
    onStatus('❌ Download Error: $e');
    rethrow;
  }
}