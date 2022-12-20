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
export HOME_DIR="exodus"

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
cd $HOME && sudo apt-get install git -y && git clone https://github.com/CraftRom/scripts && cd scripts && sudo bash setup/android_build_env.sh
echo -e "$blue    \nDownloading manifest and initialized repo.\n $nocol"
push_message "Downloading manifest and initialized repo"
cd $HOME
mkdir -p $HOME_DIR
cd $HOME/$HOME_DIR/
repo init -u https://github.com/ExodusOS/android.git -b lineage-19.1
repo sync --detach --no-tags --force-remove-dirty --force-sync
