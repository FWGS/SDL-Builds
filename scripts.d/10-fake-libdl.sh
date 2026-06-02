#!/bin/bash

# HACKHACK: generate dummy libdl/librt for following architectures
ffbuild_enabled() {
    case "$TARGET" in
        linuxppc64|linuxmips64|linuxriscv64) return 0 ;;
        *) return -1 ;;
    esac
}

ffbuild_depends() {
    return 0
}

ffbuild_dockerdl() {
    return 0
}

ffbuild_dockerbuild() {
    mkdir -p "$FFBUILD_DESTPREFIX/lib"
    for stub in libdl librt; do
        cat > "$FFBUILD_DESTPREFIX/lib/${stub}.so" <<EOF
GROUP ( AS_NEEDED ( libc.so.6 ) )
EOF
    done
}
