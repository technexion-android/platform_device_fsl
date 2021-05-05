#!/system/bin/sh

ifconfig eth0 up

# screen rotation
sleep 5

if [[ "$(getprop ro.boot.swrotation)" == "0" ]];then
  rot_value=0
elif [[ "$(getprop ro.boot.swrotation)" == "90" ]];then
  rot_value=1
elif [[ "$(getprop ro.boot.swrotation)" == "180" ]];then
  rot_value=2
elif [[ "$(getprop ro.boot.swrotation)" == "270" ]];then
  rot_value=3
fi

# 0 = 0 degree, 1 = 90 degree, 2 = 180 degree, 3 = 270 degree
content insert --uri content://settings/system --bind name:s:user_rotation --bind value:i:"$rot_value"
