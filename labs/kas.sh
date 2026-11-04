#!/bin/sh
# Run KAS with the lab work and build directories kept inside labs/.
#
# Usage:
#   ./kas.sh build kas/qemu.yml
#   ./kas.sh shell kas/qemu.yml -c 'runqemu qemux86-64 training-image'
#   ./kas.sh checkout kas/qemu.yml
#
# The repository checkouts live in labs/work/ and the build in labs/build/.
# Both directories are ignored by git.

set -eu

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

export KAS_WORK_DIR="$here/work"
export KAS_BUILD_DIR="$here/build"

exec kas "$@"
