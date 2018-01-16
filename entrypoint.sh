#!/bin/bash

# borrowed from http://filthypants.blogspot.com/2009/05/monitoring-directory-to-automatically.html

#script to watch a directory for incoming files and pass them onto HandBrakeCLI

WATCH_DIR="/watch/"
OUTPUT_DIR="/output/"
TASK_SPOOLER_SLOTS=2

if [ ! -z "${THREADS}" ]; then
  TASK_SPOOLER_SLOTS=${THREADS}
fi

##HANDBRAKE PROFILE 1
PRESET1_NAME="android-hq"
PRESET1_HANDBRAKE_SETTINGS=" -e x264 -x weightp=0:cabac=0 -b 650 --audio 1 --aencoder faac --ab 96 --mixdown stereo --gain 3 --width 720 --loose-crop --decomb --markers --turbo --two-pass --vfr --subtitle 1 --native-language eng"
PRESET1_FILE_TYPE="mkv"
PRESET1_DELETE_SOURCE="yes"

###########################

ts -S $TASK_SPOOLER_SLOTS
inotifywait --recursive --monitor --quiet -e moved_to -e close_write --format '%w%f' "$WATCH_DIR" | while read -r INPUT_FILE; do

PRESET_NAME="$PRESET1_NAME"
HANDBRAKE_SETTINGS="$PRESET1_HANDBRAKE_SETTINGS"
FILE_TYPE="$PRESET1_FILE_TYPE"
DELETE_SOURCE="$PRESET1_DELETE_SOURCE"

if [[ $(echo "$WATCH_DIR" | grep -i "$PRESET1_NAME") ]] ; then
PRESET_NAME="$PRESET1_NAME"
HANDBRAKE_SETTINGS="$PRESET1_HANDBRAKE_SETTINGS"
FILE_TYPE="$PRESET1_FILE_TYPE"
DELETE_SOURCE="$PRESET1_DELETE_SOURCE"
fi
FULL_FILE_NAME=$(echo ${INPUT_FILE##*/})
OUTPUT_FILE=$(echo ${FULL_FILE_NAME%.*})
tsp bash -c 'nice -n 19 /usr/bin/HandBrakeCLI -v -i "$0" -o "$1""$2"-"$3"."$4" "$5" && if [[ "$6" = yes ]] ; then sleep 15 ; rm -f "$0" ; fi ; rmdir -p "$(dirname "$0")"' "$INPUT_FILE" "$OUTPUT_DIR" "$OUTPUT_FILE" "$PRESET_NAME" "$FILE_TYPE" "$HANDBRAKE_SETTINGS" "$DELETE_SOURCE"
done
