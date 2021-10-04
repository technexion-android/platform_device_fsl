#!/system/bin/sh

ifconfig eth0 up

# screen rotation
sleep 5

if [[ "$(wm size | grep 720x1280)" ]];then
  rot_value=1
  # 0 = 0 degree, 1 = 90 degree, 2 = 180 degree, 3 = 270 degree
  content insert --uri content://settings/system --bind name:s:user_rotation --bind value:i:"$rot_value"
fi
