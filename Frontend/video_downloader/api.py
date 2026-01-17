# api.py - FIXED VERSION
import yt_dlp
from flask import Flask, request, jsonify, Response
from flask_cors import CORS
import subprocess
import json
import requests

app = Flask(__name__)
CORS(app)


@app.route('/extract-video', methods=['POST'])
def extract_video():
    data = request.get_json()
    url = data.get("url")

    if not url:
        return jsonify({"error": "No URL provided"}), 400

    try:
        ydl_opts = {
            "quiet": True,
            "skip_download": True,
            "no_warnings": True,
            "extract_flat": False,
        }

        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=False)

        videos = []
        seen_urls = set()  # avoid duplicates

        for f in info.get("formats", []):
            # skip audio-only formats
            if f.get("vcodec") == "none":
                continue

            format_url = f.get("url", "")
            if format_url in seen_urls:
                continue
            seen_urls.add(format_url)

            # 1️⃣ Try yt-dlp metadata
            filesize = f.get("filesize") or f.get("filesize_approx") or f.get("filesize_raw")

            # # 2️⃣ HEAD request for direct MP4s
            # if not filesize and format_url.endswith(".mp4"):
            #     try:
            #         r = requests.head(
            #             format_url,
            #             allow_redirects=True,
            #             timeout=5,
            #             headers={"User-Agent": "Mozilla/5.0"}
            #         )
            #         content_length = r.headers.get("Content-Length")
            #         if content_length:
            #             filesize = int(content_length)
            #     except:
            #         pass

            # 3️⃣ Estimate from tbr * duration
            tbr = f.get("tbr") or f.get("vbr") or f.get("abr")
            duration = info.get("duration")
            if not filesize and tbr and duration:
                filesize = int((tbr * 1000 / 8) * duration)

            # 4️⃣ Fallback: estimate using resolution → average bitrate table
            height = f.get('height', 0)
            if not filesize and duration and height:
                bitrate_map = {
                    2160: 16000, 1440: 8000, 1080: 5000,
                    720: 2500, 480: 1200, 360: 700, 240: 400
                }
                br = bitrate_map.get(height)
                if br:
                    filesize = int((br * 1000 / 8) * duration)

            # Format filesize for frontend
            if filesize:
                size_str = f"{filesize / (1024*1024):.1f} MB"

            else:
                size_str = "Unknown size"

            # Duration formatting
            if duration:
                minutes = int(duration // 60)
                seconds = int(duration % 60)
                duration_str = f"{minutes}:{seconds:02d}"
            else:
                duration_str = "Unknown"

            # Resolution and quality
            width = f.get('width', 0)
            if height:
                quality = f"{height}p"
            elif width:
                approx_height = int(width * 9 / 16)
                quality = f"{approx_height}p"
            else:
                quality = "Unknown"

            # Codec info
            vcodec = f.get('vcodec', '')
            if 'av1' in vcodec.lower():
                codec_info = 'AV1'
            elif 'h264' in vcodec.lower() or 'avc' in vcodec.lower():
                codec_info = 'H264'
            elif 'vp9' in vcodec.lower():
                codec_info = 'VP9'
            else:
                codec_info = vcodec.split('.')[0] if vcodec else ''

            # Format type
            if '.m3u8' in format_url:
                format_type = 'HLS'
            elif '.mpd' in format_url:
                format_type = 'DASH'
            else:
                format_type = 'Direct'

            videos.append({
                "url": format_url,
                "format_id": f.get("format_id", ""),
                "quality": quality,
                "resolution": f"{width}x{height}" if width and height else "Unknown",
                "size": size_str,
                "filesize_bytes": filesize,
                "duration": duration_str,
                "codec": codec_info,
                "format_type": format_type,
                "ext": f.get('ext', ''),
                "fps": f.get('fps', 0),
                "has_audio": f.get('acodec') != 'none',
            })

        # Sort by quality -> prefer direct -> largest size
        def sort_key(video):
            q = video["quality"]
            try:
                q_num = int(q[:-1]) if q.endswith("p") else 0
            except:
                q_num = 0
            fmt_priority = 0 if video["format_type"] == "Direct" else 1
            return (q_num, fmt_priority, -(video["filesize_bytes"] or 0))

        videos.sort(key=sort_key, reverse=True)

        # Group by quality and deduplicate further
        unique_videos = []
        seen_qualities = set()

        for video in videos:
            quality_key = f"{video['quality']}_{video['codec']}_{video['format_type']}"

            # Only add if we haven't seen this quality/codec/type combination
            if quality_key not in seen_qualities:
                seen_qualities.add(quality_key)
                unique_videos.append(video)

        return jsonify({
            "success": True,
            "title": info.get("title", "Unknown Title"),
            "url": url,
            "thumbnail": info.get("thumbnail", ""),
            "description": info.get("description", ""),
            "uploader": info.get("uploader", ""),
            "duration_seconds": duration or 0,
            "view_count": info.get("view_count", 0),
            "like_count": info.get("like_count", 0),
            "downloadable_videos": unique_videos,
        })

    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e),
            "downloadable_videos": []
        }), 500


@app.route("/stream-download", methods=["POST"])
def stream_download():
    try:
        data = request.get_json()
        url = data["url"]
        format_id = data["format_id"]

        ydl_opts = {"quiet": True, "skip_download": True}
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=False)

        selected = None
        for f in info["formats"]:
            if f.get("format_id") == format_id:
                selected = f
                break

        if not selected:
            return jsonify({"error": "Format not found"}), 400

        video_url = selected["url"]
        title = info.get("title", "video").replace(" ", "_")

        # Remove invalid characters from filename
        import re
        title = re.sub(r'[<>:"/\\|?*]', '', title)

        is_stream = ".m3u8" in video_url or ".mpd" in video_url

        def generate():
            # Universal command that works for most codecs
            # It will automatically handle codec compatibility
            cmd = [
                "ffmpeg",
                "-i", video_url,
                "-movflags", "+faststart+frag_keyframe",
                "-f", "mp4",
                "-c:v", "libx264",  # Always encode to H264 for compatibility
                "-preset", "veryfast",  # Fast encoding
                "-crf", "24",  # Good quality
                "-c:a", "aac",  # Always encode audio to AAC
                "-b:a", "128k",  # Good audio bitrate
                "-ar", "44100",  # Standard sample rate
                "-max_muxing_queue_size", "9999",  # Prevent muxing errors
                "pipe:1"
            ]

            print(f"Running FFmpeg command for: {title}")

            process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                bufsize=10 ** 6
            )

            # Read and print stderr in background
            import threading
            stderr_lines = []

            def capture_stderr():
                for line in iter(process.stderr.readline, b''):
                    line_str = line.decode().strip()
                    stderr_lines.append(line_str)
                    # Print progress information
                    if 'frame=' in line_str and 'fps=' in line_str:
                        print(f"FFmpeg progress: {line_str}")

            stderr_thread = threading.Thread(target=capture_stderr)
            stderr_thread.daemon = True
            stderr_thread.start()

            # Stream output
            try:
                while True:
                    chunk = process.stdout.read(65536)  # 64KB chunks
                    if not chunk:
                        break
                    yield chunk
            finally:
                # Clean up
                process.stdout.close()
                process.wait()

                # Check for errors
                if process.returncode != 0:
                    print(f"FFmpeg failed with code {process.returncode}")
                    print("Last 10 stderr lines:")
                    for line in stderr_lines[-10:]:
                        print(f"  {line}")

        headers = {
            "Content-Disposition": f'attachment; filename="{title}.mp4"',
            "Content-Type": "video/mp4"
        }

        return Response(generate(), headers=headers)

    except Exception as e:
        print(f"Error in stream-download: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500


@app.route('/')
def home():
    return jsonify({
        "status": "online",
        "message": "Video Downloader Backend is running",
        "endpoints": {
            "POST /extract-video": "Extract video info from URL",
            "POST /stream-download": "Stream download video",
            "GET /": "Health check"
        }
    })


if __name__ == '__main__':
    print("Starting Video Downloader Backend on http://0.0.0.0:5000")
    print("Make sure ffmpeg is installed and in PATH")
    app.run(debug=True, host='0.0.0.0', port=5000)