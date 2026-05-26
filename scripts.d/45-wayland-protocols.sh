#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/wayland/wayland-protocols.git"
SCRIPT_COMMIT="02e63e74a807afed95bc25a386173110afef24e3" # 1.48

ffbuild_depends() {
    echo wayland
}

ffbuild_enabled() {
    [[ $TARGET == linux* ]] || return 1
    return 0
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        -Dtests=false
    )

    if [[ $TARGET == linux* ]]; then
        myconf+=( --cross-file=/cross.meson )
    fi

    meson setup "${myconf[@]}" ..
    ninja -j"$(nproc)"
    DESTDIR="$FFBUILD_DESTDIR" ninja install
}
