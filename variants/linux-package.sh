#!/bin/bash

package_variant() {
    local IN="$1"
    local OUT="$2"

    mkdir -p "$OUT"/lib
    cp -a "$IN"/lib/lib*.so* "$OUT"/lib

    mkdir -p "$OUT"/lib/pkgconfig
    cp -a "$IN"/lib/pkgconfig/*.pc "$OUT"/lib/pkgconfig
    sed -i \
        -e 's|^prefix=.*|prefix=${pcfiledir}/../..|' \
        -e 's|/opt/ffbuild|${prefix}|' \
        "$OUT"/lib/pkgconfig/*.pc

    mkdir -p "$OUT"/include
    cp -r "$IN"/include/* "$OUT"/include

    if [[ -d "$IN"/lib/cmake ]]; then
        mkdir -p "$OUT"/lib/cmake
        cp -r "$IN"/lib/cmake/* "$OUT"/lib/cmake
    fi
}
