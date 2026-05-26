#!/bin/bash
SDL_CMAKE_FLAGS+=( -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON )

ffbuild_dockeraddin() {
    to_df 'ENV CFLAGS="$CFLAGS -flto=auto" CXXFLAGS="$CXXFLAGS -flto=auto" LDFLAGS="$LDFLAGS -flto=auto"'
    to_df 'ENV FFBUILD_TARGET_FLAGS="$FFBUILD_TARGET_FLAGS --ar=${FFBUILD_TOOLCHAIN}-gcc-ar --nm=${FFBUILD_TOOLCHAIN}-gcc-nm --ranlib=${FFBUILD_TOOLCHAIN}-gcc-ranlib"'
}
