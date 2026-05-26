#!/bin/bash
set -e

if [[ $# -lt 2 ]]; then
    echo "Missing arguments"
    exit -1
fi

RELEASE_DIR="$(realpath "$1")"
shift
mkdir -p "$RELEASE_DIR"

rm -rf repack_dir
mkdir repack_dir
trap "rm -rf repack_dir" EXIT

while [[ $# -gt 0 ]]; do
    INPUT="$1"
    shift

    (
        set -e
        REPACK_DIR="repack_dir/$BASHPID"
        rm -rf "$REPACK_DIR"
        mkdir "$REPACK_DIR"

        if [[ $INPUT == *.tar.xz ]]; then
            tar xvaf "$INPUT" -C "$REPACK_DIR"
        else
            echo "Unknown input file type: $INPUT"
            exit 1
        fi

        cd "$REPACK_DIR"

        INAME="$(echo sdl*-*)"
        PREFIX="${INAME%%-*}"
        TAIL="$(grep -oE 'linux[a-z0-9]+(-.*)?$' <<<"$INAME")"
        ONAME="${PREFIX}-latest-${TAIL}"

        mv "$INAME" "$ONAME"

        tar cvJf "$RELEASE_DIR/$ONAME.tar.xz" "$ONAME"

        rm -rf "$REPACK_DIR"
    ) &

    while [[ $(jobs | wc -l) -gt 3 ]]; do
        wait %1
    done
done

while [[ $(jobs | wc -l) -gt 0 ]]; do
    wait %1
done
rm -rf repack_dir
