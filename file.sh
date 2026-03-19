# zlib
if [ ! -f $PREFIX/lib/libz.a ]; then
  wget -nc https://zlib.net/zlib-1.3.1.tar.gz
  tar xzf zlib-1.3.1.tar.gz && cd zlib-1.3.1
  CHOST=arm-linux-gnueabihf ./configure --prefix=$PREFIX --static
  make -j$(nproc) CC=arm-linux-gnueabihf-gcc && make install
  cd /build/src
else echo "✓ zlib"; fi

# xz

if [ ! -f $PREFIX/lib/liblzma.a ]; then
  wget -nc https://tukaani.org/xz/xz-5.4.6.tar.gz
  tar xzf xz-5.4.6.tar.gz && cd xz-5.4.6
  ./configure --host=arm-linux-gnueabihf --prefix=$PREFIX \
    --enable-static --disable-shared --disable-doc \
    CC=arm-linux-gnueabihf-gcc CFLAGS="$CFLAGS"
  make -j$(nproc) && make install
  cd /build/src
else echo "✓ xz"; fi

# bzip2

if [ ! -f $PREFIX/lib/libbz2.a ]; then
  wget -nc https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz
  tar xzf bzip2-1.0.8.tar.gz && cd bzip2-1.0.8
  make libbz2.a CC=arm-linux-gnueabihf-gcc AR=arm-linux-gnueabihf-ar RANLIB=arm-linux-gnueabihf-ranlib CFLAGS="$CFLAGS"
  install -m 644 bzlib.h $PREFIX/include/
  install -m 644 libbz2.a $PREFIX/lib/
  cd /build/src
else echo "✓ bzip2"; fi

# file

if [ ! -f $PREFIX/bin/file ]; then
  wget -nc https://astron.com/pub/file/file-5.44.tar.gz
  tar xzf file-5.44.tar.gz && cd file-5.44
  ./configure --host=arm-linux-gnueabihf --build=x86_64-linux-gnu \
    --prefix=$PREFIX --enable-static --disable-shared --disable-libseccomp \
    CC=arm-linux-gnueabihf-gcc \
    CFLAGS="$CFLAGS" \
    LDFLAGS="-static -L$PREFIX/lib" \
    LIBS="-llzma -lbz2 -lz"
  make -j$(nproc) && make install
  mkdir -p $PREFIX/share/misc
  cp magic/magic.mgc $PREFIX/share/misc/
  cd /build/src
else echo "✓ file"; fi
