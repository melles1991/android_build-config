#!/bin/bash
# Change to the Source Directory
cd $SYNC_PATH
# Set-up ccache
if [ -z "$CCACHE_SIZE" ]; then
    ccache -M 10G
else
    ccache -M ${CCACHE_SIZE}
fi

SECONDS=0 # builtin bash timer
echo "--- Setup"

export OVERRIDE_TARGET_FLATTEN_APEX=true

export TYPE=userdebug
export DEVICE_START=onclite 
export LOGBUILD="tmp/android-build-${DEVICE_START}.log"

echo "--- Clean"
rm tmp/android-*.log || true
rm out/target/product/$DEVICE_START/ExodusOS-*.zip || true

# Telegram setup
push_message() {
    curl -s -X POST \
        https://api.telegram.org/bot5579959772:AAHJ1cvfipl05kxYhNQBvLy7b60vGmeQSRE/sendMessage \
        -d chat_id="-1001593139005" \
        -d text="$1" \
        -d "parse_mode=html" \
        -d "disable_web_page_preview=true"
}

push_document() {
    curl -s -X POST \
        https://api.telegram.org/bot5579959772:AAHJ1cvfipl05kxYhNQBvLy7b60vGmeQSRE/sendDocument \
        -F chat_id="-1001593139005" \
        -F document=@"$1" \
        -F caption="$2" \
        -F "parse_mode=html" \
        -F "disable_web_page_preview=true"
}
 
echo "--- Building"
. build/envsetup.sh
mka cleaninstall
breakfast lineage_$DEVICE_START-$TYPE

export BUILD_DATE=$(date '+%Y-%m-%d  %H:%M')

# Push message if build started
push_message "<b>Start building ExodusOS for <code>$DEVICE_START</code></b>
<b>BuildDate:</b> <code>$BUILD_DATE</code>"
brunch $DEVICE_START -j8 | tee $LOGBUILD

rom="out/target/product/$DEVICE_START/ExodusOS-*.zip"
if [ -f "$rom" ]; then
	echo -e "$blue --- Uploading *.zip. $nocol"
	scp out/target/product/$DEVICE_START/ExodusOS-*.zip melles1991@frs.sourceforge.net:/home/frs/project/exodusos/ExodusOS/onclite/$DEVICE_START/squirrel

	# Push to telegram
	push_message "ExodusOS for <code>$DEVICE_START</code>
	<b>Type:</b> <code>$TYPE</code>
	<b>BuildDate:</b> <code>$BUILD_DATE</code>
	<b>md5 checksum :</b> <code>$(md5sum "$rom" | cut -d' ' -f1)</code>"

	push_document "$LOGBUILD" "
	<b>ExodusOS for <code>$DEVICE_START</code> compiled succesfully!</b>
	Total build time <b>$((SECONDS / 60))</b> minute(s) and <b>$((SECONDS % 60))</b> second(s) !
	#logs #$DEVICE_START "
	echo -e "(i)          Send to telegram succesfully!\n"
else
	echo -e "$red \Rom Compilation failed! Fix the errors!\n $nocol"
	# Push message if build error
	push_message "$BUILDER! <b>Failed building ExodusOS for <code>$DEVICE_START</code></b> 
	<b>Please fix it...!</b>
	Total build time <b>$((SECONDS / 60))</b> minute(s) and <b>$((SECONDS % 60))</b> second(s) !"
	push_document "$LOGBUILD" "#$DEVICE_START #error #exodus "
fi
