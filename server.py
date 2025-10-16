# server.py
from fastapi import FastAPI, Query, HTTPException
from fastapi.responses import FileResponse
import yt_dlp
import tempfile
import os

app = FastAPI()

@app.get("/download")
def download_audio(url: str = Query(..., description="YouTube video URL")):
    if not url.startswith("http"):
        raise HTTPException(status_code=400, detail="Invalid URL")

    # Create a temporary file to store the MP3
    temp_dir = tempfile.mkdtemp()
    output_path = os.path.join(temp_dir, "%(title)s.%(ext)s")

    ydl_opts = {
        "format": "bestaudio/best",
        "outtmpl": output_path,
        "postprocessors": [{
            "key": "FFmpegExtractAudio",
            "preferredcodec": "mp3",
            "preferredquality": "192",
        }],
        "quiet": True,
    }

    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url)
            filename = ydl.prepare_filename(info).replace(".webm", ".mp3").replace(".m4a", ".mp3")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Download failed: {e}")

    if not os.path.exists(filename):
        raise HTTPException(status_code=500, detail="File not found after download")

    return FileResponse(filename, media_type="audio/mpeg", filename=os.path.basename(filename))
