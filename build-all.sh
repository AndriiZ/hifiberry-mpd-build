#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IMG="$SCRIPT_DIR/hifiberryos-20230404-pi2.img"
SYSROOT="$SCRIPT_DIR/hifiberry-sysroot"

# Download HifiBerryOS image if not exists
if [ ! -f "$IMG" ]; then
  echo "→ Downloading HifiBerryOS image..."
  wget https://github.com/hifiberry/hifiberry-os/releases/download/v20230404/hifiberryos-20230404-pi2.img \
    -O "$IMG"
fi

# Mount and extract sysroot
if [ ! -d "$SYSROOT/lib" ]; then
  echo "→ Extracting sysroot..."
  sudo mkdir -p /mnt/hifiberry
  sudo mount -o loop,offset=$((131073 * 512)) "$IMG" /mnt/hifiberry
  mkdir -p "$SYSROOT/usr"
  cp -a /mnt/hifiberry/usr/lib "$SYSROOT/usr/"
  cp -a /mnt/hifiberry/lib "$SYSROOT/"
  sudo umount /mnt/hifiberry
  echo "✓ Sysroot ready"
else
  echo "✓ Sysroot already extracted"
fi

# Build Docker image
echo "→ Building Docker image..."
docker build -t mpd-builder -f "$SCRIPT_DIR/Dockerfile.mpd" "$SCRIPT_DIR"

# Run build
echo "→ Running build..."
mkdir -p "$SCRIPT_DIR/mpd-sysroot" "$SCRIPT_DIR/mpd-build"

docker run --rm -it \
  -v "$SYSROOT:/opt/hifiberry-sysroot" \
  -v "$SCRIPT_DIR/mpd-sysroot:/opt/sysroot" \
  -v "$SCRIPT_DIR/mpd-build:/build" \
  -v "$SCRIPT_DIR:/host" \
  mpd-builder bash -c "/host/build-mpd.sh 2>&1 | tee /host/build.log"

echo "=== Build complete ==="
echo "Binary: $SCRIPT_DIR/mpd"
ls -lh "$SCRIPT_DIR/mpd"
