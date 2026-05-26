#!/bin/bash

SCRIPT_REPO="https://github.com/libffi/libffi.git"
SCRIPT_COMMIT="e2eda0cf72a0598b44278cc91860ea402273fa29"  # v3.5.2

ffbuild_enabled() {
    [[ $TARGET == linux* ]] || return 1
    return 0
}

ffbuild_dockerbuild() {
    # libtool 2.5+ dropped LT_SYS_SYMBOL_USCORE; not needed on ELF.
    sed -i '/^LT_SYS_SYMBOL_USCORE$/,/^fi$/d' configure.ac

    ./autogen.sh

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --host="$FFBUILD_TOOLCHAIN"
        --disable-shared
        --enable-static
        --disable-docs
        --disable-multi-os-directory
    )

    export CFLAGS="$RAW_CFLAGS"
    export LDFLAGS="$RAW_LDFLAGS"

    ./configure "${myconf[@]}"
    make -j"$(nproc)"
    make install DESTDIR="$FFBUILD_DESTDIR"

    rm -f "$FFBUILD_DESTPREFIX"/lib/libffi.la
}
