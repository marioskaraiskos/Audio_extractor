import 'package:flutter/material.dart';
import 'youtube_downloader.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Audio Downloader',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const YouTubeDownloader(),
      debugShowCheckedModeBanner: false,
    );
  }
}
