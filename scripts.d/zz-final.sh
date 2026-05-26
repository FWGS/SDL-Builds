#!/bin/bash

SCRIPT_SKIP="1"

ffbuild_depends() {
    echo base
    echo zlib
    echo libiconv
    echo libsamplerate
    echo pulseaudio
    echo alsa
    echo x11
    echo libffi
    echo wayland
    echo wayland-protocols
    echo libxkbcommon
    echo libudev
    echo dbus
    echo expat
    echo vulkan-headers
}

ffbuild_enabled() {
    return 0
}

ffbuild_dockerfinal() {
    return 0
}

ffbuild_dockerdl() {
    return 0
}

ffbuild_dockerlayer() {
    return 0
}

ffbuild_dockerstage() {
    return 0
}

ffbuild_dockerbuild() {
    return 0
}
