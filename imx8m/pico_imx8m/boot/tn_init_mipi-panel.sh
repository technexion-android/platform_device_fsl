#!/system/bin/sh

ifconfig eth0 up

# screen rotation
sleep 5
content insert --uri content://settings/system --bind name:s:user_rotation --bind value:i:1
