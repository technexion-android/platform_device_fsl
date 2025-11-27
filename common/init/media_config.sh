#! /vendor/bin/sh

FB_MODE_PATH="/sys/class/graphics/fb0/virtual_size"

# 720p profile
TARGET_PROFILE="_95-ap1302"

if [ -f "$FB_MODE_PATH" ]; then
    FB_SIZE=$(cat $FB_MODE_PATH)
    WIDTH=${FB_SIZE%%,*}
    HEIGHT=${FB_SIZE##*,}

    # low resolution display
    if [ "$WIDTH" -lt 1920 ] || [ "$HEIGHT" -lt 1080 ] ; then
        TARGET_PROFILE="_95-ap1302"
    fi
fi

if [ ! -z "$TARGET_PROFILE" ]; then
    setprop vendor.media.profile $TARGET_PROFILE
fi