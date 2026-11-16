#!/bin/bash
#
# Rebuilds icon_extractor.jar from IconExtractor.java.
#
# Requires a JDK and an Android SDK with a platform and build-tools installed.

set -euo pipefail

cd "$(dirname "$0")"

java_home="${JAVA_HOME:-/Applications/Android Studio.app/Contents/jbr/Contents/Home}"
sdk="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
android_jar="$(ls "$sdk"/platforms/android-*/android.jar | tail -n 1)"

# d8 stamps its version into the jar, so it is pinned to keep builds reproducible.
d8="$sdk/build-tools/36.0.0/d8"

work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

"$java_home/bin/javac" -g:none --release 8 -Xlint:-options -classpath "$android_jar" -d "$work_dir/classes" IconExtractor.java
PATH="$java_home/bin:$PATH" "$d8" --release --lib "$android_jar" --output "$work_dir/icon_extractor.jar" "$work_dir"/classes/*.class
mv "$work_dir/icon_extractor.jar" icon_extractor.jar
