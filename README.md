# HifiBerry MPD Build

Cross-compilation scripts for building MPD 0.24.8 for HifiBerryOS (RPi2, ARMv7).

## Requirements
- Ubuntu/Debian (WSL or native)
- Docker
- ~5GB free space

## Usage
```bash
./build-all.sh
```

This will:
1. Download HifiBerryOS image for sysroot
2. Build Docker cross-compilation environment
3. Build all dependencies statically
4. Build MPD 0.24.8
5. Output binary to `./mpd`

## Features
- Fully static binary (no glibc version issues)
- FLAC, MP3 (mad+mpg123), Ogg, Opus, WavPack, AAC, sndfile
- ALSA output
- HTTP/HTTPS streaming (curl)
- HTTP output (httpd)
- CUE sheet support
- FFmpeg for extended format support
- LAME MP3 encoder for httpd streaming

## HifiBerryOS Installation
```bash
# Copy to device
scp mpd root@hifiberry:/library/playlists/mpd/mpd

# systemd drop-in
mkdir -p /etc/systemd/system/mpd.service.d/
cat > /etc/systemd/system/mpd.service.d/override.conf << 'CONF'
[Service]
ExecStart=
ExecStartPre=-mkdir /var/run/mpd
ExecStartPre=/opt/hifiberry/bin/bootmsg "Mounting SMB shares"
ExecStartPre=-/opt/hifiberry/bin/mount-smb.sh
ExecStartPre=/opt/hifiberry/bin/bootmsg "Mounting USB drives"
ExecStartPre=-/opt/hifiberry/bin/mount-all.sh
ExecStartPre=/opt/hifiberry/bin/bootmsg "Starting music player daemon"
ExecStartPre=/opt/hifiberry/bin/pause-state-file
ExecStartPre=/bin/cp /library/playlists/mpd/mpd /data/mpd_custom
ExecStart=/data/mpd_custom --no-daemon /data/mpd.conf
Environment=ALSA_CONFIG_PATH=/usr/share/alsa/alsa.conf
Environment=ALSA_CONFIG_DIR=/etc
CONF

systemctl daemon-reload
systemctl restart mpd
```
