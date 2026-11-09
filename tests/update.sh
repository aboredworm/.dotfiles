#!/usr/bin/env bash
set -euo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
ROOT="$(mktemp -d)"
trap 'rm -rf "$ROOT"' EXIT
export MOCK_INSTALL_LOG="$ROOT/install.log"

# Use a local upstream checkout so pull behavior needs no network or pushes.
upstream="$ROOT/upstream"
client="$ROOT/client"
git init --quiet --initial-branch=main "$upstream"
git -C "$upstream" config user.name 'Dotfiles test'
git -C "$upstream" config user.email 'dotfiles@example.test'
cp "$REPO_DIR/update.sh" "$upstream/update.sh"
cat > "$upstream/install.sh" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$@" >> "$MOCK_INSTALL_LOG"
EOF
chmod +x "$upstream/install.sh"
printf 'original\n' > "$upstream/config"
git -C "$upstream" add .
git -C "$upstream" commit --quiet -m 'Initial fixture'
git clone --quiet "$upstream" "$client"
git -C "$client" config user.name 'Dotfiles test'
git -C "$client" config user.email 'dotfiles@example.test'
git -C "$client" config status.showUntrackedFiles no

refuse_dirty_pull() {
  if "$client/update.sh" > "$ROOT/error.log" 2>&1; then
    echo 'FAIL: pulled a dirty checkout.' >&2
    exit 1
  fi
  grep -q 'Refusing to pull with local changes' "$ROOT/error.log"
  [[ ! -e "$MOCK_INSTALL_LOG" ]]
}

printf 'modified\n' >> "$client/config"
refuse_dirty_pull
git -C "$client" add config
refuse_dirty_pull
git -C "$client" restore --staged --worktree config
printf 'untracked\n' > "$client/local-config"
refuse_dirty_pull
# --no-pull must preserve local edits and forward installer arguments.
"$client/update.sh" --no-pull --profile archlinux --dry-run
printf '%s\n' --profile archlinux --dry-run > "$ROOT/expected-args"
cmp "$ROOT/expected-args" "$MOCK_INSTALL_LOG"
rm "$client/local-config" "$MOCK_INSTALL_LOG"
rm "$client/config"
refuse_dirty_pull
git -C "$client" restore config

printf 'upstream update\n' >> "$upstream/config"
git -C "$upstream" add config
git -C "$upstream" commit --quiet -m 'Advance upstream'
"$client/update.sh" --profile archlinux > "$ROOT/ff.log" 2>&1
[[ "$(git -C "$client" rev-parse HEAD)" == "$(git -C "$upstream" rev-parse HEAD)" ]]
printf '%s\n' --profile archlinux > "$ROOT/expected-args"
cmp "$ROOT/expected-args" "$MOCK_INSTALL_LOG"
rm "$MOCK_INSTALL_LOG"

printf 'local commit\n' > "$client/local-config"
git -C "$client" add local-config
git -C "$client" commit --quiet -m 'Local commit'
local_tip="$(git -C "$client" rev-parse HEAD)"
printf 'another upstream update\n' >> "$upstream/config"
git -C "$upstream" add config
git -C "$upstream" commit --quiet -m 'Diverge upstream'
if "$client/update.sh" > "$ROOT/diverged.log" 2>&1; then
  echo 'FAIL: accepted a non-fast-forward update.' >&2
  exit 1
fi
[[ "$(git -C "$client" rev-parse HEAD)" == "$local_tip" ]]
[[ ! -e "$MOCK_INSTALL_LOG" ]]
printf 'Update tests passed: dirty checkout protection, argument forwarding, local fast-forward, divergence rejection.\n'
