#!/usr/bin/env bash
# Usage: orphan-nix-files.sh SRC ROOT...
# Print the .nix files under SRC that no ROOT reaches by following relative
# path literals (./x.nix, ../dir). References in comments count: a
# commented-out import marks a parked module, not an orphan. A directory
# reference means its default.nix. Exits 1 if any file is unreached.
set -eu
cd "$1"
shift

declare -A seen
queue=("$@")
while [ ${#queue[@]} -gt 0 ]; do
  file=${queue[0]}
  queue=("${queue[@]:1}")
  [ -n "${seen[$file]:-}" ] && continue
  seen[$file]=1
  dir=$(dirname "$file")
  for ref in $(grep -oE '\.\.?/[A-Za-z0-9._/-]*' "$file" || true); do
    path=$(realpath -m --relative-to=. "$dir/$ref")
    [ -d "$path" ] && path=$path/default.nix
    [[ $path == *.nix && -f $path ]] && queue+=("$path")
  done
done

orphans=$(find . -name '*.nix' -printf '%P\n' | sort | while read -r file; do
  [ -n "${seen[$file]:-}" ] || echo "$file"
done)
if [ -n "$orphans" ]; then
  echo "Not imported (or parked in a commented-out import) from flake.nix or any host's home/cino/<host>.nix:"
  echo "$orphans"
  exit 1
fi
