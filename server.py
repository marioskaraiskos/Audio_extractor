# server.py
from fastapi import FastAPI, Query, HTTPException, BackgroundTasks
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
import yt_dlp
import tempfile
import os
import shutil
import re
import logging

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()

# Allow all origins (development)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def sanitize_filename(name: str) -> str:
    # Replace invalid filename characters with underscores
    return re.sub(r'[<>:"/\\|?*]', '_', name)

def cleanup_temp_dir(temp_dir: str):
    """Background task to cleanup temporary directory"""
    try:
        if os.path.exists(temp_dir):
            shutil.rmtree(temp_dir, ignore_errors=True)
            logger.info(f"Cleaned up temp directory: {temp_dir}")
    except Exception as e:
        logger.error(f"Error cleaning up temp directory: {e}")

@app.get("/")
def root():
    return {"status": "YouTube Downloader API is running"}

@app.get("/download")
def download_audio(
    url: str = Query(..., description="YouTube video URL"),
    background_tasks: BackgroundTasks = None
):
    if not url.startswith("http"):
        raise HTTPException(status_code=400, detail="Invalid URL")

    temp_dir = tempfile.mkdtemp()
    logger.info(f"Created temp directory: {temp_dir}")
    
    output_template = os.path.join(temp_dir, "%(title)s.%(ext)s")

    ydl_opts = {
        "format": "bestaudio/best",
        "outtmpl": output_template,
        "postprocessors": [{
            "key": "FFmpegExtractAudio",
            "preferredcodec": "mp3",
            "preferredquality": "192",
        }],
        "quiet": False,  # Set to False to see errors
        "noplaylist": True,
        "extract_flat": False,
        "no_warnings": False,
    }

    try:
        logger.info(f"Downloading from URL: {url}")
        
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=True)
            title = info.get("title") or "Unknown Title"
            logger.info(f"✅ Extracted Title: {title}")

            # Construct the expected filename
            filename = ydl.prepare_filename(info)
            filename = os.path.splitext(filename)[0] + ".mp3"
            
            logger.info(f"Expected file path: {filename}")

            if not os.path.exists(filename):
                # Try to find any .mp3 file in temp_dir
                mp3_files = [f for f in os.listdir(temp_dir) if f.endswith('.mp3')]
                if mp3_files:
                    filename = os.path.join(temp_dir, mp3_files[0])
                    logger.info(f"Found alternative file: {filename}")
                else:
                    logger.error(f"No MP3 file found in {temp_dir}")
                    raise HTTPException(
                        status_code=500, 
                        detail="File not found after download. FFmpeg may not be installed."
                    )

    except yt_dlp.utils.DownloadError as e:
        logger.error(f"yt-dlp error: {str(e)}")
        shutil.rmtree(temp_dir, ignore_errors=True)
        raise HTTPException(
            status_code=500, 
            detail=f"Download failed: {str(e)}. Make sure FFmpeg is installed."
        )
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        shutil.rmtree(temp_dir, ignore_errors=True)
        raise HTTPException(status_code=500, detail=f"Download failed: {str(e)}")

    # Schedule cleanup after response is sent
    if background_tasks:
        background_tasks.add_task(cleanup_temp_dir, temp_dir)
    else:
        logger.warning("BackgroundTasks not available, cleanup may not occur")

    # Return file with title header
    sanitized_title = sanitize_filename(title)
    response = FileResponse(
        filename,
        media_type="audio/mpeg",
        filename=f"{sanitized_title}.mp3",
    )
    response.headers["X-Video-Title"] = sanitized_title
    response.headers["Access-Control-Expose-Headers"] = "X-Video-Title"
    
    logger.info(f"Sending file with title: {sanitized_title}")
    
    return response