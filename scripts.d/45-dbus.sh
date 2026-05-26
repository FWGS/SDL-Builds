#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/dbus/dbus.git"
SCRIPT_COMMIT="958bf9db2100553bcd2fe2a854e1ebb42e886054"  # dbus-1.16.2

ffbuild_depends() {
    echo expat
}

ffbuild_enabled() {
    [[ $TARGET == linux* ]] || return 1
    return 0
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    local mycmake=(
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN"
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX"
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON
        -DBUILD_SHARED_LIBS=OFF
        -DDBUS_BUILD_TESTS=OFF
        -DDBUS_ENABLE_DOXYGEN_DOCS=OFF
        -DDBUS_ENABLE_XML_DOCS=OFF
        -DDBUS_INSTALL_SYSTEM_LIBS=OFF
        -DDBUS_SESSION_SOCKET_DIR=/tmp
        -DDBUS_WITH_GLIB=OFF
    )

    cmake -GNinja "${mycmake[@]}" ..
    ninja -j"$(nproc)"
    DESTDIR="$FFBUILD_DESTDIR" ninja install

    rm -rf "$FFBUILD_DESTPREFIX"/{bin,etc,share/dbus-1,share/doc,share/man,share/cmake}
}
