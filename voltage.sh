#!/bin/bash

set -e

CC_DIR="$(pwd -P)/../.ccache" # CCache Path

if [ $(command -v apt) ]; then
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install git-core git-lfs jq rsync python3 gnupg ccache aarch64-linux-gnu-gcc flex bison build-essential zip curl zlib1g-dev libssl-dev libc6-dev-i386 libncurses5 x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig -y
    sudo ln -s /usr/bin/python3 /usr/bin/python
elif [ $(command -v pacman) ]; then
    sudo pacman -Sy --needed --noconfirm - < arch-pkg
fi

if [ ! $(command -v repo) ]; then
    if [ $(command -v pacman) ]; then
        sudo pacman -S repo
    fi
elif [ -f ~/.bin/repo ]; then
    export PATH="${HOME}/.bin:${PATH}"
else
    mkdir -p ~/.bin
    curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
    chmod a+rx ~/.bin/repo
    export PATH="${HOME}/.bin:${PATH}"
fi

# Git Config
if [ ! -f "$(realpath ~/.gitconfig)" ]; then
    git config --global user.email "@users.noreply.github.com"
    git config --global user.name "Ivy-Tokito"
fi

# Repo Clone
mkdir voltageos && cd voltageos && git-lfs install
yes | repo init -u https://github.com/VoltageOS/manifest.git -b 16.2 --git-lfs
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags

# Private Keys
git clone https://gitlab.com/Tokito_to/Private_keys.git -b voltage-16 private-keys

# Device Source
git clone https://github.com/LineageOS/android_device_xiaomi_sm8250-common.git -b lineage-23.2 device/xiaomi/sm8250-common
git clone https://github.com/LineageOS/android_device_xiaomi_apollon.git -b lineage-23.2 device/xiaomi/apollon
git clone https://github.com/TheMuppets/proprietary_vendor_xiaomi_sm8250-common.git -b lineage-23.2 vendor/xiaomi/sm8250-common
git clone https://github.com/TheMuppets/proprietary_vendor_xiaomi_apollon.git -b lineage-22.2 vendor/xiaomi/apollon
git clone https://github.com/LineageOS/android_kernel_xiaomi_sm8250.git -b lineage-23.2 kernel/xiaomi/sm8250

# Build
export BUILD_USERNAME=Tokito
export USE_CCACHE=1 CCACHE_EXEC=$(which ccache)
[[ ! -z "$CC_DIR" ]] && export CCACHE_DIR="$CC_DIR"
ccache -M 20G

. build/envsetup.sh && brunch voltage_apollon-bp2a-user
