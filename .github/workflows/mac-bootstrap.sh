set -euo pipefail

export WORKFLOW_ROOT="/Users/runner/work/futurerestore/futurerestore/.github/workflows"
export DEP_ROOT="/Users/runner/work/futurerestore/futurerestore/dep_root"
export BASE="/Users/runner/work/futurerestore/futurerestore"
export PROCURSUS="/opt/procursus"

cd "$WORKFLOW_ROOT"

# Download dependencies safely
for url in \
  "https://cdn.cryptiiiic.com/bootstrap/bootstrap_x86_64.tar.zst" \
  "https://cdn.cryptiiiic.com/deps/static/macOS/x86_64/macOS_x86_64_Release_Latest.tar.zst" \
  "https://cdn.cryptiiiic.com/deps/static/macOS/arm64/macOS_arm64_Release_Latest.tar.zst" \
  "https://cdn.cryptiiiic.com/deps/static/macOS/x86_64/macOS_x86_64_Debug_Latest.tar.zst" \
  "https://cdn.cryptiiiic.com/deps/static/macOS/arm64/macOS_arm64_Debug_Latest.tar.zst"; do
  curl -fsO "$url" &
done
wait

# Extract bootstrap
sudo gtar xf bootstrap_x86_64.tar.zst -C / --warning=none || true

# Setup PATH
{
  echo "$PROCURSUS/bin"
  echo "$PROCURSUS/libexec/gnubin"
  cat /etc/paths
} | sudo tee /etc/paths.new >/dev/null
sudo mv /etc/paths.new /etc/paths

# Prepare dependency root
rm -rf "$DEP_ROOT/lib" "$DEP_ROOT/include" || true
mkdir -p "$DEP_ROOT/macOS_x86_64_Release" "$DEP_ROOT/macOS_x86_64_Debug" \
         "$DEP_ROOT/macOS_arm64_Release" "$DEP_ROOT/macOS_arm64_Debug"

gtar xf macOS_x86_64_Release_Latest.tar.zst -C "$DEP_ROOT/macOS_x86_64_Release" &
gtar xf macOS_x86_64_Debug_Latest.tar.zst -C "$DEP_ROOT/macOS_x86_64_Debug" &
gtar xf macOS_arm64_Release_Latest.tar.zst -C "$DEP_ROOT/macOS_arm64_Release" &
gtar xf macOS_arm64_Debug_Latest.tar.zst -C "$DEP_ROOT/macOS_arm64_Debug" &
wait

# Init submodules
cd "$BASE"
git submodule update --init --recursive
cd external/tsschecker
git submodule update --init --recursive
