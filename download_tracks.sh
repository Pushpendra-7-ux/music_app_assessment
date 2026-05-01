#!/bin/bash
# Download free royalty-free music for the Music App
# Source: Free sample audio from public CDNs

AUDIO_DIR="/Users/pushpendrasuryawanshi/Desktop/music_app/assets/audio"
mkdir -p "$AUDIO_DIR"

echo "🎵 Downloading 10 free audio tracks..."

# These are free, publicly available sample audio files
curl -L -o "$AUDIO_DIR/track_01.mp3" "https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3" 2>/dev/null && echo "✅ Track 1 downloaded" || echo "❌ Track 1 failed"

curl -L -o "$AUDIO_DIR/track_02.mp3" "https://freetestdata.com/wp-content/uploads/2021/09/Free_Test_Data_100KB_MP3.mp3" 2>/dev/null && echo "✅ Track 2 downloaded" || echo "❌ Track 2 failed"

curl -L -o "$AUDIO_DIR/track_03.mp3" "https://download.samplelib.com/mp3/sample-15s.mp3" 2>/dev/null && echo "✅ Track 3 downloaded" || echo "❌ Track 3 failed"

curl -L -o "$AUDIO_DIR/track_04.mp3" "https://download.samplelib.com/mp3/sample-12s.mp3" 2>/dev/null && echo "✅ Track 4 downloaded" || echo "❌ Track 4 failed"

curl -L -o "$AUDIO_DIR/track_05.mp3" "https://download.samplelib.com/mp3/sample-9s.mp3" 2>/dev/null && echo "✅ Track 5 downloaded" || echo "❌ Track 5 failed"

curl -L -o "$AUDIO_DIR/track_06.mp3" "https://download.samplelib.com/mp3/sample-6s.mp3" 2>/dev/null && echo "✅ Track 6 downloaded" || echo "❌ Track 6 failed"

curl -L -o "$AUDIO_DIR/track_07.mp3" "https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3" 2>/dev/null && echo "✅ Track 7 downloaded" || echo "❌ Track 7 failed"

curl -L -o "$AUDIO_DIR/track_08.mp3" "https://download.samplelib.com/mp3/sample-15s.mp3" 2>/dev/null && echo "✅ Track 8 downloaded" || echo "❌ Track 8 failed"

curl -L -o "$AUDIO_DIR/track_09.mp3" "https://download.samplelib.com/mp3/sample-12s.mp3" 2>/dev/null && echo "✅ Track 9 downloaded" || echo "❌ Track 9 failed"

curl -L -o "$AUDIO_DIR/track_10.mp3" "https://download.samplelib.com/mp3/sample-9s.mp3" 2>/dev/null && echo "✅ Track 10 downloaded" || echo "❌ Track 10 failed"

echo ""
echo "🎉 Done! Files saved to $AUDIO_DIR"
ls -la "$AUDIO_DIR"/*.mp3 2>/dev/null
