et -euo pipefail

cd "$BASE"

export FUTURERESTORE_VERSION=$(git rev-list --count HEAD)
export FUTURERESTORE_VERSION_SHA=$(git rev-parse HEAD)
export FUTURERESTORE_VERSION_RELEASE=$(< version.txt)

print -n $FUTURERESTORE_VERSION_SHA > latest_build_sha.txt
print -n $FUTURERESTORE_VERSION > latest_build_num.txt

function package() {
  local x86_bin=$1
  local arm_bin=$2
  local output=$3

  [[ -f "$x86_bin" ]] && [[ -f "$arm_bin" ]] || { echo "Missing input binaries for $output"; return 1; }

  lipo -create -arch x86_64 "$x86_bin" -arch arm64 "$arm_bin" -output futurerestore
  codesign --force --sign - futurerestore
  tar cpPJf "$output" futurerestore
  rm -f futurerestore
}

package cmake-build-release-x86_64/src/futurerestore \
        cmake-build-release-arm64/src/futurerestore \
        "futurerestore-macOS-${FUTURERESTORE_VERSION_RELEASE}-Build_${FUTURERESTORE_VERSION}-RELEASE.tar.xz"

package cmake-build-debug-x86_64/src/futurerestore \
        cmake-build-debug-arm64/src/futurerestore \
        "futurerestore-macOS-${FUTURERESTORE_VERSION_RELEASE}-Build_${FUTURERESTORE_VERSION}-DEBUG.tar.xz"

package cmake-build-asan-x86_64/src/futurerestore \
        cmake-build-asan-arm64/src/futurerestore \
        "futurerestore-macOS-${FUTURERESTORE_VERSION_RELEASE}-Build_${FUTURERESTORE_VERSION}-ASAN.tar.xz"
