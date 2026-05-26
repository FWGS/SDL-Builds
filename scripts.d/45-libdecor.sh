#!/bin/bash

# TODO: skipped because of large dependency tree
# cairo, pixman, freetype, fontconfig
# some could be disabled but maybe we can ship libdecor as dynamic library dependency
# anyway, it's GNOME problems not mine :)

SCRIPT_REPO="https://gitlab.freedesktop.org/libdecor/libdecor.git"
SCRIPT_COMMIT="149c6f0b05663aaa69fdf7f94be2483776d1a311"  # 0.2.5

ffbuild_depends() {
    echo wayland
    echo wayland-protocols
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
        --default-library=shared
        -Ddemo=false
        -Ddbus=disabled
        -Dgtk=disabled
    )

    if [[ $TARGET == linux* ]]; then
        myconf+=( --cross-file=/cross.meson )
    fi

    export CFLAGS="$RAW_CFLAGS"
    export LDFLAGS="$RAW_LDFLAGS"

    meson setup "${myconf[@]}" ..
    ninja -j"$(nproc)"
    DESTDIR="$FFBUILD_DESTDIR" ninja install

    gen-implib "$FFBUILD_DESTPREFIX"/lib/{libdecor-0.so.0,libdecor-0.a}
    rm -f "$FFBUILD_DESTPREFIX"/lib/libdecor-0{.so*,.la}
}
