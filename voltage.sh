#!/bin/bash

set -e

GITPASS="" # Git Token
CC_DIR="$(pwd -P)/../.ccache" # CCache Path

if [ $(command -v apt) ]; then
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install git-core git-lfs jq rsync python3 gnupg ccache aarch64-linux-gnu-gcc flex bison build-essential zip curl zlib1g-dev libssl-dev libc6-dev-i386 libncurses5 x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig -y
    sudo ln -s /usr/bin/python3 /usr/bin/python
elif [ $(command -v pacman) ]; then
    sudo pacman -Sy --needed --noconfirm -< arch-pkg
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
yes | repo init -u https://github.com/VoltageOS/manifest.git -b 15-qpr2 --git-lfs
git clone https://github.com/Tokito-to/munch_manifest -b voltage-15 .repo/local_manifests
git clone https://$GITPASS@github.com/Kurumi-Tokito/Private_keys.git -b voltage-15 private-keys
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags

# Build
export BUILD_USERNAME=Tokito
export USE_CCACHE=1 CCACHE_EXEC=$(which ccache)
[[ ! -z "$CC_DIR" ]] && export CCACHE_DIR="$CC_DIR"
ccache -M 20G

sudo mount -o remount,size=32G /tmp #increase /tmp space to 32G #to avoid no space in /tmp error

. build/envsetup.sh && brunch voltage_munch-bp1a-user

#prebuilts/jdk/jdk17/linux-x86/bin/java -Xmx2048m -Djava.library.path="out/host/linux-x86/lib64" -jar out/host/linux-x86/framework/signapk.jar  keys/releasekey.x509.pem keys/releasekey.pk8 out/input.apk out/signed.apk
