#!/usr/bin/env bash
set -euo pipefail

FLAKE_FILE="$PWD/default.nix" # Update this if needed

echo "🔍 Checking for Prisma Language Server updates..."

latest_version=$(curl -s https://registry.npmjs.org/@prisma/language-server | jq -r '.["dist-tags"].latest')
current_version=$(grep '^  version = "' "$FLAKE_FILE" | sed -E 's/.*"([^"]+)".*/\1/')

echo "Current version: $current_version"
echo "Latest version:  $latest_version"

if [[ "$latest_version" == "$current_version" ]]; then
	echo "✅ Already up-to-date."
	exit 0
fi

echo "⬇️  Fetching new tarball..."
url="https://registry.npmjs.org/@prisma/language-server/-/language-server-${latest_version}.tgz"
curl -L "$url" -o /tmp/prisma.tgz

echo "🔢 Computing SHA256..."
sha256=$(nix hash file /tmp/prisma.tgz)

echo "✍️  Updating $FLAKE_FILE..."

# Update version in `let` binding
sed -i "s|^  version = \".*\";|  version = \"$latest_version\";|" "$FLAKE_FILE"

# Update sha256 in `let` binding
sed -i "s|^  sha256 = \".*\";|  sha256 = \"$sha256\";|" "$FLAKE_FILE"

echo "🔄 Regenerating lock.json with dream2nix..."
nix run .#default.lock

echo "✅ Update complete: version $latest_version, lock.json regenerated."
