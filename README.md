# Audio Extractor

Audio Extractor is a **cross-platform Flutter application** that allows you to download audio from YouTube, TikTok, Instagram, and many other platforms. It works seamlessly on **Windows, macOS, Linux, Android, iOS, and Web**, making it easy to save your favorite music, podcasts, shorts, or any audio content directly to your device.

---

## Features

- 🎵 **Download audio from multiple platforms:** YouTube, TikTok, Instagram, and more.
- 💻 **Cross-platform support:** Works on Android, iOS, Windows, macOS, Linux, and the web.
- ⚡ **Fast and efficient:** Uses a server-side backend for consistent performance across all devices.
- 🏷️ **Preserves original titles:** Downloads audio files with the original video title.
- 🔄 **Real-time progress updates:** Shows download progress and status.
- 🛠️ **Custom storage location:** Save audio files to a folder of your choice.

---


## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Python 3](https://www.python.org/downloads/) (for the backend server)
- [FFmpeg](https://ffmpeg.org/download.html) and `ffprobe` (for audio processing)

---

### Installation

1. **Clone the repository:**

```bash
git clone https://github.com/marioskaraiskos/Audio_extractor.git
cd Audio_extractor


2. **Install Flutter dependencies:**

flutter pub get

3. **Setup Backend Server**

python -m venv venv
source venv/Scripts/activate  # Windows
pip install -r requirements.txt  # or pip install fastapi uvicorn yt-dlp
uvicorn server:app --reload

4. **Run the App**

flutter run

