#!/usr/bin/env bash
set -euo pipefail

usage() {
    printf 'Usage: %s [FILTER]\nRun hardware RTL tests, optionally selecting names with unittest -k.\n' "${0##*/}"
}

if [[ $# -eq 1 && "$1" == "--help" ]]; then
    usage
    exit 0
fi
if [[ $# -gt 1 ]]; then
    usage >&2
    exit 2
fi

project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
build_dir="$project_root/hardware/build-sim"
if [[ ! -f "$build_dir/coyote_test/__init__.py" ]]; then
    printf 'Simulation configuration is missing. Configure and build it first:\n' >&2
    printf '  cmake -S %q -B %q\n  cmake --build %q --target sim\n' \
        "$project_root/hardware" "$build_dir" "$build_dir" >&2
    exit 1
fi

test_python=python3
if [[ -x "$build_dir/.venv/bin/python" ]]; then
    test_python="$build_dir/.venv/bin/python"
fi
export PYTHONPATH="$build_dir:$project_root/libstf/coyote/sim:$project_root/libstf/hardware/unit-tests:$project_root/hardware/unit-tests${PYTHONPATH:+:$PYTHONPATH}"
cd -- "$project_root"

test_args=(discover -v -s ./hardware/unit-tests -p '*_test.py')
if [[ $# -eq 1 ]]; then
    test_args+=(-k "$1")
fi
exec "$test_python" -m unittest "${test_args[@]}"
