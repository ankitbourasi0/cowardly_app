@echo off
set /p input="Enter input video file path: "
set /p output="Enter output file name (without .mp4): "

ffmpeg -i "%input%" -c:v libx264 -preset fast -crf 23 -c:a aac -b:a 128k -movflags +faststart "%output%.mp4"

echo.
echo ✅ Video encoding complete! Saved as %output%.mp4
pause
