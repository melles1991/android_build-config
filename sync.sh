#!/bin/bash
#
# Compile script for kernel
# Copyright (C) 2022 Craft Rom.

SECONDS=0 # builtin bash timer

#Set Color
blue='\033[0;34m'
grn='\033[0;32m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'
txtbld=$(tput bold)
txtrst=$(tput sgr0) 

export DATE=$(date '+%Y-%m-%d  %H:%M')

# Telegram setup
push_message() {
    curl -s -X POST \
         https://api.telegram.org/bot5579959772:AAHJ1cvfipl05kxYhNQBvLy7b60vGmeQSRE/sendMessage \
        -d chat_id="-1001593139005" \
        -d text="$1" \
        -d "parse_mode=html" \
        -d "disable_web_page_preview=true"
}

push_message "<b>Build ExodusOS bot is running.</b>
<b>Date:</b> <code>$DATE</code>"
# Make the Directory if it doesn't exist
mkdir -p $SYNC_PATH

# Init
cd $HOME && sudo apt-get install git -y && git clone https://github.com/CraftRom/scripts && cd scripts && sudo bash setup/android_build_env.sh

# Change to the Source Directory
cd $SYNC_PATH

echo -e "$blue    \nDownloading manifest and initialized repo.\n $nocol"
push_message "Downloading manifest and initialized repo"
echo -e "$blue    \n initialized repo.\n $nocol"
mkdir -p $SYNC_PATH/exodus
cd $SYNC_PATH/exodus
# Init
sudo apt-get install git-core gnupg flex bison build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 libncurses5 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig
mkdir -p ~/.bin
PATH="${HOME}/.bin:${PATH}"
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
chmod a+rx ~/.bin/repo
repo init --depth=1 -u $MANIFEST -b $MANIFEST_BRANCH
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-remove-dirty --force-sync

echo -e "$blue    \n end initialized repo.\n $nocol"
# Exit
exit 0
