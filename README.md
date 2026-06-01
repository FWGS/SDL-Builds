# SDL2 and SDL3 Auto-Builds

Linux builds of SDL master and latest release branch, targetting RHEL/CentOS 8 (glibc-2.28 + linux-4.18) and anything more recent.

## Auto-Builds

Builds run daily at 12:00 UTC (or GitHubs idea of that time) and are automatically released on success.

### Release Retention Policy

- The last build of each month is kept for two years.
- The last 14 daily builds are kept.
- The special "latest" build floats and provides consistent URLs always pointing to the latest build.

## Package List

For a list of included dependencies check the scripts.d directory.
Every file corresponds to its respective package.

## How to make a build

### Prerequisites

* bash
* docker or podman w/ docker wrapper

### Build Image

* `./makeimage.sh target variant [addin [addin] [addin] ...]`

### Build SDL

* `./build.sh target variant [addin [addin] [addin] ...]`

On success, the resulting zip file will be in the `artifacts` subdir.

### Targets, Variants and Addins

Available targets:
* `linux64` (64-bit x86 Linux, glibc>=2.28, linux>=4.18)
* `linux32` (32-bit x86 Linux, glibc>=2.28, linux>=4.18)
(and few more, untested)

Available variants:
* `sdl2` builds SDL2
* `sdl3` builds SDL3

All of those can be optionally combined with any combination of addins:
* `2.32`/`3.4` to build from the respective release branch instead of master.
* `debug` to not strip debug symbols from the binaries.
* `lto` build all dependencies and sdl with -flto=auto, untested.
