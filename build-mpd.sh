#!/bin/bash
set -euo pipefail

export PREFIX=/opt/sysroot
export CFLAGS="-march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=hard -I/opt/sysroot/include"
export CXXFLAGS="$CFLAGS"

mkdir -p $PREFIX/lib/pkgconfig $PREFIX/include /build/src

# native file
cat > /build/native.ini << 'EOF'
[binaries]
pkgconfig = 'pkg-config'
pkg-config = 'pkg-config'
EOF

# cross file
cat > /build/armhf-hifiberry.ini << 'EOF'
[binaries]
c = 'arm-linux-gnueabihf-gcc'
cpp = 'arm-linux-gnueabihf-g++'
ar = 'arm-linux-gnueabihf-ar'
strip = 'arm-linux-gnueabihf-strip'
pkg-config = 'arm-linux-gnueabihf-pkg-config'
cmake = 'cmake'

[built-in options]
c_args = ['-march=armv7-a', '-mfpu=vfpv3-d16', '-mfloat-abi=hard', '-I/opt/sysroot/include']
cpp_args = ['-march=armv7-a', '-mfpu=vfpv3-d16', '-mfloat-abi=hard', '-I/opt/sysroot/include']
c_link_args = ['-static', '-static-libgcc', '-L/opt/sysroot/lib', '-L/usr/arm-linux-gnueabihf/lib']
cpp_link_args = ['-static', '-static-libstdc++', '-static-libgcc', '-L/opt/sysroot/lib', '-L/usr/arm-linux-gnueabihf/lib']

[properties]
pkg_config_libdir = '/opt/sysroot/lib/pkgconfig'

[host_machine]
system = 'linux'
cpu_family = 'arm'
cpu = 'cortex-a7'
endian = 'little'
EOF

cd /build/src

# OpenSSL
if [ ! -f $PREFIX/lib/libssl.a ]; then
  wget -nc https://www.openssl.org/source/openssl-3.3.0.tar.gz
  tar xzf openssl-3.3.0.tar.gz && cd openssl-3.3.0
  ./Configure linux-armv4 --cross-compile-prefix=arm-linux-gnueabihf- \
    --prefix=$PREFIX --openssldir=$PREFIX no-shared no-tests CFLAGS="$CFLAGS"
  make -j$(nproc) && make install_sw
  cd /build/src
else echo "✓ OpenSSL"; fi

# zlib
if [ ! -f $PREFIX/lib/libz.a ]; then
  wget -nc https://github.com/madler/zlib/releases/download/v1.3.1/zlib-1.3.1.tar.gz
  tar xzf zlib-1.3.1.tar.gz && cd zlib-1.3.1
  CC=arm-linux-gnueabihf-gcc CFLAGS="$CFLAGS" ./configure --prefix=$PREFIX --static
  make -j$(nproc) && make install
  cd /build/src
else echo "✓ zlib"; fi

# curl
if [ ! -f $PREFIX/lib/libcurl.a ]; then
  wget -nc https://curl.se/download/curl-8.12.0.tar.gz
  tar xzf curl-8.12.0.tar.gz && cd curl-8.12.0
  ./configure --host=arm-linux-gnueabihf --prefix=$PREFIX \
    --disable-shared --enable-static \
    --with-openssl=$PREFIX --with-zlib=$PREFIX \
    --without-libpsl --without-brotli --without-zstd \
    --without-libidn2 --without-libssh2 \
    --disable-ldap --disable-sspi --disable-ftp --disable-file \
    --disable-dict --disable-telnet --disable-tftp --disable-rtsp \
    --disable-pop3 --disable-imap --disable-smtp --disable-gopher --disable-smb \
    CC=arm-linux-gnueabihf-gcc CFLAGS="$CFLAGS"
  make -j$(nproc) && make install
  cd /build/src
else echo "✓ curl"; fi

# FLAC
if [ ! -f $PREFIX/lib/libFLAC.a ]; then
  wget -nc https://downloads.xiph.org/releases/flac/flac-1.4.3.tar.xz
  tar xJf flac-1.4.3.tar.xz && cd flac-1.4.3
  ./configure --host=arm-linux-gnueabihf --prefix=$PREFIX \
    --disable-shared --enable-static \
    --disable-programs --disable-examples --disable-docs --with-ogg=no \
    CC=arm-linux-gnueabihf-gcc CXX=arm-linux-gnueabihf-g++ \
    CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS"
  make -j$(nproc) && make install
  cd /build/src
else echo "✓ FLAC"; fi

# libogg
if [ ! -f $PREFIX/lib/libogg.a ]; then
  wget -nc https://downloads.xiph.org/releases/ogg/libogg-1.3.5.tar.xz
  tar xJf libogg-1.3.5.tar.xz && cd libogg-1.3.5
  ./configure --host=arm-linux-gnueabihf --prefix=$PREFIX \
    --disable-shared --enable-static \
    CC=arm-linux-gnueabihf-gcc CFLAGS="$CFLAGS"
  make -j$(nproc) && make install
  cd /build/src
else echo "✓ libogg"; fi

# libvorbis
if [ ! -f $PREFIX/lib/libvorbis.a ]; then
  wget -nc https://downloads.xiph.org/releases/vorbis/libvorbis-1.3.7.tar.xz
  tar xJf libvorbis-1.3.7.tar.xz && cd libvorbis-1.3.7
  ./configure --host=arm-linux-gnueabihf --prefix=$PREFIX \
    --disable-shared --enable-static --with-ogg=$PREFIX \
    CC=arm-linux-gnueabihf-gcc CFLAGS="$CFLAGS"
  make -j$(nproc) && make install
  cd /build/src
else echo "✓ libvorbis"; fi

# libopus
if [ ! -f $PREFIX/lib/libopus.a ]; then
  wget -nc https://downloads.xiph.org/releases/opus/opus-1.5.2.tar.gz
  tar xzf opus-1.5.2.tar.gz && cd opus-1.5.2
  ./configure --host=arm-linux-gnueabihf --prefix=$PREFIX \
    --disable-shared --enable-static --disable-doc --disable-extra-programs \
    CC=arm-linux-gnueabihf-gcc CFLAGS="$CFLAGS"
  make -j$(nproc) && make install
  cd /build/src
else echo "✓ libopus"; fi

# mpg123
if [ ! -f $PREFIX/lib/libmpg123.a ]; then
  wget -nc https://www.mpg123.de/download/mpg123-1.32.9.tar.bz2
  tar xjf mpg123-1.32.9.tar.bz2 && cd mpg123-1.32.9
  ./configure --host=arm-linux-gnueabihf --prefix=$PREFIX \
    --disable-shared --enable-static --with-cpu=generic \
    --disable-id3tag --disable-debug \
    CC=arm-linux-gnueabihf-gcc CFLAGS="$CFLAGS"
  make -j$(nproc) && make install
  cd /build/src
else echo "✓ mpg123"; fi

# libsndfile
if [ ! -f $PREFIX/lib/libsndfile.a ]; then
  wget -nc https://github.com/libsndfile/libsndfile/releases/download/1.2.2/libsndfile-1.2.2.tar.xz
  tar xJf libsndfile-1.2.2.tar.xz && cd libsndfile-1.2.2
  ./configure --host=arm-linux-gnueabihf --prefix=$PREFIX \
    --disable-shared --enable-static \
    --disable-full-suite --disable-programs --disable-external-libs \
    CC=arm-linux-gnueabihf-gcc CFLAGS="$CFLAGS"
  make -j$(nproc) && make install
  cd /build/src
else echo "✓ libsndfile"; fi

# wavpack
if [ ! -f $PREFIX/lib/libwavpack.a ]; then
  wget -nc https://github.com/dbry/WavPack/releases/download/5.7.0/wavpack-5.7.0.tar.xz
  tar xJf wavpack-5.7.0.tar.xz && cd wavpack-5.7.0
  ./configure --host=arm-linux-gnueabihf --prefix=$PREFIX \
    --disable-shared --enable-static --disable-apps \
    CC=arm-linux-gnueabihf-gcc CFLAGS="$CFLAGS"
  make -j$(nproc) && make install
  cd /build/src
else echo "✓ wavpack"; fi

# libcue
if [ ! -f $PREFIX/lib/libcue.a ]; then
  wget -nc https://github.com/lipnitsk/libcue/archive/refs/tags/v2.3.0.tar.gz -O libcue-2.3.0.tar.gz
  tar xzf libcue-2.3.0.tar.gz && cd libcue-2.3.0
  cmake -DCMAKE_SYSTEM_NAME=Linux \
    -DCMAKE_C_COMPILER=arm-linux-gnueabihf-gcc \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_C_FLAGS="$CFLAGS" .
  make -j$(nproc) && make install
  cd /build/src
else echo "✓ libcue"; fi

# libgpg-error
if [ ! -f $PREFIX/lib/libgpg-error.a ]; then
  wget -nc https://gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.51.tar.bz2
  tar xjf libgpg-error-1.51.tar.bz2 && cd libgpg-error-1.51
  ./configure --host=arm-linux-gnueabihf --prefix=$PREFIX \
    --disable-shared --enable-static --disable-doc --disable-tests \
    CC=arm-linux-gnueabihf-gcc CFLAGS="$CFLAGS"
  make -j$(nproc) && make install
  cd /build/src
else echo "✓ libgpg-error"; fi

# libgcrypt
if [ ! -f $PREFIX/lib/libgcrypt.a ]; then
  wget -nc https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.11.0.tar.bz2
  tar xjf libgcrypt-1.11.0.tar.bz2 && cd libgcrypt-1.11.0
  ./configure --host=arm-linux-gnueabihf --prefix=$PREFIX \
    --disable-shared --enable-static --disable-doc --disable-asm \
    --with-libgpg-error-prefix=$PREFIX \
    CC=arm-linux-gnueabihf-gcc CFLAGS="$CFLAGS"
  make -j$(nproc) && make install
  cd /build/src
else echo "✓ libgcrypt"; fi

# bzip2
if [ ! -f $PREFIX/lib/libbz2.a ]; then
  wget -nc https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz
  tar xzf bzip2-1.0.8.tar.gz && cd bzip2-1.0.8
  make CC=arm-linux-gnueabihf-gcc AR=arm-linux-gnueabihf-ar \
    RANLIB=arm-linux-gnueabihf-ranlib CFLAGS="$CFLAGS" libbz2.a
  cp libbz2.a $PREFIX/lib/ && cp bzlib.h $PREFIX/include/
  cd /build/src
else echo "✓ bzip2"; fi

# lame
if [ ! -f $PREFIX/lib/libmp3lame.a ]; then
  wget -nc https://sourceforge.net/projects/lame/files/lame/3.100/lame-3.100.tar.gz
  tar xzf lame-3.100.tar.gz && cd lame-3.100
  ./configure --host=arm-linux-gnueabihf --prefix=$PREFIX \
    --disable-shared --enable-static --disable-frontend \
    CC=arm-linux-gnueabihf-gcc CFLAGS="$CFLAGS"
  make -j$(nproc) && make install
  cd /build/src
else echo "✓ lame"; fi

# faad2
if [ ! -f $PREFIX/lib/libfaad.a ]; then
  wget -nc https://github.com/knik0/faad2/archive/refs/tags/2.11.1.tar.gz -O faad2-2.11.1.tar.gz
  tar xzf faad2-2.11.1.tar.gz && cd faad2-2.11.1
  cmake -DCMAKE_SYSTEM_NAME=Linux \
    -DCMAKE_C_COMPILER=arm-linux-gnueabihf-gcc \
    -DCMAKE_CXX_COMPILER=arm-linux-gnueabihf-g++ \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DBUILD_SHARED_LIBS=OFF -DBUILD_PROGRAMS=OFF \
    -DCMAKE_C_FLAGS="$CFLAGS" \
    -DCMAKE_C_STANDARD_LIBRARIES="-lm" .
  make -j$(nproc) && make install
  # faad installs to wrong path sometimes
  [ -f /lib/libfaad.a ] && cp /lib/libfaad.a $PREFIX/lib/
  [ -f /include/neaacdec.h ] && cp /include/neaacdec.h $PREFIX/include/
  cd /build/src
else echo "✓ faad2"; fi

# libmad
if [ ! -f $PREFIX/lib/libmad.a ]; then
  wget -nc https://sourceforge.net/projects/mad/files/libmad/0.15.1b/libmad-0.15.1b.tar.gz
  tar xzf libmad-0.15.1b.tar.gz && cd libmad-0.15.1b
  ./configure --host=arm-linux-gnueabihf --prefix=$PREFIX \
    --disable-shared --enable-static --disable-aso \
    CC=arm-linux-gnueabihf-gcc \
    CFLAGS="$CFLAGS -fno-strict-aliasing -marm"
  make -j$(nproc) && make install
  cd /build/src
else echo "✓ libmad"; fi

# alsa-lib
if [ ! -f $PREFIX/lib/libasound.a ]; then
  wget -nc https://www.alsa-project.org/files/pub/lib/alsa-lib-1.2.12.tar.bz2
  tar xjf alsa-lib-1.2.12.tar.bz2 && cd alsa-lib-1.2.12
  ./configure --host=arm-linux-gnueabihf --prefix=$PREFIX \
    --disable-shared --enable-static --disable-python \
    CC=arm-linux-gnueabihf-gcc CFLAGS="$CFLAGS"
  make -j$(nproc) && make install
  cd /build/src
else echo "✓ alsa-lib"; fi

# FFmpeg (minimal)
if [ ! -f $PREFIX/lib/libavcodec.a ]; then
  wget -nc https://ffmpeg.org/releases/ffmpeg-7.1.tar.xz
  tar xJf ffmpeg-7.1.tar.xz && cd ffmpeg-7.1
  PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig \
  PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig \
  ./configure \
    --cross-prefix=arm-linux-gnueabihf- \
    --arch=arm \
    --target-os=linux \
    --prefix=$PREFIX \
    --enable-static \
    --disable-shared \
    --disable-all \
    --enable-gpl \
    --enable-nonfree \
    --enable-openssl \
    --enable-zlib \
    --enable-avcodec \
    --enable-avformat \
    --enable-avutil \
    --enable-avfilter \
    --enable-swresample \
    --enable-decoder=aac,aac_fixed,alac,mjpeg,png,dca,dsd_lsbf,dsd_msbf,dsd_lsbf_planar,dsd_msbf_planar \
    --enable-demuxer=mov,aac,m4v,dts,dsf,dsdiff,dash,hls \
    --enable-parser=aac,alac,mjpeg,mpegaudio,dca \
    --enable-protocol=file,http,https,tcp,tls,pipe \
    --enable-filter=aresample \
    --enable-network \
    --extra-cflags="$CFLAGS -I$PREFIX/include" \
    --extra-ldflags="-L$PREFIX/lib -ldl -lpthread"
  make -j$(nproc) && make install
  cd /build/src
else echo "✓ FFmpeg"; fi

#Sox
if [ ! -f $PREFIX/lib/libsoxr.a ]; then
   git clone https://git.code.sf.net/p/soxr/code soxr-code
   cd soxr-code

   mkdir -p build && cd build

   cmake .. \
     -DCMAKE_SYSTEM_NAME=Linux \
     -DCMAKE_SYSTEM_PROCESSOR=arm \
     -DCMAKE_C_COMPILER=arm-linux-gnueabihf-gcc \
     -DCMAKE_INSTALL_PREFIX=$PREFIX \
     -DBUILD_SHARED_LIBS=OFF \
     -DBUILD_EXAMPLES=OFF \
     -DBUILD_TESTS=OFF \
     -DWITH_OPENMP=OFF

   make -j$(nproc)
   make install
else echo "✓ Sox"; fi

#pUPnP
if [ ! -f $PREFIX/lib/libupnp.a ]; then
  git clone https://github.com/pupnp/pupnp.git
  cd pupnp
  git checkout branch-1.12.x
  sh ./bootstrap
  ./configure   --host=arm-linux-gnueabihf   --prefix=$PREFIX   --enable-static   --disable-shared   --disable-ipv6   --disable-samples
   make -j$(nproc)
   make install  
else echo "✓ pUPnP"; fi

# MPD
if [ ! -d mpd-0.24.9 ]; then
  wget -nc https://www.musicpd.org/download/mpd/0.24/mpd-0.24.9.tar.xz
  tar xJf mpd-0.24.9.tar.xz
fi
cd mpd-0.24.9
rm -rf build-hifiberry

meson setup build-hifiberry \
  --cross-file /build/armhf-hifiberry.ini \
  --native-file /build/native.ini \
  --prefix=/usr \
  --buildtype=release \
  -Ddefault_library=shared \
  -Ddocumentation=disabled \
  -Dtest=false \
  -Ddaemon=false \
  -Dsystemd=disabled \
  -Ddbus=disabled \
  -Dupnp=pupnp \
  -Dzeroconf=disabled \
  -Dneighbor=false \
  -Dcue=true \
  -Dflac=enabled \
  -Dwavpack=enabled \
  -Dvorbis=enabled \
  -Dopus=enabled \
  -Dfaad=enabled \
  -Dcurl=enabled \
  -Dhttpd=true \
  -Dffmpeg=enabled \
  -Dmad=enabled \
  -Dlame=enabled \
  -Dalsa=enabled \
  -Dsoxr=enabled \
  -Diconv=enabled

ninja -C build-hifiberry
arm-linux-gnueabihf-strip build-hifiberry/mpd
cp build-hifiberry/mpd /host/mpd

echo "=== DONE ==="
ls -lh /host/mpd
