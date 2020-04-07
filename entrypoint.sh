#!/bin/bash

# borrowed from http://filthypants.blogspot.com/2009/05/monitoring-directory-to-automatically.html

#script to watch a directory for incoming files and pass them onto HandBrakeCLI

WATCH_DIR="/watch/"
OUTPUT_DIR="/output/"

# defaults
TASK_SPOOLER_SLOTS=1
HANDBRAKE_SETTINGS=" --preset-import-file /Uconnect.json --preset \"Uconnect\""
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
inotifywait --recursive --monitor --quiet -e moved_to -e close_write --format '%w%f' "$WATCH_DIR" | while read -r INPUT_FILE
do
  # make sure we have a video file
  FILE_TYPE=`file --mime-type "$INPUT_FILE" | sed -e 's/.* //' -e 's#/.*##'`

  if [ ${FILE_TYPE} == "video" ]
  then
    FULL_FILE_NAME=$(echo ${INPUT_FILE##*/})
    OUTPUT_FILE=$(echo ${FULL_FILE_NAME%.*})
    COVER_FILE=`mktemp`

    COVER_IMAGE=""
    # check for cover image
    find "$WATCH_DIR" -type f -iname "${OUTPUT_FILE}*" -print0 | while IFS= read -r -d $'\0' line; do
      IMAGE_CHECK=`file --mime-type "$line" | sed -e 's/.* //' -e 's#/.*##'`
      if [ ${IMAGE_CHECK} == "image" ]
      then
        COVER_IMAGE="$line"
        /usr/bin/convert "$line" -background none -gravity center -resize 800x600 -extent 800x600 cover.png
      fi
    done

    tsp bash -c 'nice -n 19 /usr/bin/HandBrakeCLI -v -i "$0" -o "$1""$2"."$3" "$4" && \
    mkvpropedit "$1""$2"."$3" --edit info --set title="$2" && \
    if [[ "$5" = yes ]] ; then sleep 15 ; rm -f "$0" ; fi ; rmdir -p "$(dirname "$0")"' "$INPUT_FILE" "$OUTPUT_DIR" "$OUTPUT_FILE" "$MY_FILE_TYPE" "$HANDBRAKE_SETTINGS" "$MY_DELETE_SOURCE"
  fi
done
