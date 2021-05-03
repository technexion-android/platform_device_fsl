#!/system/bin/sh

ifconfig eth0 up

# detect rotation
while :
do
  if [[ "$(getprop init.svc.bootanim)" == "stopped"  ]];then
    sleep 6

    if [[ "$(getprop ro.boot.hwrotation)" == "0" ]];then
      rot_value=1
    elif [[ "$(getprop ro.boot.hwrotation)" == "90" ]];then
      rot_value=2
    elif [[ "$(getprop ro.boot.hwrotation)" == "180" ]];then
      rot_value=3
    elif [[ "$(getprop ro.boot.hwrotation)" == "270" ]];then
      rot_value=0
    fi
    # 1 = 0 degree, 2 = 90 degree, 3 = 180 degree, 0 = 270 degree
    content insert --uri content://settings/system --bind name:s:user_rotation --bind value:i:"$rot_value"
    break;
  fi
  sleep 2
done
