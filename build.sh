#!/bin/bash
set -xe
shopt -s globstar
cd "$(dirname "$0")"
source util/vars.sh

source "variants/${TARGET}-${VARIANT}.sh"

for addin in ${ADDINS[*]}; do
    source "addins/${addin}.sh"
done

if docker info 2>/dev/null | grep -qEi 'rootless|podman'; then
    UIDARGS=()
else
    UIDARGS=( -u "$(id -u):$(id -g)" )
fi

rm -rf ffbuild
mkdir ffbuild

BUILD_SCRIPT="$(mktemp)"
trap "rm -f -- '$BUILD_SCRIPT'" EXIT

PATCH_DIRS=()
for addin in "${ADDINS[@]}"; do
    [[ -d "patches/$addin" ]] && PATCH_DIRS+=( "patches/$addin" )
done

cat <<EOF >"$BUILD_SCRIPT"
    set -xe
    cd /ffbuild
    rm -rf sdl prefix

    git clone --filter=blob:none --branch='$SDL_BRANCH' '$SDL_REPO' sdl
    cd sdl
    SDL_VERSION="\$(git describe --tags --always)"
    echo "\$SDL_VERSION" > /ffbuild/sdl.version

    for d in ${PATCH_DIRS[*]}; do
        for p in /patches/\${d#patches/}/*.patch; do
            [[ -f "\$p" ]] && git am "\$p"
        done
    done

    export PKG_CONFIG="pkg-config --static"

    mkdir build && cd build
    # HACKHACK: link X11 dependencies manually
    cmake -GNinja \
        -DCMAKE_TOOLCHAIN_FILE="\$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/ffbuild/prefix \
        -DCMAKE_C_STANDARD_LIBRARIES="-Wl,--start-group -lxcb -lXau -lXrender -Wl,--end-group" \
        ${SDL_CMAKE_FLAGS[@]} \
        ..

    ninja -j\$(nproc) -v
    ninja install
EOF

[[ -t 1 ]] && TTY_ARG="-t" || TTY_ARG=""

PATCH_MOUNT=()
[[ ${#PATCH_DIRS[@]} -gt 0 ]] && PATCH_MOUNT=( -v "$PWD/patches":/patches:ro )

docker run --rm -i $TTY_ARG "${UIDARGS[@]}" -v "$PWD/ffbuild":/ffbuild -v "$BUILD_SCRIPT":/build.sh "${PATCH_MOUNT[@]}" "$IMAGE" bash /build.sh

SDL_VERSION="$(cat ffbuild/sdl.version)"

if [[ -n "$FFBUILD_OUTPUT_DIR" ]]; then
    mkdir -p "$FFBUILD_OUTPUT_DIR"
    package_variant ffbuild/prefix "$FFBUILD_OUTPUT_DIR"
    cp ffbuild/sdl/LICENSE.txt "$FFBUILD_OUTPUT_DIR/LICENSE.txt" 2>/dev/null || true
    rm -rf ffbuild
    exit 0
fi

mkdir -p artifacts
ARTIFACTS_PATH="$PWD/artifacts"
BUILD_NAME="${SDL_NAME,,}-${SDL_VERSION}-${TARGET}${ADDINS_STR:+-}${ADDINS_STR}"

mkdir -p "ffbuild/pkgroot/$BUILD_NAME"
package_variant ffbuild/prefix "ffbuild/pkgroot/$BUILD_NAME"
cp ffbuild/sdl/LICENSE.txt "ffbuild/pkgroot/$BUILD_NAME/LICENSE.txt" 2>/dev/null || true

cd ffbuild/pkgroot
OUTPUT_FNAME="${BUILD_NAME}.tar.xz"
docker run --rm -i $TTY_ARG "${UIDARGS[@]}" -v "${ARTIFACTS_PATH}":/out -v "${PWD}/${BUILD_NAME}":"/${BUILD_NAME}" -w / "$IMAGE" tar cJf "/out/${OUTPUT_FNAME}" "$BUILD_NAME"
cd -

rm -rf ffbuild

if [[ -n "$GITHUB_ACTIONS" ]]; then
    echo "build_name=${BUILD_NAME}" >> "$GITHUB_OUTPUT"
    echo "${OUTPUT_FNAME}" > "${ARTIFACTS_PATH}/${TARGET}-${VARIANT}${ADDINS_STR:+-}${ADDINS_STR}.txt"
fi
