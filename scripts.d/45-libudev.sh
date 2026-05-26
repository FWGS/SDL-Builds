#!/bin/bash

# TODO: maybe replace with systemd?

SCRIPT_REPO="https://github.com/eudev-project/eudev.git"
SCRIPT_COMMIT="9e7c4e744b9e7813af9acee64b5e8549ea1fbaa3"  # v3.2.14

ffbuild_enabled() {
    [[ $TARGET == linux* ]] || return 1
    return 0
}

ffbuild_dockerbuild() {
    ./autogen.sh

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --host="$FFBUILD_TOOLCHAIN"
        --enable-static
        --disable-shared
        --disable-programs
        --disable-hwdb
        --disable-manpages
        --disable-blkid
        --disable-selinux
        --disable-kmod
        --disable-mtd_probe
    )

    export CFLAGS="$RAW_CFLAGS"
    export LDFLAGS="$RAW_LDFLAGS"

    ./configure "${myconf[@]}"
    make -j"$(nproc)"
    make install-strip DESTDIR="$FFBUILD_DESTDIR"

    # Drop everything eudev installed except libudev itself.
    rm -rf "$FFBUILD_DESTPREFIX"/{bin,etc,share,sbin}
    rm -rf "$FFBUILD_DESTPREFIX"/lib/{udev,systemd}
}
