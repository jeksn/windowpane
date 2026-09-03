#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

"$ROOT/Scripts/package_app.sh" debug

if pgrep -x WindowPane > /dev/null 2>&1; then
    pkill -x WindowPane || true
    sleep 0.3
fi

open "$ROOT/WindowPane.app"
echo "WindowPane launched"
