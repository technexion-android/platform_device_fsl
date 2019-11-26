#!/system/bin/sh

#####################
# CAN BUS INIT
#####################
ip link set can0 type can bitrate 125000
ifconfig can0 up
sleep 0.1
ip link set can1 type can bitrate 125000
ifconfig can1 up

# enable bluetooth power
echo 1 > /sys/class/rfkill/rfkill0/state
