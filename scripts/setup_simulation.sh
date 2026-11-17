#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

# Coyote's Tcl scripts use tput even in batch mode.
if [[ -z "${TERM:-}" || "$TERM" == "dumb" ]]; then
    export TERM=xterm
fi

# Reconfigure in place, preserving the Python environment and simulation logs.
cmake -S "$project_root/hardware" -B "$project_root/hardware/build-sim"
cmake --build "$project_root/hardware/build-sim" --target sim
