if [ ! -f $PREFIX/lib/libgmp.a ]; then
  wget -nc https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz
  tar xJf gmp-6.3.0.tar.xz && cd gmp-6.3.0
  ./configure \
    --host=arm-linux-gnueabihf \
    --build=x86_64-linux-gnu \
    --prefix=$PREFIX \
    --disable-shared \
    --enable-static \
    CC=arm-linux-gnueabihf-gcc \
    CFLAGS="$CFLAGS" \
    LDFLAGS="-static -L${PREFIX}/lib"
  make -j$(nproc) && make install
  cd /build/src
else echo "✓ gmp"; fi
if [ ! -f $PREFIX/lib/libnettle.a ]; then
  wget -nc https://ftp.gnu.org/gnu/nettle/nettle-3.9.1.tar.gz
  tar xzf nettle-3.9.1.tar.gz && cd nettle-3.9.1
  ./configure \
    --host=arm-linux-gnueabihf \
    --build=x86_64-linux-gnu \
    --prefix=$PREFIX \
    --disable-shared \
    --enable-static \
    --disable-openssl \
    CC=arm-linux-gnueabihf-gcc \
    CC_FOR_BUILD=gcc \
    CFLAGS="$CFLAGS -I${PREFIX}/include" \
    CFLAGS_FOR_BUILD="-O2" \
    LDFLAGS="-static -L${PREFIX}/lib" \
    LIBS="-lgmp" \
    PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
  make -j$(nproc) && make install
  cd /build/src
else echo "✓ nettle"; fi
if [ ! -f $PREFIX/lib/libgnutls.a ]; then
  wget -nc https://www.gnupg.org/ftp/gcrypt/gnutls/v3.8/gnutls-3.8.3.tar.xz
  tar xJf gnutls-3.8.3.tar.xz && cd gnutls-3.8.3
  ./configure \
    --host=arm-linux-gnueabihf \
    --build=x86_64-linux-gnu \
    --prefix=$PREFIX \
    --disable-shared \
    --enable-static \
    --with-included-unistring \
    --with-included-libtasn1 \
    --without-p11-kit \
    --disable-libdane \
    --disable-tools \
    --disable-doc \
    --disable-tests \
    --disable-nls \
    CC=arm-linux-gnueabihf-gcc \
    CFLAGS="$CFLAGS -I${PREFIX}/include" \
    LDFLAGS="-static -L${PREFIX}/lib" \
    LIBS="-lgmp" \
    PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
  make -j$(nproc) && make install
  cd /build/src
else echo "✓ gnutls"; fi
if [ ! -f $PREFIX/lib/libcurl.a ]; then
  wget -nc https://curl.se/download/curl-8.12.0.tar.gz
  tar xzf curl-8.12.0.tar.gz && cd curl-8.12.0
  ./configure \
    --host=arm-linux-gnueabihf \
    --prefix=$PREFIX \
    --disable-shared \
    --enable-static \
    --with-gnutls \
    --without-openssl \
    --with-zlib=$PREFIX \
    --without-libpsl \
    --without-brotli \
    --without-zstd \
    --without-libidn2 \
    --without-libssh2 \
    --disable-ldap --disable-sspi --disable-ftp --disable-file \
    --disable-dict --disable-telnet --disable-tftp --disable-rtsp \
    --disable-pop3 --disable-imap --disable-smtp --disable-gopher --disable-smb \
    CC=arm-linux-gnueabihf-gcc \
    CFLAGS="$CFLAGS -I${PREFIX}/include" \
    LDFLAGS="-static -L${PREFIX}/lib" \
    LIBS="-lgnutls -lhogweed -lnettle -lgmp -latomic -lz -lpthread -ldl" \
    PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" \
    PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig" \
    PKG_CONFIG="pkg-config --static"
  make -j$(nproc) && make install
  cd /build/src
else echo "✓ curl"; fi
if [ ! -f $PREFIX/lib/libavcodec.a ]; then
  wget -nc https://ffmpeg.org/releases/ffmpeg-7.1.tar.xz
  tar xJf ffmpeg-7.1.tar.xz && cd ffmpeg-7.1
  PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig \
  PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig \
  PKG_CONFIG="pkg-config --static" \
  ./configure \
    --cross-prefix=arm-linux-gnueabihf- \
    --arch=arm \
    --target-os=linux \
    --enable-cross-compile \
    --prefix=$PREFIX \
    --enable-static \
    --disable-shared \
    --disable-all \
    --enable-gpl \
    --enable-version3 \
    --pkg-config-flags="--static" \
    --enable-zlib \
    --enable-gnutls \
    --enable-avcodec \
    --enable-avformat \
    --enable-avutil \
    --enable-avfilter \
    --enable-swresample \
    --enable-network \
    --enable-decoder=aac,aac_fixed,alac,mjpeg,png,dca,dsd_lsbf,dsd_msbf,dsd_lsbf_planar,dsd_msbf_planar \
    --enable-demuxer=mov,aac,m4v,dts,dsf,dsdiff,dash,hls \
    --enable-parser=aac,alac,mjpeg,mpegaudio,dca \
    --enable-protocol=file,http,https,tcp,tls,pipe \
    --enable-filter=aresample \
    --extra-cflags="-I$PREFIX/include $CFLAGS" \
    --extra-ldflags="-L$PREFIX/lib -static" \
    --extra-libs="-lgnutls -lhogweed -lnettle -lgmp -latomic -lz -lpthread -ldl -lm"
  make -j$(nproc) && make install
  cd /build/src
else echo "✓ FFmpeg"; fi
