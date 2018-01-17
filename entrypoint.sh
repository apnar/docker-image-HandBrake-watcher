#!/bin/bash

# borrowed from http://filthypants.blogspot.com/2009/05/monitoring-directory-to-automatically.html

#script to watch a directory for incoming files and pass them onto HandBrakeCLI

WATCH_DIR="/watch/"
OUTPUT_DIR="/output/"

# defaults
TASK_SPOOLER_SLOTS=2
HANDBRAKE_SETTINGS=" --preset \"H.264 MKV 720p30\" --native-language eng"
MY_FILE_TYPE="mkv"
MY_DELETE_SOURCE="no"

if [ ! -z "${THREADS}" ]; then
  TASK_SPOOLER_SLOTS=${THREADS}
fi

if [ ! -z "${HANDBRAKE_OPTIONS}" ]; then
  HANDBRAKE_SETTINGS="${HANDBRAKE_OPTIONS}"
fi

if [ ! -z "${FILE_TYPE}" ]; then
  MY_FILE_TYPE=${FILE_TYPE}
fi

if [ ! -z "${DELETE_SOURCE}" ]; then
  MY_DELETE_SOURCE=${DELETE_SOURCE}
fi


###########################

tsp -S $TASK_SPOOLER_SLOTS
inotifywait --recursive --monitor --quiet -e moved_to -e close_write --format '%w%f' "$WATCH_DIR" | while read -r INPUT_FILE; do

FULL_FILE_NAME=$(echo ${INPUT_FILE##*/})
OUTPUT_FILE=$(echo ${FULL_FILE_NAME%.*})
tsp bash -c 'nice -n 19 /usr/bin/HandBrakeCLI -v -i "$0" -o "$1""$2"."$3" "$4" && mkvpropedit "$1""$2"."$3" --edit info --set \"title="$2"\" && if [[ "$5" = yes ]] ; then sleep 15 ; rm -f "$0" ; fi ; rmdir -p "$(dirname "$0")"' "$INPUT_FILE" "$OUTPUT_DIR" "$OUTPUT_FILE" "$MY_FILE_TYPE" "$HANDBRAKE_SETTINGS" "$MY_DELETE_SOURCE"
done
