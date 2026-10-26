

# Test videos

## jontxu.mkv

- Original (kinda dirty) dump from an rtsp camera
- Key frame each second (?)
- Just P frames (note main profile)
- PCM audio

```bash
Stream #0:0: Video: h264 (Main), yuv420p(progressive), 1280x720, SAR 1:1 DAR 16:9, 25 fps, 25 tbr, 1k tbn, 50 tbc (default)
  
Stream #0:1: Audio: pcm_s16le, 8000 Hz, 1 channels, s16, 128 kb/s (default)
```

## jontxu.mp4

- Sanitized from `jontxu.mkv`

```bash
Stream #0:0(und): Video: h264 (High) (avc1 / 0x31637661), yuv420p, 1280x720 [SAR 1:1 DAR 16:9], 1583 kb/s, 25 fps, 25 tbr, 12800 tbn, 50 tbc (default)

Stream #0:1(und): Audio: aac (LC) (mp4a / 0x6134706D), 8000 Hz, mono, fltp, 33 kb/s (default)
```

## jontxu_k1_sec.mkv

- Just P frames
- PCM audio
- Key-frame each second

```bash
ffmpeg -y -i jontxu.mkv -c:v libx264 -c:a copy -force_key_frames "expr:gte(t,n_forced*1)" -preset ultrafast -tune zerolatency -x264opts no-mbtree:sync-lookahead=0:rc-lookahead=0:bframes=0 -vf "setpts=N/FR/TB" jontxu_k1_sec.mkv
```

```bash
Stream #0:0: Video: h264 (High), yuv420p(progressive), 1280x720 [SAR 1:1 DAR 16:9], 25 fps, 25 tbr, 1k tbn, 50 tbc (default)

Stream #0:1: Audio: pcm_s16le, 8000 Hz, 1 channels, s16, 128 kb/s (default)
```

## jontxu_k1_sec_b.mkv

- Has B frames for sure
- PCM audio
- Key-frame each second

```bash
ffmpeg -y -i jontxu.mkv -c:v libx264 -force_key_frames "expr:gte(t,n_forced*1)" -c:a copy -preset medium -crf 23 jontxu_k1_sec_b.mkv
```

```bash
Stream #0:0: Video: h264 (High), yuv420p(progressive), 1280x720 [SAR 1:1 DAR 16:9], 25 fps, 25 tbr, 1k tbn, 50 tbc (default)
  
Stream #0:1: Audio: pcm_s16le, 8000 Hz, 1 channels, s16, 128 kb/s (default)
```

## jontxu_k1_sec_b_noaudio.mkv

- Has B frames for sure
- no audio
- Key-frame each second

```bash
Stream #0:0: Video: h264 (High), yuv420p(progressive), 1280x720 [SAR 1:1 DAR 16:9], 25 fps, 25 tbr, 1k tbn, 50 tbc (default)
```

## jontxu_short.mkv

- A few-second video

```bash
Stream #0:0: Video: h264 (Main), yuv420p(progressive), 1280x720, SAR 1:1 DAR 16:9, 25 fps, 25 tbr, 1k tbn, 50 tbc (default)

Stream #0:1: Audio: pcm_s16le, 8000 Hz, 1 channels, s16, 128 kb/s (default)
```

## jontxu_vp8.webm

- Old attempt, replaced by jontxu_vp8.mkv (WebM only supports Vorbis/Opus audio; AAC not supported)

## jontxu_vp8.mkv

- VP8 video + AAC audio, MKV container
- Transcoded from `jontxu_k1_sec.mkv` for VP8/RTSP debugging
- Keyframe each second (-g 25 at 25 fps)
- AAC audio at 8000 Hz mono (matches source sample rate)

```bash
ffmpeg -y -i jontxu_k1_sec.mkv -c:v libvpx -b:v 1500k -g 25 -auto-alt-ref 0 -c:a aac -ar 8000 -ac 1 -b:a 32k jontxu_vp8.mkv
```

```bash
Stream #0:0: Video: vp8, yuv420p, 1280x720, 25 fps (default)

Stream #0:1: Audio: aac, 8000 Hz, 1 channels, 32 kb/s (default)
```


## jontxu_hevc.mkv, jontxu_hevc.mp4, jontxu_av1.mkv

- 10 s from `jontxu_k1_sec.mkv`, re-encoded with the system ffmpeg (libx265 is GPL: not in limef's own ffmpeg)
- Key-frame each second, no B-frames
- `jontxu_hevc.mkv`: H.265 Main, parameter sets also in-band (`repeat-headers`), PCM audio
- `jontxu_hevc.mp4`: H.265 Main, `hvc1` (parameter sets only in hvcC), AAC audio
- `jontxu_av1.mkv`: AV1 Main (libaom realtime), Opus audio 48 kHz
- `jontxu_hevc_noaudio.mp4`: `jontxu_hevc.mp4` without audio (`ffmpeg -i jontxu_hevc.mp4 -an -c copy`)

```bash
KF='-force_key_frames expr:gte(t,n_forced*1)'
ffmpeg -i jontxu_k1_sec.mkv -t 10 -c:v libx265 -preset ultrafast -x265-params bframes=0:keyint=25:min-keyint=25:scenecut=0:repeat-headers=1 $KF -c:a copy jontxu_hevc.mkv
ffmpeg -i jontxu_k1_sec.mkv -t 10 -c:v libx265 -preset ultrafast -tag:v hvc1 -x265-params bframes=0:keyint=25:min-keyint=25:scenecut=0 $KF -c:a aac -movflags +faststart jontxu_hevc.mp4
ffmpeg -i jontxu_k1_sec.mkv -t 10 -c:v libaom-av1 -usage realtime -cpu-used 8 -row-mt 1 -b:v 1500k -g 25 -lag-in-frames 0 $KF -c:a libopus -ar 48000 jontxu_av1.mkv
```
