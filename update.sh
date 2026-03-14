#!/bin/bash
set -e

cd "$(dirname "$0")"

git pull
git submodule update --remote
git add Sources

if git diff --cached --quiet; then
  echo "No submodule changes to commit."
  exit 0
fi

# Show last 5 commits for submodules with staged changes
git diff --cached --name-only | while read -r path; do
  if [ -d "$path" ]; then
    name=$(basename "$path")
    echo "== $name =="
    git --no-pager -C "$path" log --format="%C(cyan)%ad %C(auto)%h %C(reset)%s" --date=short -5
    echo ""
  fi
done

git status

read -r -p "Commit message: " msg
git commit -m "$msg"

echo "Last tag: $(git describe --tags --abbrev=0 2>/dev/null || echo 'none')"
read -r -p "Tag version (leave empty to skip): " tag
if [ -n "$tag" ]; then
  git tag -a "$tag" -m "$tag"
fi

git push origin main --tags
