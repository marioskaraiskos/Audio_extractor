// download_mobile.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

typedef ProgressCallback = void Function(double progress);
typedef StatusCallback = void Function(String status);

Future<void> downloadFile(
  Uint8List bytes,
  String filename,
  String? directory,
  ProgressCallback onProgress,
  StatusCallback onStatus,
) async {
  // Mobile/Desktop: Save to file system
  Directory saveDir;
  
  if (directory != null) {
    saveDir = Directory(directory);
  } else {
    saveDir = await getApplicationDocumentsDirectory();
    onStatus('⚠️ No folder selected. Using: ${saveDir.path}');
  }

  final filePath = '${saveDir.path}${Platform.pathSeparator}$filename';
  final file = File(filePath);
  await file.writeAsBytes(bytes);

  onProgress(1.0);
  onStatus('✅ Download complete: $filePath');
}