#!/bin/sh
# Publish a new BalkanRadio release: bump -> analyze -> test -> build ->
# gate -> version.json -> commit -> push -> GitHub Release -> verify.
#
# Usage:
#   ./release.sh            # publish the next patch version
#   ./release.sh 1.3.20     # publish a specific version
#   ./release.sh --dry-run  # everything except commit/push/release
#   ./release.sh --allow-major 1.4.0  # allow more than a patch jump
#
# The version files are backed up first and restored automatically if any
# step fails, so a broken release never leaves a half-bumped project behind.

set -eu

# The project directory: this script lives in it, so it works from a clone.
PROJECT=$(cd "$(dirname "$0")" && pwd)
APK_SHARE="$HOME/apk-share"
REPO="BeliVukOF/BalkanRadio"
AAPT="$HOME/Android/Sdk/build-tools/36.0.0/aapt2"
VERSION_FILES="pubspec.yaml version.json lib/ui/screens/settings_screen.dart lib/services/update_service.dart"

# Same environment as ~/fl.sh.
export PATH="/opt/flutter/bin:$PATH"
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export JAVA_HOME="/opt/android-studio/jbr"

DRY=0
ALLOW_MAJOR=0
WANT=""
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY=1 ;;
        --allow-major) ALLOW_MAJOR=1 ;;
        [0-9]*.[0-9]*.[0-9]*) WANT="$arg" ;;
        *) echo "unknown argument: $arg" >&2; exit 2 ;;
    esac
done

fail() { echo "FAIL: $*" >&2; exit 1; }
step() { echo; echo "=== $* ==="; }

[ -d "$PROJECT" ] || fail "project not found: $PROJECT"
cd "$PROJECT" || fail "cannot enter $PROJECT"

step "current state"
git status --short
CURRENT_NAME=$(sed -n 's/^version: \([0-9.]*\)+.*/\1/p' pubspec.yaml)
CURRENT_CODE=$(sed -n 's/^version: [0-9.]*+\([0-9]*\)$/\1/p' pubspec.yaml)
[ -n "$CURRENT_NAME" ] && [ -n "$CURRENT_CODE" ] || fail "cannot read the version from pubspec.yaml"
echo "current: $CURRENT_NAME+$CURRENT_CODE"

if [ -z "$WANT" ]; then
    NEW_NAME=$(printf '%s' "$CURRENT_NAME" | awk -F. '{printf "%s.%s.%d", $1, $2, $3+1}')
else
    NEW_NAME="$WANT"
fi
NEW_CODE=$((CURRENT_CODE + 1))
echo "publishing: $NEW_NAME+$NEW_CODE"

# A release must be strictly newer than the current version.
[ "$NEW_NAME" != "$CURRENT_NAME" ] || fail "$NEW_NAME is not newer than $CURRENT_NAME"
LATEST=$(printf '%s\n%s\n' "$CURRENT_NAME" "$NEW_NAME" | sort -V | tail -1)
[ "$LATEST" = "$NEW_NAME" ] || fail "$NEW_NAME is not newer than $CURRENT_NAME"

# A typo like 9.9.9 must not become a release. Only the patch part may
# change unless --allow-major is given.
OLD_MINOR=$(printf '%s' "$CURRENT_NAME" | cut -d. -f2)
NEW_MINOR=$(printf '%s' "$NEW_NAME" | cut -d. -f2)
OLD_MAJOR=$(printf '%s' "$CURRENT_NAME" | cut -d. -f1)
NEW_MAJOR=$(printf '%s' "$NEW_NAME" | cut -d. -f1)
if [ "$OLD_MINOR" != "$NEW_MINOR" ] || [ "$OLD_MAJOR" != "$NEW_MAJOR" ]; then
    [ "$ALLOW_MAJOR" = "1" ] \
        || fail "$NEW_NAME jumps more than a patch version; pass --allow-major if that is intended"
fi

step "preflight"
gh auth status >/dev/null 2>&1 || fail "gh is not logged in (gh auth status)"
if gh release view "v$NEW_NAME" >/dev/null 2>&1; then
    fail "release v$NEW_NAME already exists - bump the version instead"
fi
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "note: the working tree has uncommitted changes; they stay uncommitted."
    git status --short
fi

# Back up the version files: a failed release must not leave the project
# with a version that was never published.
BACKUP=$(mktemp -d)
for f in $VERSION_FILES; do
    mkdir -p "$BACKUP/$(dirname "$f")"
    cp "$f" "$BACKUP/$f"
done
SUCCESS=0
cleanup() {
    if [ "$SUCCESS" != "1" ] && [ "$DRY" != "1" ]; then
        for f in $VERSION_FILES; do
            [ -f "$BACKUP/$f" ] && cp "$BACKUP/$f" "$PROJECT/$f"
        done
        echo "the version files were restored"
    fi
    rm -rf "$BACKUP"
}
trap cleanup EXIT

step "bump the version"
sed -i "s/^version: .*/version: $NEW_NAME+$NEW_CODE/" pubspec.yaml
sed -i "s/const String appVersion = '[^']*';/const String appVersion = '$NEW_NAME';/" \
    lib/ui/screens/settings_screen.dart
sed -i "s/static const String currentVersionName = '[^']*';/static const String currentVersionName = '$NEW_NAME';/" \
    lib/services/update_service.dart
sed -i "s/static const int currentVersionCode = [0-9]*;/static const int currentVersionCode = $NEW_CODE;/" \
    lib/services/update_service.dart

grep -q "^version: $NEW_NAME+$NEW_CODE$" pubspec.yaml || fail "pubspec bump failed"
grep -q "const String appVersion = '$NEW_NAME';" lib/ui/screens/settings_screen.dart \
    || fail "settings_screen bump failed"
grep -q "static const String currentVersionName = '$NEW_NAME';" lib/services/update_service.dart \
    || fail "update_service name bump failed"
grep -q "static const int currentVersionCode = $NEW_CODE;" lib/services/update_service.dart \
    || fail "update_service code bump failed"
echo "bumped: $NEW_NAME+$NEW_CODE"

# version.json has to describe the new version BEFORE the test runs, because
# "version.json publishes the running version" is the gate that catches a
# half-finished bump. The real checksum is written after the build.
cat > version.json <<JSON
{
  "versionName": "$NEW_NAME",
  "versionCode": $NEW_CODE,
  "apkUrl": "https://github.com/$REPO/releases/download/v$NEW_NAME/BalkanRadio-$NEW_NAME.apk",
  "sha256": "pending",
  "sizeBytes": 0
}
JSON

step "analyze"
flutter analyze || fail "analyze failed"

step "test"
flutter test || fail "tests failed"

step "build release APK"
flutter build apk --release || fail "build failed"
APK="build/app/outputs/flutter-apk/app-release.apk"
[ -f "$APK" ] || fail "APK not found: $APK"

step "gate: the built APK must carry the version we publish"
BADGING=$("$AAPT" dump badging "$APK" 2>/dev/null | head -1)
echo "$BADGING"
case "$BADGING" in
    *"versionCode='$NEW_CODE'"*"versionName='$NEW_NAME'"*) ;;
    *) fail "built APK does not match $NEW_NAME+$NEW_CODE" ;;
esac

mkdir -p "$APK_SHARE"
cp "$APK" "$APK_SHARE/BalkanRadio-$NEW_NAME.apk"
SHA=$(sha256sum "$APK_SHARE/BalkanRadio-$NEW_NAME.apk" | cut -d' ' -f1)
SIZE=$(stat -c %s "$APK_SHARE/BalkanRadio-$NEW_NAME.apk")
echo "sha256: $SHA"
echo "size:   $SIZE"

if [ "$DRY" = "1" ]; then
    step "dry run: stopping before commit, push and release"
    for f in $VERSION_FILES; do
        cp "$BACKUP/$f" "$PROJECT/$f"
    done
    echo "the version files were restored - nothing in $PROJECT changed"
    echo "APK built at: $APK_SHARE/BalkanRadio-$NEW_NAME.apk"
    exit 0
fi

step "write the real checksum into version.json"
cat > version.json <<JSON
{
  "versionName": "$NEW_NAME",
  "versionCode": $NEW_CODE,
  "apkUrl": "https://github.com/$REPO/releases/download/v$NEW_NAME/BalkanRadio-$NEW_NAME.apk",
  "sha256": "$SHA",
  "sizeBytes": $SIZE
}
JSON

step "commit"
git add pubspec.yaml version.json \
    lib/ui/screens/settings_screen.dart lib/services/update_service.dart
git commit -m "release: $NEW_NAME" || fail "commit failed"

step "push"
git push origin main || fail "push failed"

step "GitHub release"
gh release create "v$NEW_NAME" "$APK_SHARE/BalkanRadio-$NEW_NAME.apk" \
    --title "v$NEW_NAME" \
    --notes "Balkan Radio $NEW_NAME.

- what changed in this version" || fail "release failed"

step "verify the published asset"
ASSETS=$(gh release view "v$NEW_NAME" --json assets --jq '.assets[].name')
echo "assets: $ASSETS"
case "$ASSETS" in
    *"BalkanRadio-$NEW_NAME.apk"*) ;;
    *) fail "the asset is not named BalkanRadio-$NEW_NAME.apk" ;;
esac

# Download what users actually get and compare it with the local build.
VDIR=$(mktemp -d)
curl -sL -o "$VDIR/BalkanRadio-$NEW_NAME.apk" \
    "https://github.com/$REPO/releases/download/v$NEW_NAME/BalkanRadio-$NEW_NAME.apk"
REMOTE_SHA=$(sha256sum "$VDIR/BalkanRadio-$NEW_NAME.apk" | cut -d' ' -f1)
REMOTE_SIZE=$(stat -c %s "$VDIR/BalkanRadio-$NEW_NAME.apk")
rm -rf "$VDIR"
echo "published sha256: $REMOTE_SHA"
echo "published size:   $REMOTE_SIZE"
[ "$REMOTE_SHA" = "$SHA" ] || fail "the published APK is not the APK we built"
[ "$REMOTE_SIZE" = "$SIZE" ] || fail "the published APK has a different size"

SUCCESS=1
step "done"
echo "published v$NEW_NAME ($NEW_NAME+$NEW_CODE)"
echo "APK: $APK_SHARE/BalkanRadio-$NEW_NAME.apk"
echo "sha256: $SHA"
