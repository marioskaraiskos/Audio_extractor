// lib/youtube_downloader.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

// Platform-specific download implementation
import 'download_server.dart';



class YouTubeDownloader extends StatefulWidget {
  const YouTubeDownloader({super.key});

  @override
  State<YouTubeDownloader> createState() => _YouTubeDownloaderState();
}

class _YouTubeDownloaderState extends State<YouTubeDownloader> {
  final TextEditingController _controller = TextEditingController();
  bool _isDownloading = false;
  double _progress = 0.0;
  String _status = '';
  String? _selectedDirectory;

  // Folder selection (only works on desktop/mobile)
  Future<void> _pickFolder() async {
    if (kIsWeb) {
      setState(() => _status = '⚠️ Folder selection not supported on Web.');
      return;
    }

    final dirPath = await FilePicker.platform.getDirectoryPath();
    if (dirPath != null) {
      setState(() {
        _selectedDirectory = dirPath;
        _status = '📁 Selected folder: $dirPath';
      });
    }
  }

  // Download audio using platform-specific implementation
  Future<void> _downloadAudio() async {
    final link = _controller.text.trim();
    if (link.isEmpty) {
      setState(() => _status = '⚠️ Please enter a valid YouTube link.');
      return;
    }

    setState(() {
      _isDownloading = true;
      _progress = 0;
      _status = 'Initializing download...';
    });

    try {
      await platformDownloadAudio(
        link,
        _selectedDirectory,
        (progress) => setState(() => _progress = progress),
        (status) => setState(() => _status = status),
      );
    } catch (e) {
      setState(() => _status = '❌ Error: $e');
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('YouTube Audio Downloader')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'https://www.youtube.com/watch?v=...',
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickFolder,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Choose Folder'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _isDownloading ? null : _downloadAudio,
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                ),
              ],
            ),
            const SizedBox(height: 25),
            if (_isDownloading)
              Column(
                children: [
                  LinearProgressIndicator(value: _progress),
                  const SizedBox(height: 8),
                  Text('${(_progress * 100).toStringAsFixed(1)}%'),
                ],
              ),
            const SizedBox(height: 20),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
