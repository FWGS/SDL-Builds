#!/bin/bash

SCRIPT_REPO="https://github.com/alsa-project/alsa-lib.git"
SCRIPT_COMMIT="75ed5f05babcae7515aff5277e038ffd854c7669"  # v1.2.15.3

ffbuild_enabled() {
    [[ $TARGET == linux* ]] || return 1
    return 0
}

ffbuild_dockerbuild() {
    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --host="$FFBUILD_TOOLCHAIN"
        --enable-static
        --disable-shared
        --with-versioned=no
        --disable-python
        --disable-aload
        --disable-topology
        --disable-ucm
        --disable-mixer
        --disable-rawmidi
        --disable-seq
        --disable-hwdep
        --disable-old-symbols
    )

    export CFLAGS="$RAW_CFLAGS"
    export LDFLAGS="$RAW_LDFLAGS"

    ./configure "${myconf[@]}"
    make -j"$(nproc)"
    make install DESTDIR="$FFBUILD_DESTDIR"

}
