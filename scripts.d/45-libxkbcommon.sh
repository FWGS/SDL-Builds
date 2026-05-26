#!/bin/bash

SCRIPT_REPO="https://github.com/xkbcommon/libxkbcommon.git"
SCRIPT_COMMIT="6f76d19db72b5d450e927b41e1e96cbe3252aba8"  # xkbcommon-1.13.1

ffbuild_enabled() {
    [[ $TARGET == linux* ]] || return 1
    return 0
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
        -Denable-x11=false
        -Denable-wayland=false
        -Denable-docs=false
        -Denable-xkbregistry=false
        -Denable-tools=false
        -Denable-bash-completion=false
        -Dxkb-config-root=/usr/share/X11/xkb
        -Dxkb-config-extra-path=/etc/xkb
        -Dx-locale-root=/usr/share/X11/locale
    )

    if [[ $TARGET == linux* ]]; then
        myconf+=( --cross-file=/cross.meson )
    fi

    export CFLAGS="$RAW_CFLAGS"
    export LDFLAGS="$RAW_LDFLAGS"

    meson setup "${myconf[@]}" ..
    ninja -j"$(nproc)"
    DESTDIR="$FFBUILD_DESTDIR" ninja install
}
