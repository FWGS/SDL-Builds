#!/bin/bash

SDL_REPO="${SDL_REPO_OVERRIDE:-https://github.com/libsdl-org/SDL.git}"
SDL_BRANCH="${SDL_BRANCH_OVERRIDE:-SDL2}"
SDL_NAME="SDL2"

SDL_CMAKE_FLAGS=(
    -DSDL_SHARED=ON
    -DSDL_STATIC=OFF
    -DSDL_TEST=OFF
    -DSDL_CCACHE=OFF

    -DSDL_LIBSAMPLERATE=ON
    -DSDL_LIBSAMPLERATE_SHARED=OFF
)

if [[ $TARGET == linux* ]]; then
    SDL_CMAKE_FLAGS+=(
        # X11
        -DSDL_X11=ON
        -DSDL_X11_SHARED=OFF
        # workaround for static cross-compile
        -DHAVE_XGENERICEVENT=TRUE
        -DSDL_VIDEO_DRIVER_X11_HAS_XKBKEYCODETOKEYSYM=1

        # Wayland
        -DSDL_WAYLAND=ON
        -DSDL_WAYLAND_SHARED=OFF
        -DSDL_WAYLAND_LIBDECOR=OFF

        -DSDL_KMSDRM=OFF
        -DSDL_VULKAN=ON

        # Audio
        -DSDL_PULSEAUDIO=ON
        -DSDL_PULSEAUDIO_SHARED=OFF
        -DSDL_ALSA=ON
        -DSDL_ALSA_SHARED=OFF
        -DSDL_PIPEWIRE=OFF
        -DSDL_JACK=OFF
        -DSDL_SNDIO=OFF

        # IPC / hotplug
        -DSDL_DBUS=ON
        -DSDL_IBUS=ON
        -DSDL_HIDAPI=ON
        -DSDL_HIDAPI_LIBUSB=OFF
    )
fi
