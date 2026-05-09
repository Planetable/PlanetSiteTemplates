#!/usr/bin/env zsh
setopt err_exit no_unset pipe_fail

usage() {
  cat <<'USAGE'
Usage:
  update-and-report.sh --update [--allow-dirty]
  update-and-report.sh --report-only

Options:
  --update       Run git pull --ff-only and git submodule update --init --remote.
  --report-only  Only report current submodule pointer changes.
  --allow-dirty Allow running --update when the superproject already has changes.
  -h, --help     Show this help.
USAGE
}

typeset -i run_update=0
typeset -i allow_dirty=0

if (( $# == 0 )); then
  usage
  exit 2
fi

while (( $# > 0 )); do
  case "$1" in
    --update)
      run_update=1
      ;;
    --report-only)
      run_update=0
      ;;
    --allow-dirty)
      allow_dirty=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "Not inside a git repository." >&2
  exit 1
}
cd "$root"

if [[ "$(basename "$root")" != "PlanetSiteTemplates" || ! -f ".gitmodules" ]]; then
  echo "This helper must be run from the PlanetSiteTemplates bundled template collection." >&2
  exit 1
fi

has_dirty_state() {
  [[ -n "$(git status --porcelain --ignore-submodules=none)" ]]
}

if (( run_update == 1 )); then
  if (( allow_dirty == 0 )) && has_dirty_state; then
    echo "Refusing to update with an existing dirty superproject state." >&2
    echo "Review or commit these changes first, or rerun with --allow-dirty:" >&2
    git status --short >&2
    exit 2
  fi

  echo "== Updating superproject =="
  git pull --ff-only

  echo
  echo "== Updating submodules =="
  git submodule update --init --remote
fi

echo
echo "== Superproject status =="
git status --short

echo
echo "== Submodule pointer diff =="
if git diff --quiet --ignore-submodules=none && git diff --cached --quiet --ignore-submodules=none; then
  echo "No superproject diffs."
else
  git diff --submodule=log --ignore-submodules=none
  git diff --cached --submodule=log --ignore-submodules=none
fi

submodule_paths=("${(@f)$(git config --file .gitmodules --get-regexp '^submodule\..*\.path$' | awk '{print $2}')}")

typeset -i changed_count=0

for path in "${submodule_paths[@]}"; do
  old_sha="$(git rev-parse -q --verify "HEAD:$path" 2>/dev/null || true)"
  index_sha="$(git rev-parse -q --verify ":$path" 2>/dev/null || true)"
  worktree_sha=""
  if [[ -d "$path" ]]; then
    worktree_sha="$(git -C "$path" rev-parse HEAD 2>/dev/null || true)"
  fi

  if [[ -n "$old_sha" && "$old_sha" == "$index_sha" && "$old_sha" == "$worktree_sha" ]]; then
    continue
  fi

  if [[ -z "$old_sha" && -z "$index_sha" && -z "$worktree_sha" ]]; then
    continue
  fi

  changed_count=$((changed_count + 1))
  new_sha="$worktree_sha"
  if [[ -z "$new_sha" ]]; then
    new_sha="$index_sha"
  fi

  echo
  echo "== Changed submodule: $path =="
  echo "old:      ${old_sha:-none}"
  echo "index:    ${index_sha:-none}"
  echo "worktree: ${worktree_sha:-none}"

  if [[ -n "$old_sha" && -n "$new_sha" && "$old_sha" != "$new_sha" && -d "$path" ]]; then
    echo
    echo "-- commits --"
    git -C "$path" log --oneline --decorate "$old_sha..$new_sha" || true

    echo
    echo "-- diff stat --"
    git -C "$path" diff --stat "$old_sha..$new_sha" || true

    echo
    echo "-- changed files --"
    git -C "$path" diff --name-status "$old_sha..$new_sha" || true
  fi

  if [[ -f "$path/template.json" ]]; then
    echo
    echo "-- template metadata --"
    if command -v jq >/dev/null 2>&1; then
      jq -r '"name=\(.name // "unknown") version=\(.version // "unknown") buildNumber=\(.buildNumber // "unknown")"' "$path/template.json" || true
    else
      sed -n '1,24p' "$path/template.json"
    fi
  fi
done

if (( changed_count == 0 )); then
  echo
  echo "No changed submodule pointers detected."
fi
