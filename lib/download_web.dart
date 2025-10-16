// download_web.dart
import 'dart:html' as html;
import 'dart:typed_data';

typedef ProgressCallback = void Function(double progress);
typedef StatusCallback = void Function(String status);

Future<void> downloadFile(
  Uint8List bytes,
  String filename,
  String? directory,
  ProgressCallback onProgress,
  StatusCallback onStatus,
) async {
  // Web: Trigger browser download
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
  
  onProgress(1.0);
  onStatus('✅ Download complete: $filename');
}