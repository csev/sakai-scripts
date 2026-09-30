#!/bin/bash

set -e

echo "Patching Sakai trunk for macOS 11 Big Sur..."

ROOT="$(pwd)"

if [ ! -f "$ROOT/master/pom.xml" ]; then
    echo "ERROR: Run this from the root of the Sakai trunk."
    exit 1
fi

NODE_VERSION="20.19.0"
ESBUILD_VERSION="0.25.12"

#
# 1. Backlevel Sakai's bundled Node version
#
echo "Patching Node version..."

python3 - <<PY
from pathlib import Path

p = Path("master/pom.xml")
s = p.read_text()

old = "<sakai.node.version>v22.14.0</sakai.node.version>"
new = "<sakai.node.version>v${NODE_VERSION}</sakai.node.version>"

if old in s:
    p.write_text(s.replace(old, new))
    print("Node: v22.14.0 -> v${NODE_VERSION}")
elif new in s:
    print("Node already patched")
else:
    raise SystemExit("ERROR: Expected sakai.node.version not found")
PY

#
# 2. Surgically backlevel esbuild in package.json
#
echo "Patching esbuild..."

python3 - <<PY
from pathlib import Path

p = Path("webcomponents/tool/src/main/frontend/package.json")
s = p.read_text()

old = '"esbuild": "^0.27.3"'
new = '"esbuild": "${ESBUILD_VERSION}"'

if old in s:
    p.write_text(s.replace(old, new))
    print("esbuild: ^0.27.3 -> ${ESBUILD_VERSION}")
elif new in s:
    print("esbuild already patched")
else:
    raise SystemExit("ERROR: Expected esbuild dependency not found")
PY

#
# 3. Download a temporary modern Node/npm just to update package-lock.json
#
TMPNODE="/tmp/sakai-big-sur-node-${NODE_VERSION}"

rm -rf "$TMPNODE"
mkdir -p "$TMPNODE"

echo "Downloading temporary Node v${NODE_VERSION}..."

curl -fsSL \
  "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-darwin-x64.tar.gz" \
  | tar xz -C "$TMPNODE"

NODEHOME="$TMPNODE/node-v${NODE_VERSION}-darwin-x64"

#
# 4. Update package-lock.json without reformatting package.json
#
FRONTEND="$ROOT/webcomponents/tool/src/main/frontend"

cd "$FRONTEND"

"$NODEHOME/bin/node" \
  "$NODEHOME/lib/node_modules/npm/bin/npm-cli.js" \
  install --package-lock-only --ignore-scripts

cd "$ROOT"

rm -rf "$TMPNODE"

echo
echo "Big Sur patches applied:"
echo "  Node:    v${NODE_VERSION}"
echo "  esbuild: ${ESBUILD_VERSION}"
echo
echo "Changes:"

git diff --stat

