#!/bin/bash

# MODULE=$(basename $BASH_SOURCE)
FILE_PATH="$1"
MODULE="$2"
NAME_TYPE=$(echo $MODULE | awk -F. '{print $1}')
DISPLAY_MODULE=$(echo $MODULE | awk -F. '{print $2}')
TARGET_FILE="uEnv.txt"
SOURCE_FILE="uEnv.txt"."$NAME_TYPE"."$DISPLAY_MODULE"

echo "Model Name =" "$NAME_TYPE"
echo "Display type =" "$DISPLAY_MODULE"
echo "Source File =" "$SOURCE_FILE"
echo "Target File =" "$TARGET_FILE"

echo "Delete" "$TARGET_FILE"
rm "$FILE_PATH""$TARGET_FILE"
echo "copy" "$FILE_PATH""$SOURCE_FILE" "to" "$FILE_PATH""$TARGET_FILE"
cp "$FILE_PATH""$SOURCE_FILE" "$FILE_PATH""$TARGET_FILE"

