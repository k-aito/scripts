#!/usr/bin/env bash

# Set the input file
declare -r INPUT_FILE="$1"

# What do we extract
declare -r WHITELIST_CODEC_ID=(
  "V_MPEG2"
  "V_MPEG4/ISO/AVC"
  "V_MPEGH/ISO/HEVC"

  "A_AC3"
  "A_FLAC"
  "A_MPEG/L3"
  "A_VORBIS"

  "S_TEXT/UTF8"
  "S_TEXT/ASS"
)

# Set the output directory
declare -r OUTPUT_DIR_TRACKS="${2:-./tracks}"
declare -r OUTPUT_DIR_ATTACHMENTS="${2:-./attachments}"

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR_TRACKS" "$OUTPUT_DIR_ATTACHMENTS"

# Uncomment functions below if you use flatpak
#function mkvinfo() {
#  flatpak run --command=/app/bin/mkvinfo org.bunkus.mkvtoolnix-gui "$@"
#}
#function mkvextract() {
#  flatpak run --command=/app/bin/mkvextract org.bunkus.mkvtoolnix-gui "$@"
#}

# Extract information using mkvinfo and extract tracks
track_id=0
EXTRACT="false"
while IFS= read -r line; do
  # Cluster mark the end of the mkvinfo and so we can process the last track
  if echo "$line" | grep -q -e "Track number:" -e "Cluster" ; then
    if [[ "$EXTRACT" = "true" ]] ; then
      # Extract track information
      case "$codec_id" in
        "V_MPEG2")
          ext="mpeg2"
          ;;
        "V_MPEG4/ISO/AVC")
          ext="avc"
          ;;
        "V_MPEGH/ISO/HEVC")
          ext="hevc"
          ;;
        "A_AC3")
          ext="ac3"
          ;;
        "A_FLAC")
          ext="flac"
          ;;
        "A_MPEG/L3")
          ext="mp3"
          ;;
        "A_VORBIS")
          ext="ogg"
          ;;
        "S_TEXT/UTF8")
          ext="srt"
          ;;
        "S_TEXT/ASS")
          ext="ass"
          ;;
        *)
          echo "$codec_id is not known, add it in the case...esac"
          exit 1
          ;;
      esac
      echo "Extracting track $track_id: $track_name ($track_language, $codec_id, $ext)"
      echo "  Track ID: $track_id"
      echo "  Track name: $track_name"
      if [[ "${WHITELIST_CODEC_ID[*]}" =~ "$codec_id" ]] ; then
        echo "$codec_id match the (${WHITELIST_CODEC_ID[*]})"
        mkvextract tracks "$INPUT_FILE" $track_id:"$OUTPUT_DIR_TRACKS/$(basename "$INPUT_FILE")_${track_id}_${track_name}_${track_language}.${ext}" --ui-language en_US
      else
        echo "$codec_id doesn't match the (${WHITELIST_CODEC_ID[*]})"
      fi
      track_id=$((track_id + 1))
      EXTRACT="false"
    fi
    EXTRACT="true"
    track_name=""
    track_language=""
    codec_id=""
  elif echo "$line" | grep -q "Name:" ; then
    track_name=$(echo "$line" | cut -d ':' -f 2- | sed -e 's/^\ \+//g' -e 's/\ \+$//g')
  elif echo "$line" | grep -q "Language (IETF BCP 47):" ; then
    track_language=$(echo "$line" | cut -d ':' -f 2- | sed -e 's/^\ \+//g' -e 's/\ \+$//g')
  elif echo "$line" | grep -q "Codec ID:" ; then
    codec_id=$(echo "$line" | cut -d ':' -f 2- | sed -e 's/^\ \+//g' -e 's/\ \+$//g')
  fi
done < <(mkvinfo "$INPUT_FILE" --ui-language en_US)

# Extract information using mkvinfo and extract attachments
attachemnt_id=0
EXTRACT="false"
while IFS= read -r line; do
  # Cluster mark the end of the mkvinfo and so we can process the last attachment
  if echo "$line" | grep -q -e "Attached" -e "Cluster" ; then
    if [[ "$EXTRACT" = "true" ]] ; then
        # Extract attachment
        echo "Extracting track $attachemnt_id: $file_name ($file_uid, $mime_type)"
        echo "  Attachment ID: $attachemnt_id"
        echo "  File name: $file_name"
        # Attachment id start at 1
        mkvextract attachments "$INPUT_FILE" $((attachemnt_id + 1)):"$OUTPUT_DIR_ATTACHMENTS/$(basename "$INPUT_FILE")_${attachemnt_id}_${file_name}" --ui-language en_US
        attachemnt_id=$((attachemnt_id + 1))
        EXTRACT="false"
    fi
    EXTRACT="true"
    file_name=""
    mime_type=""
    file_uid=""
  elif echo "$line" | grep -q "File name:" ; then
    file_name=$(echo "$line" | cut -d ':' -f 2- | sed -e 's/^\ \+//g' -e 's/\ \+$//g')
  elif echo "$line" | grep -q "MIME type:" ; then
    mime_type=$(echo "$line" | cut -d ':' -f 2- | sed -e 's/^\ \+//g' -e 's/\ \+$//g')
  elif echo "$line" | grep -q "File UID:" ; then
    file_uid=$(echo "$line" | cut -d ':' -f 2- | sed -e 's/^\ \+//g' -e 's/\ \+$//g')
  fi
done < <(mkvinfo "$INPUT_FILE" --ui-language en_US | grep "Attached" -A 4)
