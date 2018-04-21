#!/usr/bin/env bash

set -eu

# shellcheck source=/dev/null
. "$(dirname "$0")/../config.sh"

LMDB_ROOT=${PROJECT_DIR}/lmdb/libraries/liblmdb
SYSROOT=$NDK_ROOT/sysroot
LINK_SYSROOT=$NDK_ROOT/platforms/android-$API_LEVEL

case "$ANDROID_ABI" in
    armeabi*)
        TOOLCHAIN_DIR=$NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/${OS}-${ARCH}/bin
        ;;
    arm64-v8a)
        TOOLCHAIN_DIR=$NDK_ROOT/toolchains/aarch64-linux-android-4.9/prebuilt/${OS}-${ARCH}/bin
        ;;
    x86)
        TOOLCHAIN_DIR=$NDK_ROOT/toolchains/x86-4.9/prebuilt/${OS}-${ARCH}/bin
        ;;
    x86_64)
        TOOLCHAIN_DIR=$NDK_ROOT/toolchains/x86_64-4.9/prebuilt/${OS}-${ARCH}/bin
        ;;
    *)
        echo "Error: $0 is not supported for ABI: ${ANDROID_ABI}"
        exit 1
        ;;
esac

pushd "${LMDB_ROOT}"

make clean
make -j"${N_JOBS}" \
     CC="$TOOLCHAIN_DIR/${TRIPLE}-gcc" AR="$TOOLCHAIN_DIR/${TRIPLE}-ar" \
     CFLAGS="--sysroot=$SYSROOT -isystem $NDK_ROOT/sysroot/usr/include/$TRIPLE -DMDB_DSYNC=O_SYNC -DMDB_USE_ROBUST=0" \
     LDFLAGS="--sysroot=$LINK_SYSROOT/arch-$TARGET_ARCH"

rm -rf "$INSTALL_DIR/lmdb"
make prefix="$INSTALL_DIR/lmdb" install

popd
