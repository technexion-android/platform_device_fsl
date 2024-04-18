#! /vendor/bin/sh

if [ -f /sys/bus/mmc/devices/mmc?\:0001/device ]; then
	WIFIDEV=$(cat /sys/bus/mmc/devices/mmc?\:0001/device)
	case "$WIFIDEV" in
	0x0701)
		setprop vendor.all.wifi_bt_device QCA
		;;
	*)
		setprop vendor.all.wifi_bt_device NXP
		;;
	esac
else
    setprop vendor.all.wifi_bt_device NONE
fi
