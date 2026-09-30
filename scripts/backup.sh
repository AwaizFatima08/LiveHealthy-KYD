#!/usr/bin/env bash
# Backs up LiveHealthy: Know Your Disease:
#   1. Local mirror (INCLUDING secrets/ — the release keystore lives here)
#      -> /mnt/storage/project_backups/LiveHealthy_KYD_Backup/
#   2. Google Drive (rclone remote "gdrive:"), EXCLUDING secrets/ and any
#      signing/credential files — keystores and passwords never go to cloud storage.
#      https://drive.google.com/drive/folders/1oju0RM26IHeiDILfdkIlJQMveIeDZgX5
set -euo pipefail
SRC="$(cd "$(dirname "$0")/.." && pwd)"
LOCAL=/mnt/storage/project_backups/LiveHealthy_KYD_Backup
DRIVE_FOLDER_ID=1oju0RM26IHeiDILfdkIlJQMveIeDZgX5
STAMP=$(date +%Y%m%d_%H%M)

EXCLUDES=(--exclude 'build/' --exclude '.venv/' --exclude '__pycache__/' --exclude '.dart_tool/' --exclude 'node_modules/'
          --exclude '.gradle/' --exclude '.idea/' --exclude '*.iml' --exclude '.cxx/')

echo "== Local mirror -> $LOCAL/current"
mkdir -p "$LOCAL"
rsync -a --delete "${EXCLUDES[@]}" "$SRC/" "$LOCAL/current/"

echo "== Local snapshot archive"
tar -C "$(dirname "$SRC")" -czf "$LOCAL/live_healthy_kyd_${STAMP}.tar.gz" \
  --exclude='*/build' --exclude='*/.dart_tool' --exclude='*/node_modules' --exclude='*/.gradle' \
  "$(basename "$SRC")"
# Keep the 10 newest snapshots.
ls -1t "$LOCAL"/live_healthy_kyd_*.tar.gz | tail -n +11 | xargs -r rm --

# Release artifacts are worth keeping alongside (rebuildable but slow).
if [ -f "$SRC/app/build/app/outputs/bundle/release/app-release.aab" ]; then
  mkdir -p "$LOCAL/release"
  cp "$SRC/app/build/app/outputs/bundle/release/app-release.aab" "$LOCAL/release/"
  cp "$SRC/app/build/app/outputs/flutter-apk/app-release.apk" "$LOCAL/release/" 2>/dev/null || true
fi

echo "== Google Drive (no secrets)"
rclone sync "$SRC" "gdrive:" --drive-root-folder-id "$DRIVE_FOLDER_ID" \
  "${EXCLUDES[@]}" --exclude '.git/**' --exclude 'secrets/**' --exclude '**/key.properties' \
  --exclude '*.jks' --exclude '*.keystore' --exclude '**/google-services.json' \
  --exclude '**/local.properties' --fast-list --transfers 8
if [ -f "$SRC/app/build/app/outputs/bundle/release/app-release.aab" ]; then
  rclone copy "$SRC/app/build/app/outputs/bundle/release/app-release.aab" "gdrive:release" \
    --drive-root-folder-id "$DRIVE_FOLDER_ID"
fi
echo "Backup complete ($STAMP)."
