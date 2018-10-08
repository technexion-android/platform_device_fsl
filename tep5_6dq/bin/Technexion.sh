#!/bin/bash
# This program is used to initial CANBUS
# 2017/10/06

ip link set can0 up type can bitrate 125000
ip link set can1 up type can bitrate 125000
tinymix 6 3

