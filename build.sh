#!/usr/bin/env bash
set -euo pipefail

source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
firmware_dir=${1:-"$source_dir/firmware"}
mkdir -p -- "$firmware_dir"
firmware_dir=$(cd -- "$firmware_dir" && pwd)

docker run --rm --pull=missing \
  --mount "type=bind,source=$source_dir,target=/source,readonly" \
  --mount "type=bind,source=$firmware_dir,target=/firmware" \
  --mount type=volume,source=klighy-roba-zmk-v03,target=/workspace \
  --workdir /workspace \
  zmkfirmware/zmk-build-arm:stable bash -euo pipefail -c '
    exec 9>/workspace/.build.lock
    flock 9

    if [[ ! -f .west/config ]]; then
      mkdir -p config
      cp /source/config/west.yml config/west.yml
      west init -l config
    fi

    if ! cmp -s /source/config/west.yml .synced-west.yml; then
      cp /source/config/west.yml config/west.yml
      west update --fetch-opt=--filter=tree:0
      west zephyr-export
      cp config/west.yml .synced-west.yml
    fi

    build() {
      local shield=$1
      shift
      west build -p auto -s zmk/app -d "build/$shield" \
        -b seeeduino_xiao_ble "$@" -- \
        "-DSHIELD=$shield" -DZMK_CONFIG=/source/config -DZMK_EXTRA_MODULES=/source
    }

    build roBa_R -S studio-rpc-usb-uart
    build roBa_L

    for shield in roBa_R roBa_L; do
      cp "build/$shield/zephyr/zmk.uf2" "/firmware/$shield.uf2"
    done
  '
printf '\nUF2: %s\n' "$firmware_dir"
