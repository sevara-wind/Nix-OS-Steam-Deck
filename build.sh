#!/usr/bin/env bash
# Build the Steam Deck configuration deterministically, keeping the flake.lock
# in sync with upstream and pushing lock changes back.
#
# Usage:  sudo ./build.sh
#
# What it does:
#   1. Fetch the latest main and hard-reset local /etc/nixos to it (handles
#      rewritten / diverged histories without a merge conflict).
#   2. Refresh the lock file (re-fetches remote inputs; fixes the volatile
#      steamidra narHash drift on the Steam Deck).
#   3. Commit + push the refreshed flake.lock so the repo always stays valid.
#   4. Build and switch the system.
set -euo pipefail

cd /etc/nixos

if [ "$(id -u)" -ne 0 ]; then
  echo "Запустите под sudo (нужны права root для /etc/nixos)." >&2
  exit 1
fi

if [ "${NIX_UNSTABLE_FORCE_RESET:-1}" = "1" ] || git rev-parse --verify --quiet origin/main >/dev/null; then
  echo "==> Синхронизация с remote (hard reset на origin/main) ..."
  git fetch origin
  git reset --hard origin/main
  git clean -fd
else
  echo "Нет remote origin/main — пропускаю синхронизацию."
fi

# Git identity (если ещё не задана глобально под root)
git config user.name  >/dev/null 2>&1 || git config user.name  "sevara-wind"
git config user.email >/dev/null 2>&1 || git config user.email "sevara.wind@icloud.com"

echo "==> Обновление flake.lock (фиксирует волатильный steamidra narHash)..."
nix flake lock

if git diff --quiet -- flake.lock; then
  echo "==> flake.lock без изменений — пропускаю коммит."
else
  echo "==> Коммит и пуш flake.lock ..."
  git add flake.lock
  git commit -m "Update flake.lock"
  git push origin main
fi

echo "==> Сборка и переключение системы ..."
nixos-rebuild switch --flake .#steamdeck

echo "==> Готово."