#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/glvnd/libglvnd.git"
SCRIPT_COMMIT="c046a760d845416e98ac4128757b2b356c47fdaa"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=shared
        -Dasm=disabled
        -Dx11=enabled
        -Degl=true
        -Dglx=enabled
        -Dgles1=true
        -Dgles2=true
        -Dheaders=true
    )

    if [[ $TARGET == linux* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    export CFLAGS="$RAW_CFLAGS"
    export LDFLAGS="$RAW_LDFLAGS"
    export PKG_CONFIG="pkg-config --static"

    meson "${myconf[@]}" ..
    ninja -j"$(nproc)"
    DESTDIR="$FFBUILD_DESTDIR" ninja install

    # SDL wants to link to OpenGL during configure stage
    # let's just generate stub implib so it passes the config but contains no glvnd code
    # and prevents any attempt to link to libGL
    for LIBNAME in libEGL.so.1 libGL.so.1 libGLX.so.0 libGLESv1_CM.so.1 libGLESv2.so.2 libOpenGL.so.0; do
        BASE="${LIBNAME%%.so*}"
        gen-implib "$FFBUILD_DESTPREFIX"/lib/{$LIBNAME,$BASE.a}
        rm -f "$FFBUILD_DESTPREFIX"/lib/${BASE}{.so*,.la}
    done
}
