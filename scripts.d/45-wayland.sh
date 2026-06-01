#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/wayland/wayland.git"

# Lock at 1.24.0, because we build in Ubuntu 26.04 container
# and use it's packaged wayland-scanner binary
SCRIPT_COMMIT="736d12ac67c20c60dc406dc49bb06be878501f86"

ffbuild_depends() {
    echo libffi
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
        --default-library=static
        -Ddocumentation=false
        -Dtests=false
        -Ddtd_validation=false
        -Dlibraries=true
        -Dscanner=false
    )

    if [[ $TARGET == linux* ]]; then
        myconf+=( --cross-file=/cross.meson )
    fi

    export CFLAGS="$RAW_CFLAGS"
    export LDFLAGS="$RAW_LDFLAGS"

    # HACKHACK: the meson users (as in projects using meson) is doing a dumbest thnig ever
    #  and don't let override _native_ mind you wayland-scanner binary through envvar
    # for this case generate a stub .pc pointing at the host wayland-scanner
    mkdir -p "$FFBUILD_PREFIX"/lib/pkgconfig "$FFBUILD_DESTPREFIX"/lib/pkgconfig
    cat > "$FFBUILD_PREFIX"/lib/pkgconfig/wayland-scanner.pc <<'EOF'
prefix=/usr
bindir=${prefix}/bin
wayland_scanner=${bindir}/wayland-scanner

Name: Wayland Scanner
Description: stub pointing at host wayland-scanner
Version: 1.24.0
EOF
    cp "$FFBUILD_PREFIX"/lib/pkgconfig/wayland-scanner.pc \
       "$FFBUILD_DESTPREFIX"/lib/pkgconfig/wayland-scanner.pc

    meson setup "${myconf[@]}" ..
    ninja -j"$(nproc)"
    DESTDIR="$FFBUILD_DESTDIR" ninja install
}
