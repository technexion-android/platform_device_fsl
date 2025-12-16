#! /vendor/bin/sh

FB_MODE_PATH="/sys/class/graphics/fb0/virtual_size"

# SOC
SOC=$(getprop ro.boot.soc_type)

# camera module
CAM=$(getprop ro.boot.camera.product)

if [ -f "$FB_MODE_PATH" ]; then
    FB_SIZE=$(cat $FB_MODE_PATH)
    WIDTH=${FB_SIZE%%,*}
    HEIGHT=${FB_SIZE##*,}

    # low resolution on display or camera module
    if [ "$WIDTH" -lt 1920 ] || [ "$HEIGHT" -lt 1080 ] || [ "$CAM" = "ar0144" ] ; then
        case "$SOC" in
            "imx95")
                TARGET_PROFILE="_95-ap1302"
                ;;
            "imx8mm"|"imx8mp")
                TARGET_PROFILE="-720p_30fps"
                ;;
            *)
                ;;
        esac
    fi
fi

if [ ! -z "$TARGET_PROFILE" ]; then
    setprop vendor.media.profile $TARGET_PROFILE
fi