#!/usr/bin/env bash

set -eu

# shellcheck source=/dev/null
. "$(dirname "$0")/../config.sh"

SNAPPY_ROOT=${PROJECT_DIR}/snappy
SYSROOT=$NDK_ROOT/sysroot
LINK_SYSROOT=$NDK_ROOT/platforms/android-$API_LEVEL

"$PROJECT_DIR/scripts/make-toolchain.sh"

pushd "${SNAPPY_ROOT}"

if [ ! -f configure ]; then
    ./autogen.sh
fi

MAKE="$TOOLCHAIN_DIR/bin/make" \
CC="$(find "$TOOLCHAIN_DIR/bin/" -name '*-gcc')" \
CXX="$(find "$TOOLCHAIN_DIR/bin/" -name '*-g++')" \
AR="$(find "$TOOLCHAIN_DIR/bin/" -name '*-ar' -not -name '*gcc-ar')" \
AS="$(find "$TOOLCHAIN_DIR/bin/" -name '*-as')" \
LD="$(find "$TOOLCHAIN_DIR/bin/" -name '*-ld')" \
RANLIB="$(find "$TOOLCHAIN_DIR/bin/" -name '*-ranlib' -not -name '*gcc-ranlib')" \
STRIP="$(find "$TOOLCHAIN_DIR/bin/" -name '*-strip')" \
CFLAGS="-isystem $NDK_ROOT/sysroot/usr/include/$TRIPLE" \
LDFLAGS="--sysroot=$LINK_SYSROOT/arch-$TARGET_ARCH" \
./configure --prefix="$INSTALL_DIR/snappy" --with-gflags=no --host="${TRIPLE}" --with-sysroot="${SYSROOT}"

make clean
make -j"${N_JOBS}"
rm -rf "${INSTALL_DIR}/snappy"
make install
git clean -fd 2> /dev/null || true

popd
