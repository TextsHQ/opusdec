#!/bin/sh

# ==============================================================
# Script to build a statically linked version of opus-tools
# https://gist.github.com/spvkgn/60c12010d4cae1243dfee45b0821f692
#
# https://github.com/xiph/ogg.git
# https://github.com/xiph/opus.git
# https://github.com/xiph/opusfile.git
# https://github.com/xiph/opus-tools.git
# https://github.com/xiph/flac.git
# https://github.com/xiph/libopusenc.git
#
# Build deps: autoconf automake libtool pkg-config
#
# ==============================================================

export BUILD_DIR=`pwd`/build
export PKG_CONFIG_PATH="$BUILD_DIR/lib/pkgconfig"
export OPT_FLAGS="-fno-strict-aliasing -O3 -march=native"
XIPH=https://github.com/xiph/
LIBS=(ogg opus opusfile opus-tools flac libopusenc)
SUFFIX="-static"

echo "Cloning git repositories..."
for LIB in "${LIBS[@]}"
  do
    git clone "$XIPH$LIB"
  done

[ -d "$BUILD_DIR" ] || mkdir "$BUILD_DIR"

# build libogg
cd ${LIBS[0]}
./autogen.sh
./configure --prefix=$BUILD_DIR \
  --disable-shared --enable-static
make clean
make -j $(nproc) install
cd ..

# build Opus
cd ${LIBS[1]}
./autogen.sh
./configure --prefix=$BUILD_DIR \
  --disable-shared --enable-static \
  --disable-maintainer-mode \
  --disable-doc \
  --disable-extra-programs
make clean
make -j $(nproc) install
cd ..

# build opusfile
cd ${LIBS[2]}
./autogen.sh
./configure --prefix=$BUILD_DIR \
  --disable-shared --enable-static \
  --disable-maintainer-mode \
  --disable-examples \
  --disable-doc \
  --disable-http
make clean
make -j $(nproc) install
cd ..

# build opus-tools
cd ${LIBS[3]}
./autogen.sh
./configure --prefix=$BUILD_DIR \
  --disable-shared --enable-static \
  --disable-maintainer-mode
make clean
make -j $(nproc) install
cd ..

# build FLAC
cd ${LIBS[4]}
./autogen.sh
./configure --prefix=$BUILD_DIR \
  --disable-shared --enable-static \
  --disable-debug \
  --disable-oggtest \
  --disable-cpplibs \
  --disable-doxygen-docs \
  --with-ogg="$BUILD_DIR"
make clean
make -j $(nproc) install
cd ..

# build libopusenc
cd ${LIBS[5]}
./autogen.sh
./configure --prefix=$BUILD_DIR \
  --disable-shared --enable-static \
  --disable-maintainer-mode \
  --disable-examples \
  --disable-doc
make clean
make -j $(nproc) install
cd ..

if ls $BUILD_DIR/bin/opus* > /dev/null 2>&1 ; then
  for file in $BUILD_DIR/bin/opus*
  do
    cp $file $PWD/$(basename $file)$SUFFIX
    strip $PWD/$(basename $file)$SUFFIX
  done
fi